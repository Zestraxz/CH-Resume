#!/usr/bin/env bash
# =============================================================================
# Safe git push — runs lint/test/typecheck gate before pushing.
# =============================================================================
# Usage:
#   ./04_tools/GitPush.sh -m "feat(api): add endpoint" -f apps/api/src/routes/x.ts apps/api/tests/x.test.ts
#   ./04_tools/GitPush.sh -m "..." --no-test
#   ./04_tools/GitPush.sh -m "..." --dry-run
# =============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

MESSAGE=""
FILES=()
NO_TEST=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        -m|--message) MESSAGE="$2"; shift 2 ;;
        -f|--files)   shift; while [[ $# -gt 0 && "$1" != -* ]]; do FILES+=("$1"); shift; done ;;
        --no-test)    NO_TEST=1; shift ;;
        --dry-run)    DRY_RUN=1; shift ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
step() { printf "${CYAN}==> %s${NC}\n" "$1"; }
ok()   { printf "    ${GREEN}OK: %s${NC}\n" "$1"; }
fail() { printf "    ${RED}FAIL: %s${NC}\n" "$1"; }

if [[ -z "$MESSAGE" ]]; then fail "Commit message required (-m)"; exit 1; fi

# ---- 1. Sanity --------------------------------------------------------------
step "Sanity check"

for f in "${FILES[@]:-}"; do
    base="$(basename "$f")"
    if [[ "$base" == ".env" || "$base" == "credentials.json" || "$base" == "secrets.json" ]]; then
        fail "Refusing to commit forbidden file: $f"
        exit 1
    fi
done

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
echo "    Branch: $BRANCH"
if [[ "$BRANCH" =~ ^(main|master|production)$ ]]; then
    printf "${YELLOW}    ⚠  Pushing to a protected branch. Confirm? [y/N] ${NC}"
    read -r ans
    if [[ "$ans" != "y" && "$ans" != "Y" ]]; then echo "Aborted."; exit 1; fi
fi

# ---- 2. List modified ------------------------------------------------------
if [[ ${#FILES[@]} -eq 0 ]]; then
    step "Modified files (none specified — listing for confirmation)"
    git status --short
    echo
    printf "${YELLOW}Re-run with -f <space-separated-files> to stage specific files.${NC}\n"
    exit 0
fi

# ---- 3. Precommit gate -----------------------------------------------------
step "Running precommit gate"

run_step() {
    local name="$1"; local cmd="$2"
    if [[ $DRY_RUN -eq 1 ]]; then
        printf "${YELLOW}    DRY-RUN: would run %s${NC}\n" "$cmd"
    else
        echo "    -> $cmd"
        eval "$cmd" || { fail "$name failed. Fix before pushing."; exit 1; }
    fi
}

run_step format "pnpm format"
run_step lint "pnpm lint"
run_step typecheck "pnpm typecheck"
if [[ $NO_TEST -eq 0 ]]; then run_step test "pnpm test"; fi

ok "Precommit gate passed"

# ---- 4. Stage --------------------------------------------------------------
step "Staging files"
for f in "${FILES[@]}"; do
    if [[ $DRY_RUN -eq 1 ]]; then
        printf "${YELLOW}    DRY-RUN: would git add %s${NC}\n" "$f"
    else
        git add "$f"; echo "    + $f"
    fi
done

# ---- 5. Commit -------------------------------------------------------------
step "Committing"
if [[ $DRY_RUN -eq 1 ]]; then
    printf "${YELLOW}    DRY-RUN: would git commit -m '%s'${NC}\n" "$MESSAGE"
else
    git commit -m "$MESSAGE"; ok "Committed"
fi

# ---- 6. Push ---------------------------------------------------------------
step "Pushing"
if [[ $DRY_RUN -eq 1 ]]; then
    printf "${YELLOW}    DRY-RUN: would git push${NC}\n"
else
    git push; ok "Pushed"
fi

echo
printf "${GREEN}Done.${NC}\n"
