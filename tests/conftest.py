"""Pytest shared fixtures and configuration.

Place fixtures used across tests here. Add directory-scoped conftest.py
files for narrower fixtures.
"""

from __future__ import annotations

import os

import pytest


# ---- Determinism ------------------------------------------------------------
os.environ.setdefault("TZ", "UTC")


@pytest.fixture(autouse=True)
def _seed_env(monkeypatch: pytest.MonkeyPatch) -> None:
    """Sanitize env per test — no provider keys, no real secrets leak."""
    for key in ("ANTHROPIC_API_KEY", "OPENAI_API_KEY", "GEMINI_API_KEY", "DEEPSEEK_API_KEY"):
        monkeypatch.setenv(key, "test-key-do-not-use")


# ---- Example fixture (delete once real ones exist) -------------------------
@pytest.fixture
def example_record() -> dict[str, str]:
    return {"id": "test-1", "name": "Example"}
