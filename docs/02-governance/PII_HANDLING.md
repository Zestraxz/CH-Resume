# PII Handling

> Pattern documentation only. Specific implementation depends on your data shape.

---

## Where PII enters the system

1. User input forms (login, profile, content)
2. Webhooks from third parties (Stripe, OAuth providers)
3. Server logs of request bodies (if not scrubbed)
4. LLM provider calls (if user input is passed verbatim)
5. Database backups

## Scrubbing tiers

| Tier | Latency | Catches | Tool |
|---|---|---|---|
| Regex | sub-ms | Emails, phones, SSN, credit card patterns | `pii-detect` (TS), `presidio` (Py - regex mode) |
| NER | 5-50ms | Names, addresses, indirect identifiers | spaCy + presidio (Py), `compromise` (TS) |
| LLM | 200-800ms | Subtle PII in long-form text | Claude / GPT classification |

## Pattern: structured-logging middleware (preferred)

Scrub BEFORE serialization. No "leak window."

```typescript
// apps/api/src/lib/pii.ts
import { redactPII } from '@your-lib/pii-detect';

logger.serializers.req = (req) => ({
  ...req,
  headers: redactPII(req.headers),
  body: redactPII(req.body),
});
```

## Pattern: log post-processor (fallback)

Acceptable when middleware not feasible. Risk: PII sits in logs unredacted for the window between write and processor run.

## Test fixtures

Use clearly fake values (`test+user@example.com`, `+1-555-0100`). Never sample real PII for fixtures.

## Reference implementations

- [Microsoft Presidio](https://github.com/microsoft/presidio) - Python; tier 1 + 2
- [Wealthsimple PII redaction](https://github.com/wealthsimple/redactor) - open-source ref impl
- [TruffleHog](https://github.com/trufflesecurity/trufflehog) - secret scanning (related)

## Compliance

- GDPR Art. 5(1)(c): data minimization. Scrubbing supports compliance.
- HIPAA: PHI ~ PII for these purposes; same patterns apply.
- See [PRIVACY.md](PRIVACY.md) for the data-subject-rights workflow.
