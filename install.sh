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

info()    { echo -e "  ${CYAN}→${RESET}  $*"; }
success() { echo -e "  ${GREEN}✓${RESET}  $*"; }
warn()    { echo -e "  ${YELLOW}⚠${RESET}  $*"; }
error()   { echo -e "  ${RED}✗${RESET}  $*" >&2; exit 1; }

echo -e "\n${BOLD}🔧 speckit-core installer${RESET}\n"

cd "$TARGET_DIR" || error "Cannot cd to $TARGET_DIR"
git rev-parse --git-dir &>/dev/null || error "$TARGET_DIR is not a git repository."

echo -e "${BOLD}Target:${RESET} $(pwd)\n"

# ── 1. Submodule ───────────────────────────────────────────────────────────────
echo -e "${BOLD}Step 1: Submodule${RESET}"
if git config --file .gitmodules "submodule.${SUBMODULE_PATH}.url" &>/dev/null 2>&1; then
  warn ".speckit submodule already registered — updating"
  git submodule update --init --remote "$SUBMODULE_PATH"
else
  info "Adding $SPECKIT_REPO → $SUBMODULE_PATH"
  git submodule add "$SPECKIT_REPO" "$SUBMODULE_PATH"
  git submodule update --init "$SUBMODULE_PATH"
fi
success "Submodule ready at .speckit/\n"

# ── 2. Symlinks ────────────────────────────────────────────────────────────────
echo -e "${BOLD}Step 2: Symlinks${RESET}"
mkdir -p .specify

declare -A LINKS=(
  [".specify/templates"]="../.speckit/.specify/templates"
  [".specify/scripts"]="../.speckit/.specify/scripts"
)

for link in "${!LINKS[@]}"; do
  target="${LINKS[$link]}"
  if [ -L "$link" ]; then
    warn "$link already exists — skipping"
  elif [ -e "$link" ]; then
    warn "$link exists as real path — skipping"
  else
    ln -s "$target" "$link"
    success "Linked $link → $target"
  fi
done
echo ""

# ── 3. Memory stubs ────────────────────────────────────────────────────────────
echo -e "${BOLD}Step 3: Memory stubs${RESET}"
mkdir -p .specify/memory

_stub() {
  local path="$1" label="$2"; shift 2
  if [ -f "$path" ]; then warn "$path already exists — skipping"
  else printf '%s\n' "$@" > "$path" && success "Created $path  ($label)"; fi
}

_stub ".specify/memory/constitution.md" "fill via /speckit.constitution" \
  "<!-- Run /speckit.constitution to initialize this for your project -->" "" \
  "$(cat .speckit/.specify/templates/constitution-template.md 2>/dev/null || echo '# [PROJECT_NAME] Constitution')"

_stub ".specify/memory/stack.md" "fill via /speckit.constitution" \
  "<!-- Run /speckit.constitution to detect and populate your stack -->" "" \
  "$(cat .speckit/.specify/templates/stack-template.md 2>/dev/null || echo '# Project Stack')"

echo ""
echo -e "${BOLD}${GREEN}✅  speckit-core installed!${RESET}\n"
echo -e "  ${BOLD}Next:${RESET} pair with ${CYAN}copilot-kit${RESET} or another tool kit, then run ${CYAN}/speckit.constitution${RESET}"
echo -e "  ${BOLD}Update later:${RESET} ${CYAN}git submodule update --remote .speckit${RESET}\n"
