# prompts/

> Raw LLM prompt files. Source-of-truth for prompts that ship in your code.

---

## Why a separate folder

Inline prompts buried in code rot quickly. When the prompt is in code:
- Reviewers don't focus on it during PR review (it's "just a string")
- A/B testing different prompts means editing code in multiple places
- Evals can't easily snapshot vs the live prompt

`prompts/` makes the prompt a first-class artifact: one file per prompt, versioned, diff-able.

## Layout

```
prompts/
├── system/             # System prompts (persona, rules)
│   └── critic.md
├── task/               # Task-specific prompts
│   └── extract-intent.md
├── few-shot/           # Few-shot examples paired with task prompts
│   └── extract-intent.examples.json
└── README.md
```

## Pattern

```typescript
// In code - load from disk; never inline
import { readFileSync } from 'fs';
const criticPrompt = readFileSync('prompts/system/critic.md', 'utf-8');
const response = await claude.messages.create({
  system: criticPrompt,
  // ...
});
```

## When to add a new prompt

- Any LLM call that runs at runtime
- Any prompt longer than 3 lines
- Any prompt that benefits from version control (most do)

## Don't put here

- One-off chat-with-Claude prompts (those live in your terminal history)
- Prompt fragments shorter than a sentence
- Heavily templated prompts where the dynamic part dominates (those belong in code)

## Eval ties

Evals in `../evals/` should reference these files, not have their own copy. Same prompt, two contexts (prod runtime + eval harness).
