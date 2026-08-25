"""Shared eval fixtures + budget gate."""

from __future__ import annotations

import os

import pytest


@pytest.fixture(scope="session", autouse=True)
def _check_eval_budget() -> None:
    """Sanity-check: don't run evals if no budget is set (avoid runaway cost)."""
    budget = os.environ.get("LLM_DAILY_BUDGET_USD", "")
    if not budget:
        pytest.skip("evals skipped: set LLM_DAILY_BUDGET_USD env var to run")


@pytest.fixture
def llm_judge_threshold() -> float:
    """Minimum similarity / quality score for LLM-as-judge assertions."""
    return 0.80
