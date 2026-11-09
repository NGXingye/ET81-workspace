"""Commit one unit from contracts/commit_plan.json. UTF-8 message file. No --all. held is not a commit slot."""
import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
import held_paths

ROOT = Path(__file__).resolve().parents[1]
PLAN = ROOT / "contracts" / "commit_plan.json"
TEMPLATE = ROOT / "contracts" / "_template_commit_plan.json"

def load_plan(path):
    if not path.is_file():
        raise SystemExit("missing " + str(path))
    return json.loads(path.read_text(encoding="utf-8"))

def save_plan(path, plan):
    path.write_text(json.dumps(plan, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

def check_plan(plan):
    units = plan.get("units") or []
    if not plan.get("task_id") or not str(plan.get("summary") or "").strip():
        raise SystemExit("commit plan needs task_id and summary")
    if not units:
        raise SystemExit("units must not be empty")
    seen = set()
    ids = set()
    for unit in units:
        uid = str(unit.get("id") or "")
        if not uid or uid in ids:
            raise SystemExit("unit id missing or duplicated")
        ids.add(uid)
        if not str(unit.get("title") or "").strip():
            raise SystemExit(uid + " needs title")
        for rel in unit.get("paths") or []:
            key = str(unit.get("workspace_path") or "") + "|" + rel.replace("\\", "/")
            if key in seen:
                raise SystemExit("path in two units: " + rel)
            if ".." in Path(rel).parts:
                raise SystemExit("path must stay inside workspace: " + rel)
            seen.add(key)

def confirm_overlap(unit, extract, dry, live):
    if not live:
        return True
    lines = held_paths.overlaps(unit)
    if not lines:
        return True
    print("这些路径还在 held，提交会带上该文件的全部本地改动：")
    for line in lines:
        print("  " + line)
    if dry or extract:
        return True
    if not sys.stdin.isatty():
        raise SystemExit("path overlap with held_commit_plan; pass --extract to commit and strike after success")
    try:
        answer = input("提交成功后从模块划掉？y/n ").strip().lower()
    except EOFError:
        return False
    return answer == "y"

def strike_after(unit, dry, live):
    if dry or not live:
        return
    for note in held_paths.strike(unit):
        print("模块仍按目录暂留，请把剩余文件改成列表：" + note)

def message_of(plan, unit):
    hook = str(unit.get("hook_task") or "").strip()
    if not hook.isdigit():
        raise SystemExit(unit["id"] + " hook_task must be digits")
    summary = str(plan["summary"]).strip()
    title = str(unit["title"]).strip()
    return "task:" + hook + " " + summary + "；" + title

def run_svn(root, args):
    done = subprocess.run(["svn", *args], cwd=str(root), capture_output=True, text=True, encoding="utf-8", errors="replace")
    if done.returncode != 0:
        sys.stdout.write(done.stdout or "")
        sys.stderr.write(done.stderr or "")
        raise SystemExit("svn " + args[0] + " failed")
    return done

def add_unversioned(root, paths):
    for rel in paths:
        info = subprocess.run(["svn", "info", rel], cwd=str(root), capture_output=True, text=True, encoding="utf-8", errors="replace")
        if info.returncode == 0:
            continue
        # svn add 会无视忽略规则强行加入；本地专用文件以 svn 忽略为准，遇 I 就拒绝
        st = run_svn(root, ["status", "--no-ignore", "--depth", "empty", rel]).stdout
        if st[:1] == "I":
            raise SystemExit("local-only path is svn-ignored, refuse add: " + rel)
        run_svn(root, ["add", "--parents", rel])

def local_only_of(root):
    for path in (ROOT / "targets").glob("*.json"):
        target = json.loads(path.read_text(encoding="utf-8"))
        if Path(str(target.get("workspace_path") or "")).resolve() == root.resolve():
            return [str(p).replace("\\", "/").lower() for p in target.get("local_only") or []]
    return []

def refuse_local_only(root, paths):
    # 不依赖本机 svn 配置：命中目标 local_only（/ 结尾为目录，含 Unity .meta）就拒绝
    entries = local_only_of(root)
    for rel in paths:
        key = rel.replace("\\", "/").lower()
        for entry in entries:
            base = entry.rstrip("/")
            if key in (base, base + ".meta") or (entry.endswith("/") and key.startswith(entry)):
                raise SystemExit("local-only path (targets local_only), refuse commit: " + rel)

def commit_unit(plan, unit, dry):
    if unit.get("status") == "committed":
        raise SystemExit(unit["id"] + " already committed")
    paths = [str(p) for p in (unit.get("paths") or [])]
    if not paths:
        raise SystemExit(unit["id"] + " has no paths")
    root = Path(str(unit.get("workspace_path") or ""))
    if not root.is_dir():
        raise SystemExit("workspace_path missing: " + str(root))
    missing = [p for p in paths if not (root / p).exists()]
    if missing:
        raise SystemExit("missing files: " + ", ".join(missing))
    refuse_local_only(root, paths)
    text = message_of(plan, unit)
    if dry:
        print(text)
        return None
    handle = tempfile.NamedTemporaryFile("w", encoding="utf-8", newline="\n", suffix=".txt", delete=False)
    handle.write(text + "\n")
    handle.close()
    add_unversioned(root, paths)
    done = run_svn(root, ["commit", *paths, "-F", handle.name, "--encoding", "utf-8"])
    found = re.search(r"Committed revision (\d+)", done.stdout or "")
    unit["status"] = "committed"
    if found:
        unit["committed_rev"] = found.group(1)
    return found.group(1) if found else ""

def enable_gray():
    if sys.platform != "win32":
        return True
    try:
        import ctypes
        kernel = ctypes.windll.kernel32
        handle = kernel.GetStdHandle(-11)
        mode = ctypes.c_uint()
        if not kernel.GetConsoleMode(handle, ctypes.byref(mode)):
            return False
        return bool(kernel.SetConsoleMode(handle, mode.value | 4))
    except OSError:
        return False

def show_verify(path):
    script = ROOT / "runtime" / "check-commit-plan.py"
    done = subprocess.run([sys.executable, str(script), "--verify", "--plan", str(path)])
    if done.returncode not in (0, 1):
        print("验证失败")
    input("回车继续")

def run_menu(path, dry, live, extract):
    use_gray = enable_gray()
    while True:
        plan = load_plan(path)
        check_plan(plan)
        os.system("cls" if sys.platform == "win32" else "clear")
        print(plan["task_id"])
        for index, unit in enumerate(plan["units"], 1):
            done = unit.get("status") == "committed"
            line = str(index) + "  " + unit["title"]
            if done:
                line += "  已提交"
                if use_gray:
                    line = "\033[90m" + line + "\033[0m"
            print(line)
        print("编号回车提交，r 刷新，v 验证完整性，q 退出")
        try:
            picked = input("> ").strip()
        except EOFError:
            return
        if picked.lower() == "q":
            return
        if picked.lower() == "r":
            continue
        if picked.lower() == "v":
            show_verify(path)
            continue
        if not picked.isdigit():
            continue
        number = int(picked)
        if number < 1 or number > len(plan["units"]):
            continue
        unit = plan["units"][number - 1]
        if unit.get("status") == "committed":
            continue
        if not confirm_overlap(unit, extract, dry, live):
            input("未提交，回车继续")
            continue
        try:
            commit_unit(plan, unit, dry)
        except SystemExit as err:
            print(err)
            input("回车继续")
            continue
        if dry:
            input("未提交，回车继续")
            continue
        save_plan(path, plan)
        strike_after(unit, dry, live)

def main():
    parser = argparse.ArgumentParser(description="commit one plan unit")
    parser.add_argument("--unit", help="commit this unit id")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--demo", action="store_true", help="load the template")
    parser.add_argument("--held", action="store_true", help="rejected: held is a module index")
    parser.add_argument("--extract", action="store_true", help="commit despite held overlap; strike exact files after success")
    args = parser.parse_args()
    if args.held:
        raise SystemExit("held_commit_plan is a module index, not a commit slot; commit contracts/commit_plan.json")
    path = TEMPLATE if args.demo else PLAN
    live = not args.demo
    if args.unit:
        plan = load_plan(path)
        check_plan(plan)
        unit = next((item for item in plan["units"] if item["id"] == args.unit), None)
        if not unit:
            raise SystemExit("no unit " + args.unit)
        dry = args.dry_run or args.demo
        if not confirm_overlap(unit, args.extract, dry, live):
            raise SystemExit("held overlap left in place")
        commit_unit(plan, unit, dry)
        if dry:
            return
        save_plan(path, plan)
        strike_after(unit, dry, live)
        return
    if args.dry_run and not sys.stdin.isatty():
        plan = load_plan(path)
        check_plan(plan)
        print("units " + str(len(plan["units"])))
        return
    run_menu(path, args.dry_run or args.demo, live, args.extract)

if __name__ == "__main__":
    main()
