#!/usr/bin/env bash
# link-ai-integration.sh — Link a tool-specific AI kit into a project using its manifest.

set -euo pipefail

INTEGRATION="${1:-}"
KIT_PATH_INPUT="${2:-}"
TARGET_DIR_INPUT="${3:-$(pwd)}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "  ${CYAN}->${RESET}  $*"; }
success() { echo -e "  ${GREEN}OK${RESET}  $*"; }
warn()    { echo -e "  ${YELLOW}!!${RESET}  $*"; }
error()   { echo -e "  ${RED}ERR${RESET}  $*" >&2; exit 1; }

require_command() {
  command -v "$1" >/dev/null 2>&1 || error "Missing required command: $1"
}

detect_python() {
  if command -v python3 >/dev/null 2>&1; then
    echo "python3"
  elif command -v python >/dev/null 2>&1; then
    echo "python"
  else
    error "Missing required command: python3 or python"
  fi
}

usage() {
  cat <<'EOF'
Usage: link-ai-integration.sh <integration> <kit-path> [target-dir]

Examples:
  link-ai-integration.sh copilot .copilot
  link-ai-integration.sh claude .claude /path/to/project
EOF
}

[ -n "$INTEGRATION" ] || { usage; error "Missing integration name"; }
[ -n "$KIT_PATH_INPUT" ] || { usage; error "Missing kit path"; }

PYTHON_BIN="$(detect_python)"

TARGET_DIR="$(cd "$TARGET_DIR_INPUT" && pwd)"
KIT_PATH="$(cd "$TARGET_DIR" && cd "$KIT_PATH_INPUT" && pwd)"
MANIFEST_PATH="$KIT_PATH/.specify/ai-kit.manifest.json"

[ -d "$TARGET_DIR/.git" ] || git -C "$TARGET_DIR" rev-parse --git-dir >/dev/null 2>&1 || error "$TARGET_DIR is not a git repository."
[ -d "$KIT_PATH" ] || error "Kit path not found: $KIT_PATH_INPUT"
[ -f "$MANIFEST_PATH" ] || error "Manifest not found: $MANIFEST_PATH"

echo -e "\n${BOLD}Linking ${INTEGRATION} integration${RESET}\n"
info "Project: $TARGET_DIR"
info "Kit: $KIT_PATH"
echo ""

export SPECKIT_LINK_INTEGRATION="$INTEGRATION"
export SPECKIT_LINK_KIT_PATH="$KIT_PATH"
export SPECKIT_LINK_KIT_PATH_INPUT="$KIT_PATH_INPUT"
export SPECKIT_LINK_TARGET_DIR="$TARGET_DIR"
export SPECKIT_LINK_MANIFEST_PATH="$MANIFEST_PATH"

"$PYTHON_BIN" <<'PY'
import datetime
import fnmatch
import json
import os
import shutil
import sys

integration = os.environ["SPECKIT_LINK_INTEGRATION"]
kit_root = os.environ["SPECKIT_LINK_KIT_PATH"]
kit_input = os.environ["SPECKIT_LINK_KIT_PATH_INPUT"]
target_root = os.environ["SPECKIT_LINK_TARGET_DIR"]
manifest_path = os.environ["SPECKIT_LINK_MANIFEST_PATH"]

with open(manifest_path, "r", encoding="utf-8") as fh:
    manifest = json.load(fh)

if manifest.get("integration") != integration:
    print(f"  ERR  Manifest integration '{manifest.get('integration')}' does not match '{integration}'", file=sys.stderr)
    sys.exit(1)

# Read project-tooling.json to honor consumer-declared preferences
tooling_path = os.path.join(target_root, ".specify", "project-tooling.json")
project_tooling = {}
if os.path.isfile(tooling_path):
    with open(tooling_path, "r", encoding="utf-8") as fh:
        project_tooling = json.load(fh)

spec_workflow = project_tooling.get("spec_workflow", True)

def log(prefix, message):
    print(f"  {prefix}  {message}")

def rel_link(source_abs, target_abs):
    return os.path.relpath(source_abs, os.path.dirname(target_abs))

def ensure_parent(path):
    parent = os.path.dirname(path)
    if parent:
        os.makedirs(parent, exist_ok=True)

def link_entry(source_abs, target_abs):
    ensure_parent(target_abs)
    expected = rel_link(source_abs, target_abs)

    if os.path.islink(target_abs):
        current = os.readlink(target_abs)
        if current == expected:
            log("OK", f"Link already correct: {os.path.relpath(target_abs, target_root)} -> {current}")
        else:
            log("!!", f"{os.path.relpath(target_abs, target_root)} already points to {current} — skipping")
        return

    if os.path.exists(target_abs):
        log("!!", f"{os.path.relpath(target_abs, target_root)} exists as a real path — skipping")
        return

    os.symlink(expected, target_abs)
    log("OK", f"Linked {os.path.relpath(target_abs, target_root)} -> {expected}")

def should_skip_child(child_name, rule):
    # Respect explicit spec_workflow: false — skip speckit.* assets unconditionally
    if not spec_workflow and fnmatch.fnmatch(child_name, "speckit.*"):
        return True
    for condition in rule.get("skip_patterns_unless_paths_exist", []):
        patterns = condition.get("patterns", [])
        required_paths = condition.get("paths", [])
        if not any(fnmatch.fnmatch(child_name, pattern) for pattern in patterns):
            continue
        if all(os.path.exists(os.path.join(target_root, path)) for path in required_paths):
            continue
        return True
    return False

for rule in manifest.get("links", []):
    mode = rule["mode"]
    source_abs = os.path.join(kit_root, rule["source"])
    target_abs = os.path.join(target_root, rule["target"])

    if not os.path.exists(source_abs):
        log("!!", f"Source missing for {rule['target']}: {rule['source']} — skipping")
        continue

    if mode == "link_dir":
        link_entry(source_abs, target_abs)
        continue

    if mode == "link_children":
        if os.path.islink(target_abs):
            log("!!", f"{rule['target']} is a symlink — skipping child linking")
            continue

        os.makedirs(target_abs, exist_ok=True)
        for child_name in sorted(os.listdir(source_abs)):
            if child_name.startswith("."):
                continue
            if should_skip_child(child_name, rule):
                log("!!", f"Skipping {os.path.join(rule['target'], child_name)} (requires additional speckit assets)")
                continue
            link_entry(
                os.path.join(source_abs, child_name),
                os.path.join(target_abs, child_name),
            )
        continue

    print(f"  ERR  Unsupported link mode: {mode}", file=sys.stderr)
    sys.exit(1)

for rule in manifest.get("copies", []):
    source_abs = os.path.join(kit_root, rule["source"])
    target_abs = os.path.join(target_root, rule["target"])

    if not os.path.exists(source_abs):
        log("!!", f"Copy source missing for {rule['target']}: {rule['source']} — skipping")
        continue

    if rule.get("if_missing", False) and (os.path.exists(target_abs) or os.path.islink(target_abs)):
        log("!!", f"{rule['target']} already exists — skipping")
        continue

    ensure_parent(target_abs)
    shutil.copy2(source_abs, target_abs)
    log("OK", f"Copied {rule['target']}")

integration_record = {
    "integration": integration,
    "version": manifest.get("version"),
    "kit_path": kit_input,
    "manifest_path": os.path.relpath(manifest_path, target_root),
    "linked_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
}

os.makedirs(os.path.join(target_root, ".specify"), exist_ok=True)
with open(os.path.join(target_root, ".specify", "integration.json"), "w", encoding="utf-8") as fh:
    json.dump(integration_record, fh, indent=2)
    fh.write("\n")

# Update project-tooling.json: merge ai_tool + ai_kit_path, preserve spec_workflow and other keys
project_tooling.setdefault("spec_workflow", True)
project_tooling["ai_tool"] = integration
project_tooling["ai_kit_path"] = kit_input
with open(tooling_path, "w", encoding="utf-8") as fh:
    json.dump(project_tooling, fh, indent=2)
    fh.write("\n")

log("OK", "Recorded active integration in .specify/integration.json")
log("OK", "Updated .specify/project-tooling.json")
PY

echo ""
success "Integration ready"
