"""Match held modules by workspace. Strike exact files only after a successful commit. No SVN."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HELD = ROOT / "contracts" / "held_commit_plan.json"
SCRIPTS = "Unity/Assets/Scripts"
_cache = None

def norm_rel(rel):
    text = str(rel or "").replace("\\", "/").strip()
    mark = text.find(SCRIPTS)
    return text[mark:] if mark >= 0 else text.lstrip("./")

def ws_key(ws):
    text = str(ws or "").rstrip("\\/")
    if not text:
        return ""
    try:
        return str(Path(text).resolve()).rstrip("\\/").lower()
    except OSError:
        return text.lower()

def load_held():
    global _cache
    key = str(HELD)
    if _cache is not None and _cache[0] == key:
        return _cache[1]
    if not HELD.is_file():
        data = {"modules": []}
    else:
        data = json.loads(HELD.read_text(encoding="utf-8"))
        if not isinstance(data.get("modules"), list):
            data["modules"] = []
    _cache = (key, data)
    return data

def save_held(data):
    global _cache
    HELD.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    _cache = (str(HELD), data)

def is_dir(ws, rel):
    raw = str(rel or "").replace("\\", "/").strip()
    if raw.endswith("/"):
        return True
    try:
        return (Path(ws) / raw.rstrip("/")).is_dir()
    except OSError:
        return False

def match_kind(mod_ws, mod_rel, root, rel):
    if ws_key(mod_ws) != ws_key(root):
        return ""
    left = norm_rel(mod_rel).lower().rstrip("/")
    right = norm_rel(rel).lower().rstrip("/")
    if not left or not right:
        return ""
    if left == right:
        return "dir" if is_dir(mod_ws, mod_rel) else "file"
    if is_dir(mod_ws, mod_rel) and right.startswith(left + "/"):
        return "dir"
    return ""

def overlaps(unit):
    root = unit.get("workspace_path") or ""
    lines, seen = [], set()
    for mod in load_held().get("modules") or []:
        mid = str(mod.get("id") or "")
        for raw in mod.get("paths") or []:
            for up in unit.get("paths") or []:
                kind = match_kind(mod.get("workspace_path"), raw, root, up)
                if not kind:
                    continue
                line = mid + ": " + ("目录 " if kind == "dir" else "") + norm_rel(up)
                if line not in seen:
                    seen.add(line)
                    lines.append(line)
    return lines

def held_match(root, rel):
    for mod in load_held().get("modules") or []:
        for raw in mod.get("paths") or []:
            if match_kind(mod.get("workspace_path"), raw, root, rel):
                return True
    return False

def strike(unit):
    data = load_held()
    root = unit.get("workspace_path") or ""
    notes, kept, changed = [], [], False
    for mod in data.get("modules") or []:
        paths = []
        for raw in mod.get("paths") or []:
            kind = ""
            for up in unit.get("paths") or []:
                hit = match_kind(mod.get("workspace_path"), raw, root, up)
                if hit == "file":
                    kind = "file"
                    break
                if hit == "dir":
                    kind = "dir"
            if kind == "file":
                changed = True
                continue
            if kind == "dir":
                notes.append(str(mod.get("id") or "") + ": " + norm_rel(raw))
            paths.append(raw)
        if paths:
            mod["paths"] = paths
            kept.append(mod)
        else:
            changed = True
    if changed:
        data["modules"] = kept
        save_held(data)
    return notes
