# Workflow - Feature Flags

> Decouple deploy from release. Ship code dark, flip the flag when ready.

---

## Vendors (2026)

| Vendor | Best for |
|---|---|
| [LaunchDarkly](https://launchdarkly.com) | Enterprise governance, RBAC, ServiceNow/Terraform integration |
| [Unleash](https://www.getunleash.io) | Best self-host story; stateless API + Postgres |
| [GrowthBook](https://www.growthbook.io) | Warehouse-native experimentation (Bayesian/Frequentist); unifies flags + A/B |
| [PostHog](https://posthog.com) | Flags + analytics + session replay in one |
| Built-in (env var) | Tiny teams; non-runtime flags only |

## Pattern in code

```typescript
import { featureFlag } from '@resume/shared/flags';

if (await featureFlag('new-checkout-flow', { userId })) {
  return newCheckoutFlow(...);
}
return legacyCheckoutFlow(...);
```

## CI pattern

Test app in three states per PR:

1. **All flags off** (current prod baseline)
2. **New flag on** (rollout state)
3. **New flag explicitly off** (rollback path - critical!)

If state 3 breaks, the rollout has no rollback. Block merge.

## Hygiene

- Every flag has a kill date (visible in vendor UI).
- Quarterly cleanup of stale flags - dead flags accumulate as "feature flag rot."
- Track flag-evaluation-count to spot zombie flags.
