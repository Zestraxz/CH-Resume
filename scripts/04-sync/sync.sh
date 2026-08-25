#!/usr/bin/env bash
# =============================================================================
# Sync project AI config with live ~/.claude/
# =============================================================================
# Usage:
#   ./scripts/04-sync/sync.sh                       # Push (project → live)
#   ./scripts/04-sync/sync.sh --direction pull
#   ./scripts/04-sync/sync.sh --direction both
#   ./scripts/04-sync/sync.sh --items agents,skills,commands,hooks
#   ./scripts/04-sync/sync.sh --dry-run
# =============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LIVE_ROOT="${HOME}/.claude"

DIRECTION="push"
ITEMS=("agents" "skills" "commands" "rules")
DRY_RUN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --direction) DIRECTION="$2"; shift 2 ;;
        --items)     IFS=',' read -ra ITEMS <<< "$2"; shift 2 ;;
        --dry-run)   DRY_RUN=1; shift ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

[ -d "$LIVE_ROOT" ] || { echo "Live ~/.claude not found at $LIVE_ROOT"; exit 1; }

RSYNC_OPTS=(--archive --update --exclude='.git' --exclude='node_modules' --exclude='*.bak.*' --exclude='.DS_Store' --exclude='Thumbs.db')
[ $DRY_RUN -eq 1 ] && RSYNC_OPTS+=("--dry-run" "--itemize-changes")

sync_folder() {
    local src="$1" dst="$2" label="$3"
    if [ ! -d "$src" ]; then echo "  [$label] $src — skip (not present)"; return; fi
    mkdir -p "$dst"
    echo "  [$label] $src/ -> $dst/"
    rsync "${RSYNC_OPTS[@]}" "$src/" "$dst/"
}

for item in "${ITEMS[@]}"; do
    project_path="$PROJECT_ROOT/$item"
    live_path="$LIVE_ROOT/$item"
    case "$DIRECTION" in
        push) sync_folder "$project_path" "$live_path" "Push:$item" ;;
        pull) sync_folder "$live_path" "$project_path" "Pull:$item" ;;
        both)
            sync_folder "$project_path" "$live_path" "Push:$item"
            sync_folder "$live_path" "$project_path" "Pull:$item"
            ;;
    esac
done

echo
echo "Sync complete ($DIRECTION)."
