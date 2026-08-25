"""Tests for env-derived Settings."""

from __future__ import annotations

import pytest


VALID_ENV = {
    "DATABASE_URL": "postgresql://user:pass@localhost:5432/db",
    "REDIS_URL": "redis://localhost:6379",
    "JWT_SECRET": "a" * 48,
    "SESSION_SECRET": "b" * 48,
    "CORS_ORIGINS": "http://localhost:3000",
}


def _import_settings(monkeypatch: pytest.MonkeyPatch, env: dict[str, str]) -> object:
    """Re-import the config module under a clean env."""
    import importlib
    for k, v in env.items():
        monkeypatch.setenv(k, v)
    import sys
    if "resume.config" in sys.modules:
        del sys.modules["resume.config"]
    return importlib.import_module("resume.config")


def test_valid_env_imports(monkeypatch: pytest.MonkeyPatch) -> None:
    mod = _import_settings(monkeypatch, VALID_ENV)
    assert mod.settings.database_url is not None
    assert mod.settings.llm_daily_budget_usd == 10.0


def test_short_jwt_rejected(monkeypatch: pytest.MonkeyPatch) -> None:
    env = {**VALID_ENV, "JWT_SECRET": "short"}
    with pytest.raises(Exception):
        _import_settings(monkeypatch, env)


def test_missing_database_url_rejected(monkeypatch: pytest.MonkeyPatch) -> None:
    env = {k: v for k, v in VALID_ENV.items() if k != "DATABASE_URL"}
    with pytest.raises(Exception):
        _import_settings(monkeypatch, env)
