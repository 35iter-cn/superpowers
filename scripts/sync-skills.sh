#!/usr/bin/env bash
#
# sync-skills.sh — one-click link/unlink superpowers skills to omp agent directory.
#
# Usage:
#   sync-skills.sh link              Create symlinks for all skills
#   sync-skills.sh unlink            Remove symlinks pointing to this repo's skills
#   sync-skills.sh link --dry-run    Preview what link would do
#   sync-skills.sh unlink --dry-run  Preview what unlink would do
#

set -euo pipefail

# ─── Configuration ───────────────────────────────────────────────────────────

TARGET_DIR="${HOME}/.omp/agent/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "${SCRIPT_DIR}/../skills" && pwd)"

DRY_RUN=false
COMMAND=""

# ─── Helpers ─────────────────────────────────────────────────────────────────

log() {
  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN] $*"
  else
    echo "$*"
  fi
}

err() {
  echo "ERROR: $*" >&2
}

die() {
  err "$*"
  exit 1
}

usage() {
  sed -n '2,9p' "$0" | sed 's/^# //'
  exit 1
}

# Resolve a symlink to its absolute path
resolve_link() {
  local path="$1"
  if [[ -L "$path" ]]; then
    readlink -f "$path"
  else
    echo ""
  fi
}

# ─── Argument Parsing ────────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
  usage
fi

COMMAND="$1"
shift

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    -h|--help)
      usage
      ;;
    *)
      die "Unknown option: $arg"
      ;;
  esac
done

case "$COMMAND" in
  link|unlink) ;;
  *) die "Unknown command: $COMMAND. Expected 'link' or 'unlink'." ;;
esac

# ─── Validation ──────────────────────────────────────────────────────────────

if [[ ! -d "$SOURCE_DIR" ]]; then
  die "Source skills directory not found: $SOURCE_DIR"
fi

# Ensure target directory exists (create only in non-dry-run, but show intent in dry-run)
if [[ ! -d "$TARGET_DIR" ]]; then
  if [[ "$DRY_RUN" == true ]]; then
    log "Would create target directory: $TARGET_DIR"
  else
    mkdir -p "$TARGET_DIR" || die "Failed to create target directory: $TARGET_DIR"
  fi
fi

# ─── Link Command ────────────────────────────────────────────────────────────

run_link() {
  local linked=0 skipped=0 failed=0

  for skill_dir in "$SOURCE_DIR"/*/; do
    [[ -d "$skill_dir" ]] || continue

    local skill_name
    skill_name="$(basename "$skill_dir")"
    local target_path="${TARGET_DIR}/${skill_name}"
    local expected_target="${SOURCE_DIR}/${skill_name}"

    if [[ -L "$target_path" ]]; then
      local current_target
      current_target="$(resolve_link "$target_path")"
      if [[ "$current_target" == "$expected_target" ]]; then
        log "SKIP    ${skill_name} (already linked)"
        ((skipped++)) || true
        continue
      else
        die "CONFLICT: ${target_path} exists and points to ${current_target}, not ${expected_target}. Aborting."
      fi
    elif [[ -e "$target_path" ]]; then
      die "CONFLICT: ${target_path} exists but is not a symlink. Aborting."
    fi

    log "LINK    ${skill_name}  →  ${target_path}"
    if [[ "$DRY_RUN" == false ]]; then
      if ln -s "$expected_target" "$target_path"; then
        ((linked++)) || true
      else
        err "Failed to link ${skill_name}"
        ((failed++)) || true
      fi
    else
      ((linked++)) || true
    fi
  done

  echo ""
  echo "Summary: ${linked} linked, ${skipped} skipped, ${failed} failed"
}

# ─── Unlink Command ──────────────────────────────────────────────────────────

run_unlink() {
  local removed=0 skipped=0

  for skill_dir in "$SOURCE_DIR"/*/; do
    [[ -d "$skill_dir" ]] || continue

    local skill_name
    skill_name="$(basename "$skill_dir")"
    local target_path="${TARGET_DIR}/${skill_name}"
    local expected_target="${SOURCE_DIR}/${skill_name}"

    if [[ ! -L "$target_path" ]]; then
      log "SKIP    ${skill_name} (not a symlink or does not exist)"
      ((skipped++)) || true
      continue
    fi

    local current_target
    current_target="$(resolve_link "$target_path")"

    if [[ "$current_target" != "$expected_target" ]]; then
      log "SKIP    ${skill_name} (points elsewhere: ${current_target})"
      ((skipped++)) || true
      continue
    fi

    log "UNLINK  ${skill_name}  ←  ${target_path}"
    if [[ "$DRY_RUN" == false ]]; then
      rm "$target_path"
    fi
    ((removed++)) || true
  done

  echo ""
  echo "Summary: ${removed} removed, ${skipped} skipped"
}

# ─── Main ────────────────────────────────────────────────────────────────────

case "$COMMAND" in
  link)
    run_link
    ;;
  unlink)
    run_unlink
    ;;
esac
