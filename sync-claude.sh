# CLAUDE.md Sync Script
# Syncs a profile markdown file from this repo to ~/.claude/CLAUDE.md
# Usage: ./sync-claude.sh [--dry-run] [profile]
#   - Defaults to ./CLAUDE.md (coding guidelines)
#   - With an arg, picks a profile by fuzzy/substring match (e.g. "acad" -> academic.md)
#   - Prompts for override if ~/.claude/CLAUDE.md already exists
#   - With --dry-run, prints what would happen without copying or prompting
#   - Side effects: overwrites ~/.claude/CLAUDE.md after confirmation
#   - Requires: bash, cp

set -euo pipefail

CONFIG_SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DEST_DIR="$HOME/.claude"
CONFIG_DEST_FILE="$CONFIG_DEST_DIR/CLAUDE.md"
CONFIG_DEFAULT_PROFILE="CLAUDE"

dry_run=0
choice=""
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    -*) echo "Error: Unknown option '$arg'" >&2; exit 1 ;;
    *) choice="$arg" ;;
  esac
done

profiles=()
for f in "$CONFIG_SRC_DIR"/*.md; do
  [ -f "$f" ] || continue
  name=$(basename "$f" .md)
  if [ "$name" != "README" ]; then
    profiles+=("$name")
  fi
done

if [ ${#profiles[@]} -eq 0 ]; then
  echo "Error: No profile .md files found." >&2
  echo "Checked: $CONFIG_SRC_DIR/*.md" >&2
  exit 1
fi

# No profile given: default to CLAUDE.md if present, otherwise list and prompt.
if [ -z "$choice" ]; then
  if printf '%s\n' "${profiles[@]}" | grep -qx "$CONFIG_DEFAULT_PROFILE"; then
    choice="$CONFIG_DEFAULT_PROFILE"
    echo "Defaulted to: $CONFIG_DEFAULT_PROFILE.md"
  else
    echo "Available profiles:"
    for f in "${profiles[@]}"; do
      echo "  $f.md"
    done
    if [ -t 0 ]; then
      printf "Choose one: "
      read -r choice
    else
      echo "Error: No profile given and stdin is not a terminal." >&2
      exit 1
    fi
  fi
fi

# Fuzzy/substring match against the requested name.
matches=()
for f in "${profiles[@]}"; do
  case "$f" in
    *"$choice"*) matches+=("$f") ;;
  esac
done

if [ ${#matches[@]} -eq 0 ]; then
  echo "Error: No profile matches '$choice'. Available: ${profiles[*]}" >&2
  exit 1
fi

if [ ${#matches[@]} -gt 1 ]; then
  echo "Multiple matches for '$choice':"
  if [ -t 0 ]; then
    for i in "${!matches[@]}"; do
      echo "  $((i+1)). ${matches[$i]}.md"
    done
    printf "Pick a number: "
    read -r idx
    if ! [ "$idx" -ge 1 ] 2>/dev/null || [ "$idx" -gt "${#matches[@]}" ]; then
      echo "Error: Invalid selection '$idx'." >&2
      exit 1
    fi
    choice="${matches[$((idx-1))]}"
  else
    echo "Error: Ambiguous input '$choice' and stdin is not a terminal." >&2
    exit 1
  fi
else
  choice="${matches[0]}"
fi

src_file="$CONFIG_SRC_DIR/$choice.md"

if [ "$dry_run" -eq 1 ]; then
  echo "[dry-run] Would copy $choice.md -> $CONFIG_DEST_FILE"
  if [ -f "$CONFIG_DEST_FILE" ]; then
    echo "[dry-run] Existing file would be overwritten: $CONFIG_DEST_FILE"
  fi
  exit 0
fi

mkdir -p "$CONFIG_DEST_DIR"

if [ -f "$CONFIG_DEST_FILE" ]; then
  echo "File already exists: $CONFIG_DEST_FILE"
  if [ -t 0 ]; then
    read -p "Override? (y/N): " confirm
    case "$confirm" in
      [yY]|[yY][eE][sS]) ;;
      *)
        echo "Aborted."
        exit 0
        ;;
    esac
  else
    echo "Error: Destination exists and stdin is not a terminal." >&2
    exit 1
  fi
fi

cp "$src_file" "$CONFIG_DEST_FILE"
echo "Done. Copied $choice.md -> $CONFIG_DEST_FILE"
