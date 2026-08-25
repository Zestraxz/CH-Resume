#!/usr/bin/env bash
# =============================================================================
# Resume — Full-stack startup (Unix)
# =============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

NO_OPEN=0
for arg in "$@"; do
    case "$arg" in --no-open) NO_OPEN=1 ;; esac
done

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
step() { printf "${CYAN}==> %s${NC}\n" "$1"; }
ok()   { printf "    ${GREEN}OK: %s${NC}\n" "$1"; }
warn() { printf "    ${YELLOW}WARN: %s${NC}\n" "$1"; }
fail() { printf "    ${RED}FAIL: %s${NC}\n" "$1"; }
has()  { command -v "$1" >/dev/null 2>&1; }

# ---- 1. Docker --------------------------------------------------------------
step "Checking Docker daemon"
if ! has docker; then fail "docker CLI not found. Install Docker Desktop / dockerd."; exit 1; fi
if ! docker info >/dev/null 2>&1; then fail "Docker daemon not running."; exit 1; fi
ok "Docker is running"

# ---- 2. .env ----------------------------------------------------------------
step "Checking .env"
if [ ! -f .env ] && [ -f .env.example ]; then
    cp .env.example .env; warn ".env created from .env.example"
fi
ok ".env present"

# ---- 3. Bring up services ---------------------------------------------------
step "docker compose up -d --build"
docker compose up -d --build
ok "Services started"

# ---- 4. Healthchecks --------------------------------------------------------
step "Waiting for services"

wait_for() {
    local name="$1"; local cmd="$2"; local timeout="${3:-60}"
    local deadline=$(( $(date +%s) + timeout ))
    while [ $(date +%s) -lt $deadline ]; do
        if eval "$cmd" >/dev/null 2>&1; then ok "$name healthy"; return 0; fi
        sleep 2
    done
    warn "$name did not become healthy within ${timeout}s"
    return 1
}

wait_for "postgres" "docker compose exec -T postgres pg_isready"
wait_for "redis"    "docker compose exec -T redis redis-cli ping | grep -q PONG"
wait_for "api"      "curl -fsS http://localhost:8000/health" 30 || true

# ---- 5. Open browser --------------------------------------------------------
if [ $NO_OPEN -eq 0 ]; then
    step "Opening browser"
    if   has xdg-open; then xdg-open "http://localhost:3000" >/dev/null 2>&1 &
    elif has open;     then open "http://localhost:3000"
    fi
fi

# ---- Done -------------------------------------------------------------------
echo
printf "${GREEN}============================================================${NC}\n"
printf "${GREEN} Resume is up.${NC}\n"
printf "${GREEN}============================================================${NC}\n"
echo
echo " Frontend: http://localhost:3000"
echo " API:      http://localhost:8000"
echo " API docs: http://localhost:8000/docs"
echo
echo " Stop with:  docker compose down"
echo " Logs:       docker compose logs -f"
echo
