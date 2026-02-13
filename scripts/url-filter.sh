#!/bin/bash
# Git smudge/clean filter for local/remote URL switching.
#
# Usage (configured via git config):
#   git config filter.tbx-url.clean  'scripts/url-filter.sh clean'
#   git config filter.tbx-url.smudge 'scripts/url-filter.sh smudge'
#
# clean  — local file:// URLs → remote GitHub URLs (for commits)
# smudge — remote GitHub URLs → local file:// URLs (for checkout)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

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

# Build sed arguments for all tbx-* repos (this one + siblings)
sed_args=()
for dir in "$REPO_DIR"/../tbx-*/; do
  dir="$(cd "$dir" 2>/dev/null && pwd)" || continue
  [ -d "$dir/.git" ] || continue

  local_url="file://${dir}/"
  remote_url=$(derive_remote_url "$dir") || continue

  if [ "$1" = "clean" ]; then
    sed_args+=(-e "s|${local_url}|${remote_url}|g")
  elif [ "$1" = "smudge" ]; then
    sed_args+=(-e "s|${remote_url}|${local_url}|g")
  fi
done

case "$1" in
  clean|smudge)
    if [ ${#sed_args[@]} -gt 0 ]; then
      sed "${sed_args[@]}"
    else
      cat
    fi
    ;;
  *)
    echo "Usage: $0 {clean|smudge}" >&2
    exit 1
    ;;
esac
