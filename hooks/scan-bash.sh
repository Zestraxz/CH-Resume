#!/usr/bin/env bash
# PreToolUse hook - scan Bash invocations for dangerous patterns.
# Exits 1 to BLOCK the tool call if a dangerous pattern is detected.

set -euo pipefail

INPUT_JSON="${CLAUDE_TOOL_INPUT:-}"
[[ -z "$INPUT_JSON" ]] && exit 0

# Extract command field via jq if available, else crude parse
if command -v jq >/dev/null 2>&1; then
    CMD="$(echo "$INPUT_JSON" | jq -r '.command // empty')"
else
    CMD="$(echo "$INPUT_JSON" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed -E 's/.*"command"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')"
fi

[[ -z "$CMD" ]] && exit 0

DANGEROUS=(
    'rm[[:space:]]+-rf[[:space:]]+(/|\$HOME|~)[[:space:]]*$'
    'rm[[:space:]]+-rf[[:space:]]+/[^t]'  # not /tmp
    ':\(\)[[:space:]]*\{[[:space:]]*:[[:space:]]*\|[[:space:]]*:'
    'curl[[:space:]]+[^|]*\|[[:space:]]*(bash|sh|zsh)'
    'wget[[:space:]]+[^|]*\|[[:space:]]*(bash|sh|zsh)'
    'mkfs\.'
    'dd[[:space:]]+if=.*of=/dev/(sd|nvme|hd)'
    '>[[:space:]]*/dev/(sda|nvme|hda)'
    'chmod[[:space:]]+-R[[:space:]]+777[[:space:]]+/'
    'history[[:space:]]+-c'
    'sudo[[:space:]]+rm[[:space:]]+-rf'
)

for pat in "${DANGEROUS[@]}"; do
    if echo "$CMD" | grep -qE "$pat"; then
        echo "BLOCKED: dangerous bash pattern matched: $pat" >&2
        echo "Command: $CMD" >&2
        echo "If this is intentional, run it manually outside Claude." >&2
        exit 1
    fi
done

exit 0
