# Task Prompt - Extract Intent

You extract a structured intent from a user message.

Output JSON conforming to:
```json
{
  "intent": "create | read | update | delete | unknown",
  "confidence": 0.0-1.0,
  "entity": "user | order | account | unknown",
  "params": { /* free-form key-value */ }
}
```

If unsure, set intent to "unknown" with low confidence rather than guessing.

Few-shot examples: `../few-shot/extract-intent.examples.json`
