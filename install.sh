#!/usr/bin/env bash
# install.sh — Bootstrap speckit-core as a git submodule in a target repository.
#
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/jwill824/speckit-core/main/install.sh) [TARGET_DIR]
#   or:  bash install.sh [TARGET_DIR]

set -euo pipefail

SPECKIT_REPO="https://github.com/jwill824/speckit-core.git"
SUBMODULE_PATH=".speckit"
TARGET_DIR="${1:-$(pwd)}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "  ${CYAN}->${RESET}  $*"; }
success() { echo -e "  ${GREEN}OK${RESET}  $*"; }
warn()    { echo -e "  ${YELLOW}!!${RESET}  $*"; }
error()   { echo -e "  ${RED}ERR${RESET}  $*" >&2; exit 1; }

require_command() {
  command -v "$1" >/dev/null 2>&1 || error "Missing required command: $1"
}

link_path() {
  local link_path="$1"
  local target_path="$2"
  local current_target

  mkdir -p "$(dirname "$link_path")"

  if [ -L "$link_path" ]; then
    current_target="$(readlink "$link_path" 2>/dev/null || true)"
    if [ "$current_target" = "$target_path" ]; then
      success "Link already correct: $link_path -> $target_path"
    else
      warn "$link_path already points to $current_target — skipping"
    fi
  elif [ -e "$link_path" ]; then
    warn "$link_path exists as a real path — skipping"
  else
    ln -s "$target_path" "$link_path"
    success "Linked $link_path -> $target_path"
  fi
}

link_child_entries() {
  local source_dir="$1"
  local destination_dir="$2"
  local relative_prefix="$3"
  local source_path
  local name

  [ -d "$source_dir" ] || return 0

  mkdir -p "$destination_dir"

  for source_path in "$source_dir"/*; do
    [ -e "$source_path" ] || continue
    name="$(basename "$source_path")"
    case "$name" in
      .*) continue ;;
    esac
    link_path "$destination_dir/$name" "$relative_prefix/$name"
  done
}

create_extensions_config() {
  local path=".specify/extensions.yml"
  local source_path=".speckit/.specify/extensions.yml"

  if [ -f "$path" ]; then
    warn "$path already exists — skipping"
    return
  fi

  if [ ! -f "$source_path" ]; then
    warn "$source_path not found — skipping"
    return
  fi

  cp "$source_path" "$path"

  success "Created $path"
}

create_project_tooling() {
  local path=".specify/project-tooling.json"

  if [ -f "$path" ]; then
    warn "$path already exists — skipping"
    return
  fi

  cat > "$path" <<'JSON'
{
  "spec_workflow": true,
  "ai_tool": null,
  "ai_kit_path": null
}
JSON
  success "Created $path"
}

create_memory_stub() {
  local path="$1"
  local label="$2"
  local fallback="$3"
  local template_path="$4"

  if [ -f "$path" ]; then
    warn "$path already exists — skipping"
    return
  fi

  {
    printf '%s\n\n' "$label"
    if [ -f "$template_path" ]; then
      cat "$template_path"
    else
      printf '%s\n' "$fallback"
    fi
  } > "$path"

  success "Created $path"
}

echo -e "\n${BOLD}speckit-core installer${RESET}\n"

require_command git

cd "$TARGET_DIR" || error "Cannot cd to $TARGET_DIR"
git rev-parse --git-dir >/dev/null 2>&1 || error "$TARGET_DIR is not a git repository."

if [ -e "$SUBMODULE_PATH" ] && ! git config --file .gitmodules "submodule.${SUBMODULE_PATH}.url" >/dev/null 2>&1; then
  error "$SUBMODULE_PATH exists but is not registered as a git submodule."
fi

echo -e "${BOLD}Target:${RESET} $(pwd)\n"

echo -e "${BOLD}Step 1: Submodule${RESET}"
if git config --file .gitmodules "submodule.${SUBMODULE_PATH}.url" >/dev/null 2>&1; then
  warn "$SUBMODULE_PATH already registered — updating"
  git submodule sync -- "$SUBMODULE_PATH"
  git submodule update --init --remote "$SUBMODULE_PATH"
else
  info "Adding $SPECKIT_REPO -> $SUBMODULE_PATH"
  git submodule add "$SPECKIT_REPO" "$SUBMODULE_PATH"
  git submodule update --init "$SUBMODULE_PATH"
fi
success "Submodule ready at $SUBMODULE_PATH/\n"

echo -e "${BOLD}Step 2: Core links${RESET}"
mkdir -p .specify
link_path ".specify/templates" "../.speckit/.specify/templates"
link_path ".specify/scripts" "../.speckit/.specify/scripts"
echo ""

echo -e "${BOLD}Step 3: Bundled extensions and integrations${RESET}"
mkdir -p .specify/extensions .specify/integrations
link_child_entries ".speckit/.specify/extensions" ".specify/extensions" "../../.speckit/.specify/extensions"
link_child_entries ".speckit/.specify/integrations" ".specify/integrations" "../../.speckit/.specify/integrations"
echo ""

echo -e "${BOLD}Step 4: Local config stubs${RESET}"
create_extensions_config
echo ""

echo -e "${BOLD}Step 5: Project tooling declaration${RESET}"
create_project_tooling
echo ""

echo -e "${BOLD}Step 6: Memory stubs${RESET}"
mkdir -p .specify/memory
create_memory_stub \
  ".specify/memory/constitution.md" \
  "<!-- Run /speckit.constitution to initialize this for your project -->" \
  "# [PROJECT_NAME] Constitution" \
  ".speckit/.specify/templates/constitution-template.md"
create_memory_stub \
  ".specify/memory/stack.md" \
  "<!-- Run /speckit.constitution to detect and populate your stack -->" \
  "# Project Stack" \
  ".speckit/.specify/templates/stack-template.md"
echo ""

echo -e "${BOLD}${GREEN}speckit-core installed${RESET}\n"
echo -e "  ${BOLD}Next:${RESET} edit ${CYAN}.specify/project-tooling.json${RESET} to declare your AI tool, then optionally pair with ${CYAN}copilot-kit${RESET} and run ${CYAN}/speckit.constitution${RESET}"
echo -e "  ${BOLD}Update later:${RESET} ${CYAN}git submodule update --remote .speckit${RESET}\n"
