#!/bin/bash
# Switch install.tbxc between local and remote modes.
#
# Usage:
#   scripts/set-mode.sh local    # Use local files (for testing)
#   scripts/set-mode.sh remote   # Use GitHub URLs (for distribution)
#
# Automatically discovers sibling repos and switches
# their URLs in install.tbxc as well.

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL="${REPO_DIR}/install.tbxc"
LOCAL_URL="file://${REPO_DIR}/"

# Derive raw GitHub URL for a given git repo directory
derive_remote_url() {
  local dir="$1"
  local origin branch
  origin=$(git -C "$dir" remote get-url origin 2>/dev/null) || return 1
  origin="${origin%.git}"
  origin="${origin#https://github.com/}"
  origin="${origin#git@github.com:}"
  branch=$(git -C "$dir" branch --show-current 2>/dev/null)
  branch="${branch:-main}"
  echo "https://raw.githubusercontent.com/${origin}/${branch}/"
}

REMOTE_URL=$(derive_remote_url "$REPO_DIR")
if [ -z "$REMOTE_URL" ]; then
  echo "Error: no git remote 'origin' found." >&2
  exit 1
fi

# Switch a single repo's URL in install.tbxc.
# Returns 1 if the URL was not found in the file.
switch_url() {
  local dir="$1" mode="$2"
  local local_url="file://${dir}/"
  local remote_url
  remote_url=$(derive_remote_url "$dir") || return 1

  if [ "$mode" = "local" ]; then
    grep -q "$remote_url" "$INSTALL" || return 1
    sed -i '' "s|${remote_url}|${local_url}|" "$INSTALL"
  else
    grep -q "$local_url" "$INSTALL" || return 1
    sed -i '' "s|${local_url}|${remote_url}|" "$INSTALL"
  fi
}

case "$1" in
  local|remote)
    # Switch this repo's URL
    switch_url "$REPO_DIR" "$1"

    # Switch any sibling dependency URLs found in install.tbxc
    for dep_dir in "$REPO_DIR"/../*/; do
      dep_dir="$(cd "$dep_dir" 2>/dev/null && pwd)" || continue
      [ "$dep_dir" = "$REPO_DIR" ] && continue
      [ -d "$dep_dir/.git" ] || continue
      switch_url "$dep_dir" "$1" && echo "  Switched dependency: $(basename "$dep_dir")"
    done

    if [ "$1" = "local" ]; then
      echo "Switched to LOCAL mode."
      echo ""
      echo "Test stamp:"
      echo "  action(runCommand(\"curl -s ${LOCAL_URL}install.tbxc\"));"
    else
      echo "Switched to REMOTE mode."
      echo ""
      echo "Install stamp:"
      echo "  action(runCommand(\"curl -s ${REMOTE_URL}install.tbxc\"));"
    fi
    ;;
  *)
    echo "Usage: $0 {local|remote}"
    exit 1
    ;;
esac
