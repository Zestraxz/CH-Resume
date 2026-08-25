#!/usr/bin/env bash
# =============================================================================
# Resume — Unix bootstrap
# =============================================================================
# Idempotent setup script. Checks prerequisites, creates .env, installs deps,
# brings up services. Safe to re-run.
#
# Usage:
#   ./01_setup/run.sh                  # full bootstrap
#   ./01_setup/run.sh --skip-deps      # skip pnpm install / pip install
#   ./01_setup/run.sh --skip-docker    # skip docker compose up
#   ./01_setup/run.sh --open-browser   # open app after ready
# =============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

SKIP_DEPS=0
SKIP_DOCKER=0
OPEN_BROWSER=0

for arg in "$@"; do
    case "$arg" in
        --skip-deps)     SKIP_DEPS=1 ;;
        --skip-docker)   SKIP_DOCKER=1 ;;
        --open-browser)  OPEN_BROWSER=1 ;;
        --help|-h)
            sed -n '4,15p' "$0"; exit 0 ;;
    esac
done

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
step() { printf "${CYAN}==> %s${NC}\n" "$1"; }
ok()   { printf "    ${GREEN}OK: %s${NC}\n" "$1"; }
warn() { printf "    ${YELLOW}WARN: %s${NC}\n" "$1"; }
fail() { printf "    ${RED}FAIL: %s${NC}\n" "$1"; }

has() { command -v "$1" >/dev/null 2>&1; }

# ---- 1. Prerequisites -------------------------------------------------------
step "Checking prerequisites"
missing=()
has git || missing+=("git")
has docker || missing+=("docker")
if [ -f package.json ]; then
    has node || missing+=("node")
    has pnpm || missing+=("pnpm")
fi
if [ -f pyproject.toml ]; then
    has python3 || has python || missing+=("python")
fi

if [ ${#missing[@]} -gt 0 ]; then
    fail "Missing prerequisites: ${missing[*]}"
    echo
    echo "Install instructions:"
    echo "  - Node + pnpm: https://nodejs.org and 'npm install -g pnpm'"
    echo "  - Python:      https://python.org"
    echo "  - Docker:      https://docker.com/products/docker-desktop"
    exit 1
fi
ok "All prerequisites present"

# ---- 2. .env ----------------------------------------------------------------
step "Checking .env"
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        warn ".env created from .env.example — edit it before deploying to prod"
    else
        warn "No .env.example found — skipping"
    fi
else
    ok ".env present"
fi

# ---- 3. Dependencies --------------------------------------------------------
if [ $SKIP_DEPS -eq 0 ]; then
    if [ -f package.json ]; then
        step "Installing Node dependencies (pnpm install)"
        pnpm install
        ok "Node deps installed"
    fi
    if [ -f pyproject.toml ]; then
        step "Installing Python dependencies"
        if has python3; then PY=python3; else PY=python; fi
        $PY -m pip install -e ".[dev]"
        ok "Python deps installed"
    fi
else
    warn "Skipping dependency install (--skip-deps)"
fi

# ---- 4. Docker --------------------------------------------------------------
if [ $SKIP_DOCKER -eq 0 ] && [ -f docker-compose.yml ]; then
    step "Checking Docker daemon"
    if ! docker info >/dev/null 2>&1; then
        fail "Docker daemon not running. Start Docker Desktop / dockerd and retry."
        exit 1
    fi
    ok "Docker is running"

    step "Bringing up services (docker compose up -d)"
    docker compose up -d
    ok "Services up"
else
    [ $SKIP_DOCKER -eq 1 ] && warn "Skipping Docker (--skip-docker)"
fi

# ---- 5. Open browser --------------------------------------------------------
if [ $OPEN_BROWSER -eq 1 ]; then
    step "Opening app in browser"
    if has xdg-open; then
        xdg-open "http://localhost:3000" >/dev/null 2>&1 &
    elif has open; then
        open "http://localhost:3000"
    fi
fi

# ---- Done -------------------------------------------------------------------
echo
printf "${GREEN}============================================================${NC}\n"
printf "${GREEN} Resume is ready.${NC}\n"
printf "${GREEN}============================================================${NC}\n"
echo
echo " App:      http://localhost:3000"
echo " API:      http://localhost:8000"
echo " API docs: http://localhost:8000/docs"
echo
echo " Next:"
echo "   - Read STATUS.md  (current phase)"
echo "   - Read CLAUDE.md  (AI workflow conventions)"
echo "   - pnpm dev        (start dev server, if not Docker)"
echo
