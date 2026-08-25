#!/usr/bin/env bash
#
# install.sh — port the Critic kit (Radar + Microscope) into any repository.
#
#   bash /path/to/CH-Critic/.Critic/install.sh /path/to/target-repo
#
# Idempotent: safe to re-run. Existing files are left alone unless --force is passed.
# Docs: .Critic/README.md · docs/04-quality/critic/SOP-AUTONOMOUS-SELF-CRITIC.md

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="."
FORCE=0
NO_WORKFLOW=0
DRY_RUN=0
DOCS_DIR="docs/04-quality/critic"

c_bold=$'\033[1m'; c_dim=$'\033[2m'; c_grn=$'\033[32m'; c_ylw=$'\033[33m'
c_red=$'\033[31m'; c_off=$'\033[0m'
[ -t 1 ] || { c_bold=""; c_dim=""; c_grn=""; c_ylw=""; c_red=""; c_off=""; }

say()  { printf '%s\n' "$*"; }
ok()   { printf '  %s✓%s %s\n' "$c_grn" "$c_off" "$*"; }
skip() { printf '  %s·%s %s %s(exists, kept)%s\n' "$c_dim" "$c_off" "$*" "$c_dim" "$c_off"; }
warn() { printf '  %s!%s %s\n' "$c_ylw" "$c_off" "$*"; }
die()  { printf '%serror:%s %s\n' "$c_red" "$c_off" "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Port the Critic kit (Radar + Microscope) into any repository.

USAGE
  install.sh [TARGET] [OPTIONS]

ARGUMENTS
  TARGET              Repo root to install into. Default: current directory.

OPTIONS
  --force             Overwrite existing .Critic/, launcher, and workflow.
                      Never overwrites the coverage map or ledger (they hold your history).
  --no-workflow       Skip the GitHub Actions workflow (non-GitHub remotes).
  --docs-dir DIR      Where to seed the coverage map + ledger.
                      Default: docs/04-quality/critic
  --dry-run           Print what would happen; change nothing.
  --print-schedule    Print the activation commands and exit.
  -h, --help          This help.

WHAT IT DOES
  1. copies .Critic/ into TARGET
  2. writes .claude/commands/critic.md          (the /critic launcher)
  3. seeds DOCS_DIR/COVERAGE.md + REFUTED-LEDGER.md
  4. installs .github/workflows/self-critic.yml (dormant until you add the secret)
  5. appends _runs/ to .gitignore

WHAT IT CANNOT DO FOR YOU
  * Edit the "Project binding" section at the bottom of .Critic/Critic-Radar.md.
    An unedited binding makes the Radar sweep the wrong surface.
  * Add the CLAUDE_CODE_OAUTH_TOKEN secret. Run --print-schedule for the commands.
EOF
}

print_schedule() {
  cat <<'EOF'
Activate the weekly Radar (subscription auth — no API credits):

  claude setup-token                    # requires a Claude subscription; prints a long-lived token
  gh secret set CLAUDE_CODE_OAUTH_TOKEN # or: Settings > Secrets and variables > Actions

Then PROVE it fires (an unfired scheduler is the failure this kit exists to prevent):

  gh workflow run self-critic.yml
  gh run list --workflow=self-critic.yml

Schedule: read it from .github/workflows/self-critic.yml — do not trust a value restated in prose.
GitHub honours `schedule:` on the DEFAULT BRANCH only, disables scheduled workflows after ~60 days
of repo inactivity, and may delay or drop top-of-hour schedules entirely — see SOP §4.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)        usage; exit 0 ;;
    --print-schedule) print_schedule; exit 0 ;;
    --force)          FORCE=1 ;;
    --no-workflow)    NO_WORKFLOW=1 ;;
    --dry-run)        DRY_RUN=1 ;;
    --docs-dir)       shift; [ $# -gt 0 ] || die "--docs-dir needs a value"; DOCS_DIR="$1" ;;
    -*)               die "unknown option: $1  (try --help)" ;;
    *)                TARGET="$1" ;;
  esac
  shift
done

[ -d "$TARGET" ] || die "target is not a directory: $TARGET"
TARGET="$(cd "$TARGET" && pwd)"
[ -f "$SRC/Critic-Radar.md" ] || die "source does not look like a .Critic folder: $SRC"
[ "$SRC" != "$TARGET/.Critic" ] || die "source and destination are the same folder"

REPO="$(basename "$TARGET")"
DATE="$(date -u +%Y-%m-%d)"
if git -C "$TARGET" rev-parse --git-dir >/dev/null 2>&1; then
  ORIGIN="$(git -C "$TARGET" remote get-url origin 2>/dev/null || echo '')"
  # sed ERE has no lazy quantifier, so strip the .git suffix first, then take owner/name.
  [ -n "$ORIGIN" ] && REPO="$(printf '%s' "$ORIGIN" \
    | sed -E -e 's#/+$##' -e 's#\.git$##' -e 's#^.*[:/]([^/]+/[^/]+)$#\1#')"
else
  warn "$TARGET is not a git repository — installing anyway, but the workflow needs a GitHub remote."
fi

say ""
say "${c_bold}Critic kit installer${c_off}"
say "  source  $SRC"
say "  target  $TARGET"
say "  repo    $REPO"
[ "$DRY_RUN" -eq 1 ] && say "  ${c_ylw}dry run — nothing will be written${c_off}"
say ""

run() { [ "$DRY_RUN" -eq 1 ] || "$@"; }

# Render a template, substituting the placeholders. Never clobbers an existing file:
# the coverage map and ledger accumulate history that must survive a re-run.
seed() {
  local tpl="$1" dest="$2"
  if [ -e "$dest" ]; then skip "$(basename "$dest")"; return; fi
  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$(dirname "$dest")"
    sed -e "s|{{PROJECT}}|$REPO|g" \
        -e "s|{{REPO}}|$REPO|g" \
        -e "s|{{DATE}}|$DATE|g" \
        -e "s|{{LAYER1}}|core|g" \
        -e "s|{{LAYER2}}|interface|g" \
        -e "s|{{LAYER3}}|ops|g" \
        "$tpl" > "$dest"
  fi
  ok "${dest#"$TARGET"/}"
}

# 1 — the kit itself
if [ -d "$TARGET/.Critic" ] && [ "$FORCE" -eq 0 ]; then
  skip ".Critic/  (use --force to overwrite)"
else
  run mkdir -p "$TARGET/.Critic"
  run cp -R "$SRC/." "$TARGET/.Critic/"
  ok ".Critic/"
fi

# 2 — the /critic launcher
LAUNCHER="$TARGET/.claude/commands/critic.md"
if [ -e "$LAUNCHER" ] && [ "$FORCE" -eq 0 ]; then
  skip ".claude/commands/critic.md"
else
  run mkdir -p "$TARGET/.claude/commands"
  run cp "$SRC/templates/critic.md" "$LAUNCHER"
  ok ".claude/commands/critic.md"
fi

# 3 — the Radar's memory and discipline
seed "$SRC/templates/COVERAGE.md"       "$TARGET/$DOCS_DIR/COVERAGE.md"
seed "$SRC/templates/REFUTED-LEDGER.md" "$TARGET/$DOCS_DIR/REFUTED-LEDGER.md"

# 4 — the scheduler
if [ "$NO_WORKFLOW" -eq 1 ]; then
  warn "workflow skipped (--no-workflow) — nothing will run the Radar on a schedule"
else
  WF="$TARGET/.github/workflows/self-critic.yml"
  if [ -e "$WF" ] && [ "$FORCE" -eq 0 ]; then
    skip ".github/workflows/self-critic.yml"
  else
    run mkdir -p "$TARGET/.github/workflows"
    run cp "$SRC/templates/self-critic.yml" "$WF"
    ok ".github/workflows/self-critic.yml  ${c_dim}(dormant until the secret is set)${c_off}"
  fi
fi

# 5 — git-ignore the per-pass scratch logs
GI="$TARGET/.gitignore"
if [ -f "$GI" ] && grep -qE '^_runs/?$' "$GI" 2>/dev/null; then
  skip "_runs/ already in .gitignore"
else
  if [ "$DRY_RUN" -eq 0 ]; then
    [ -f "$GI" ] && [ -n "$(tail -c1 "$GI" 2>/dev/null)" ] && printf '\n' >> "$GI"
    printf '\n# ---- Critic per-pass scratch logs -------------------------------------------\n_runs/\n' >> "$GI"
  fi
  ok "_runs/ -> .gitignore"
fi

# If the binding still names another project, the Radar will refuse to sweep (radar-prompt.md
# Step 0). Surfacing it here turns a confusing runtime abort into an obvious setup step.
BINDING_STALE=0
if [ -f "$TARGET/.Critic/Critic-Radar.md" ] &&
   grep -q '^## Project binding — CH-Critic' "$TARGET/.Critic/Critic-Radar.md" 2>/dev/null &&
   [ "$REPO" != "CH-Critic" ] && [ "${REPO##*/}" != "CH-Critic" ]; then
  BINDING_STALE=1
fi

say ""
say "${c_bold}Done.${c_off} Two steps remain — the installer cannot do either for you:"
say ""
if [ "$BINDING_STALE" -eq 1 ]; then
  say "  ${c_ylw}1. EDIT THE BINDING${c_off} — .Critic/Critic-Radar.md still says ${c_bold}CH-Critic${c_off}."
  say "     The Radar aborts with BINDING ERROR until it names ${c_bold}$REPO${c_off}."
else
  say "  ${c_ylw}1. EDIT THE BINDING${c_off} — the 'Project binding' section at the bottom of"
  say "     .Critic/Critic-Radar.md, plus the TODOs in $DOCS_DIR/COVERAGE.md."
fi
say "     Set: coverage-map/ledger/queue paths · real layer list · provability floor ·"
say "     the domain's validation authority (what the critic must NOT modify)."
say ""
say "  ${c_ylw}2. ACTIVATE THE SCHEDULE${c_off} — run: ${c_bold}$0 --print-schedule${c_off}"
say ""
say "  Then: ${c_bold}/critic${c_off} works immediately; the Radar runs weekly once step 2 is done."
say ""
