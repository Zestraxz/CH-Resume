# 2. Architecture Constraints

| Type | Constraint | Origin |
|---|---|---|
| Technical | Node 20.18+ | `.nvmrc` |
| Technical | Python 3.11+ | `pyproject.toml` |
| Technical | Postgres 16+ | `docker-compose.yml` |
| Organisational | MIT license | `LICENSE` |
| Organisational | Conventional Commits | `commitlint.config.cjs` |
| Conventional | Lifecycle folders `01_setup` -> `05_archive` | ADR-0002 |
