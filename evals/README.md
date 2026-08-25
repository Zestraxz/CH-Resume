# evals/ - LLM Evaluations

> If your project uses LLMs at runtime, the prompts and outputs need tests.
> "Vibes-based" is 2024 thinking. Top 1% AI-native repos ship evals as code.

---

## What lives here

- **`test_*_eval.py`** - pytest-evals: minimal pytest-based eval harness. Asserts LLM outputs satisfy structural + semantic criteria.
- **`promptfooconfig.yaml`** - promptfoo: declarative prompt comparison (standard profile only).
- **`cassettes/`** - VCR-recorded LLM responses for deterministic snapshot tests (standard profile only).
- **`conftest.py`** - shared pytest fixtures.

## Running

```bash
# Python (pytest-evals)
pytest evals/

# Or via promptfoo (standard profile)
npx promptfoo eval -c evals/promptfooconfig.yaml
```

## CI gating

By default, evals are NOT a CI blocker (they're probabilistic). Promote to required-check once your eval set is stable and you trust the failure modes.

Wire-in:
```yaml
# .github/workflows/ci.yml
- name: Eval
  run: pytest evals/ -m "not slow"
  continue-on-error: true  # remove when stable
```

## Adding a new eval

1. Create `evals/test_<feature>_eval.py`.
2. Use the `@pytest.mark.eval` decorator.
3. Compare LLM output to expected structure (`assert isinstance(x, MySchema)`) AND semantic criteria (LLM-as-judge or semantic similarity).
4. Add real-world failure cases to the eval set as you find them - the set grows with production usage.

## Don't

- Don't use evals for unit-level testing (that's `tests/unit/`).
- Don't make evals depend on real API keys in CI without a budget cap.
- Don't make evals the only quality gate - schema validation + integration tests catch structural bugs faster.

## Further reading

- pydantic-evals: https://github.com/pydantic/pydantic-ai/tree/main/pydantic_evals
- promptfoo: https://promptfoo.dev
- DeepEval: https://github.com/confident-ai/deepeval
- RAGAS (RAG-specific): https://github.com/explodinggradients/ragas
