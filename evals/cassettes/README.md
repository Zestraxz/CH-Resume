# VCR Cassettes

Snapshot recordings of real LLM responses. Used for deterministic eval replays.

## Recording

```python
import vcr

with vcr.use_cassette('cassettes/test_extraction.yaml'):
    response = llm_call(...)  # first run: real API; recorded
    # subsequent runs: replayed from cassette
```

## Updating

Delete the cassette file and re-run the test. New response gets recorded.

## Don't commit cassettes containing secrets

VCR filters by default but verify before committing.

## Reference

- Python: https://vcrpy.readthedocs.io
- Node: https://github.com/nock/nock
