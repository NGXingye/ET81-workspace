import argparse
import json
import re
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path
import held_paths
ROOT = Path(__file__).resolve().parents[1]
PLAN = ROOT / "contracts" / "commit_plan.json"
TARGETS = ROOT / "targets"
SCRIPTS = "Unity/Assets/Scripts"
TOKEN = re.compile(r"\b[A-Za-z_][A-Za-z0-9_]{5,}\b")
KEEP = {"added", "modified", "deleted", "unversioned", "missing", "replaced", "conflicted"}
COMMON = {"GetComponent", "AddComponent", "RemoveComponent", "GetParent", "Instance", "ToString", "EntityRef", "ETTask", "Debug", "LogError", "LogWarning", "Component", "Transform", "Position", "Rotation", "Dispose", "Awake", "Destroy", "Update", "Object", "String", "Boolean", "gameObject", "GameObject"}
def norm(path):
    text = str(path).replace("\\", "/")
    mark = text.find(SCRIPTS)
    return text[mark:] if mark >= 0 else text.lstrip("./")
def load_plan(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))
def save_plan(path, plan):
    Path(path).write_text(json.dumps(plan, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
def svn_out(root, args):
    done = subprocess.run(["svn", *args], cwd=str(root), capture_output=True)
    return b"" if done.returncode != 0 else done.stdout
def dirty_map(root):
    if not (Path(root) / SCRIPTS).is_dir():
        return {}
    raw = svn_out(root, ["status", "--xml", SCRIPTS])
    if not raw:
        raise SystemExit("svn status failed")
    found = {}
    for entry in ET.fromstring(raw).iter("entry"):
        rel = norm(entry.get("path") or "")
        status = entry.find("wc-status")
        if not rel.startswith(SCRIPTS + "/") or status is None or status.get("item") not in KEEP or (Path(root) / rel).is_dir():
            continue
        found[rel] = status.get("item")
    return found
def tokens_of(text):
    lines = [line for line in text.splitlines() if line.startswith("+") and not line.startswith("+++")]
    return {token for line in lines for token in TOKEN.findall(line) if token not in COMMON and any(ch.isupper() for ch in token)}
def change_text(root, rel, rev, item):
    if item == "unversioned":
        body = (Path(root) / rel).read_bytes()[:80000].decode("utf-8", "replace")
        return "\n".join("+" + line for line in body.splitlines()[:500])
    args = ["diff", "-c", str(rev), rel] if rev else ["diff", rel]
    return svn_out(root, args).decode("utf-8", "replace")
def covered(plan):
    return {norm(rel) for unit in plan.get("units") or [] for rel in unit.get("paths") or []}
def local_only_of(root):
    root = Path(root).resolve()
    for path in TARGETS.glob("*.json"):
        target = json.loads(path.read_text(encoding="utf-8"))
        if Path(str(target.get("workspace_path") or "")).resolve() == root:
            return [str(p).replace("\\", "/").lower() for p in target.get("local_only") or []]
    return []
def match_local_only(key, entries):
    for entry in entries:
        base = entry.rstrip("/")
        if key in (base, base + ".meta") or (entry.endswith("/") and key.startswith(entry)):
            return True
    return False
def is_local_only(root, rel):
    key = norm(rel).replace("\\", "/").lower()
    return match_local_only(key, local_only_of(root))
def is_local_only_any(rel):
    key = norm(rel).replace("\\", "/").lower()
    for path in TARGETS.glob("*.json"):
        target = json.loads(path.read_text(encoding="utf-8"))
        entries = [str(p).replace("\\", "/").lower() for p in target.get("local_only") or []]
        if match_local_only(key, entries):
            return True
    return False
def workspaces(plan):
    found = []
    for unit in plan.get("units") or []:
        root = str(unit.get("workspace_path") or "")
        if root and root not in found and (Path(root) / SCRIPTS).is_dir(): found.append(root)
    return found
def cs_count(paths):
    return sum(1 for rel in paths if norm(rel).endswith(".cs"))
def next_id(plan):
    nums = [int(unit["id"][1:]) for unit in plan["units"] if re.fullmatch(r"u\d+", str(unit.get("id") or ""))]
    return "u" + str(max(nums or [0]) + 1)
def digit_hook(plan, unit):
    hook = str((unit or {}).get("hook_task") or "")
    if hook.isdigit():
        return hook
    return next((str(item.get("hook_task") or "") for item in plan["units"] if str(item.get("hook_task") or "").isdigit()), "")
def unit_symbols(plan):
    bags = {}
    for unit in plan.get("units") or []:
        root = str(unit.get("workspace_path") or "")
        rev = str(unit.get("committed_rev") or "") if unit.get("status") == "committed" else ""
        bag = set()
        for rel in unit.get("paths") or []:
            rel = norm(rel)
            if not rel.startswith(SCRIPTS + "/") or not (Path(root) / rel).is_file():
                continue
            item = "unversioned" if rev == "" and subprocess.run(["svn", "info", rel], cwd=root, capture_output=True).returncode != 0 else ""
            bag |= tokens_of(change_text(root, rel, rev, item))
        bags[unit["id"]] = bag
    return bags
def owner_unit(plan, rel):
    for unit in plan["units"]:
        if rel in [norm(item) for item in unit.get("paths") or []]:
            return unit
    return None
def append_unit(plan, bags, root, paths, hook, symbol, fresh):
    uid = next_id(plan)
    plan["units"].append({"id": uid, "title": "补上 " + (symbol or "相关脚本"), "hook_task": hook, "workspace_path": root, "paths": paths, "status": "pending"})
    bags[uid] = set(fresh)
def place(plan, bags, root, rel, dirty, fresh, hit):
    meta = rel + ".meta"
    paths = [rel]
    if rel.endswith(".cs") and meta in dirty and meta not in covered(plan) and (Path(root) / meta).is_file():
        paths.append(meta)
    best = None
    best_n = 0
    for unit in plan["units"]:
        if str(unit.get("workspace_path") or "") != root:
            continue
        count = len(hit & bags.get(unit["id"], set()))
        if count > best_n:
            best_n = count
            best = unit
    extra_cs = 1 if rel.endswith(".cs") else 0
    if best and best.get("status") != "committed" and cs_count(best["paths"]) + extra_cs <= 8:
        best["paths"].extend(paths)
        bags[best["id"]] = bags.get(best["id"], set()) | fresh
        return
    append_unit(plan, bags, root, paths, digit_hook(plan, best), sorted(hit)[0] if hit else "", fresh)
def fill(path):
    plan = load_plan(path)
    bags = unit_symbols(plan)
    known = set().union(*bags.values()) if bags else set()
    added, marked, crossed = [], [], []
    roots = workspaces(plan)
    plan_covered = covered(plan)
    skipped_held, skipped_local = [], []
    omitted = []
    seen = set()
    for item in plan.get("omitted") or []:
        rel = norm(item.get("path") or "")
        if not rel or rel in plan_covered or any(held_paths.held_match(root, rel) for root in roots) or is_local_only_any(rel) or rel in seen:
            continue
        omitted.append(item)
        seen.add(rel)
    for root in roots:
        dirty = dirty_map(root)
        pending = [rel for rel in dirty if rel not in plan_covered and not held_paths.held_match(root, rel) and not is_local_only(root, rel) and not rel.endswith(".meta")]
        for _ in range(6):
            moved = False
            for rel in list(pending):
                if dirty[rel] == "conflicted":
                    continue
                fresh = tokens_of(change_text(root, rel, "", dirty[rel]))
                hit = fresh & known
                if not hit:
                    continue
                place(plan, bags, root, rel, dirty, fresh, hit)
                plan_covered = covered(plan)
                known |= fresh
                pending.remove(rel)
                added.append(rel)
                moved = True
            if not moved:
                break
        for rel in dirty:
            if rel in covered(plan) or rel in seen:
                continue
            if held_paths.held_match(root, rel):
                fresh = tokens_of(change_text(root, rel, "", dirty[rel]))
                (crossed if fresh & known else skipped_held).append(rel)
                continue
            if is_local_only(root, rel):
                skipped_local.append(rel)
                continue
            cs = rel[:-5] if rel.endswith(".meta") else ""
            owner = owner_unit(plan, cs) if cs else None
            if owner and owner.get("status") != "committed":
                owner["paths"].append(rel)
                added.append(rel)
                continue
            note = "有冲突，不自动纳入" if dirty[rel] == "conflicted" else "Scripts 中有改动，但和本计划新增符号没有交集"
            omitted.append({"path": rel, "note": note})
            seen.add(rel)
            marked.append(rel)
    plan["omitted"] = omitted
    save_plan(path, plan)
    def show(label, rows):
        print(label + " " + str(len(rows)) + " 个")
        for rel in rows:
            print("  " + rel)
    show("补进", added)
    show("标注", marked)
    if skipped_held:
        show("暂留已覆盖", skipped_held)
    if crossed:
        show("暂留相交，需决定", crossed)
    if skipped_local:
        show("local_only 跳过", skipped_local)
def verify(path):
    plan = load_plan(path)
    pending = [unit["id"] for unit in plan.get("units") or [] if unit.get("status") != "committed"]
    missed, marked, held_hit, crossed, local_hit = [], [], [], [], []
    notes = {norm(item.get("path") or ""): str(item.get("note") or "") for item in plan.get("omitted") or []}
    seen = covered(plan)
    bags = unit_symbols(plan)
    known = set().union(*bags.values()) if bags else set()
    for root in workspaces(plan):
        for rel, item in dirty_map(root).items():
            if rel in seen:
                continue
            if held_paths.held_match(root, rel):
                fresh = tokens_of(change_text(root, rel, "", item))
                (crossed if fresh & known else held_hit).append(rel)
                continue
            if is_local_only(root, rel):
                local_hit.append(rel)
                continue
            marked.append(rel + "  " + notes[rel]) if rel in notes else missed.append(rel)
    if pending:
        print("未提交：" + " ".join(pending))
    def block(title, rows):
        print(title)
        print("  无" if not rows else "\n".join("  " + rel for rel in rows))
    block("漏提交", missed)
    block("已标注", marked)
    block("暂留已覆盖", held_hit)
    block("暂留相交，需决定", crossed)
    if local_hit:
        print("local_only 跳过 " + str(len(local_hit)) + " 个")
    if not missed and not marked and not crossed:
        print("Scripts 范围内没有漏提交")
    return 1 if missed or marked or crossed else 0
def main():
    parser = argparse.ArgumentParser(description="check commit plan against Scripts")
    parser.add_argument("--fill", action="store_true")
    parser.add_argument("--verify", action="store_true")
    parser.add_argument("--plan", default=str(PLAN))
    args = parser.parse_args()
    if args.fill:
        fill(args.plan)
        return
    raise SystemExit(verify(args.plan))
if __name__ == "__main__":
    main()
