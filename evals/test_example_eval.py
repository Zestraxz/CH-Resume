"""Example LLM eval.

Replace with real evals as you ship features that depend on LLM output.
Run: `pytest evals/ -m eval`
"""

from __future__ import annotations

import pytest

pytestmark = pytest.mark.eval


def test_structured_output_matches_schema() -> None:
    """LLM output must satisfy declared schema.

    This is the cheapest eval: structural validation. Catches schema drift fast.
    """
    # Arrange: simulate an LLM call (replace with real call to your LLM wrapper)
    output = {"intent": "create", "confidence": 0.92, "entity": "user"}

    # Assert: schema
    assert isinstance(output, dict)
    assert "intent" in output and output["intent"] in {"create", "read", "update", "delete"}
    assert isinstance(output["confidence"], float) and 0.0 <= output["confidence"] <= 1.0
    assert "entity" in output


def test_high_confidence_intent_is_useful() -> None:
    """Semantic check: high-confidence outputs should produce useful intents."""
    output = {"intent": "create", "confidence": 0.92, "entity": "user"}
    if output["confidence"] > 0.8:
        assert output["intent"] != "unknown"
