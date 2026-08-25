# Workflow - Preview Environments

> Spin up an ephemeral copy of the full stack per PR. Reviewer clicks a URL, sees the change running, comments inline.

---

## Vendor landscape (2026)

| Vendor | Best for | Self-host? |
|---|---|---|
| [Vercel](https://vercel.com) | Frontend-only (Next.js, Vite, Astro) | No |
| [Netlify](https://www.netlify.com) | Same as Vercel | No |
| [Northflank](https://northflank.com) | Full-stack ephemeral | No |
| [Qovery](https://www.qovery.com) | Full-stack ephemeral | Partial |
| [Bunnyshell](https://www.bunnyshell.com) | Full-stack ephemeral | No |
| [Coolify](https://coolify.io) | Full-stack ephemeral | YES (self-host) |
| [Uffizzi](https://www.uffizzi.com) | Per-PR Docker Compose | Partial |

## Pattern

1. PR opens -> GitHub webhook fires.
2. Vendor builds frontend + spins up backend container in a namespace.
3. Vendor comments on PR with a unique URL like `pr-42.preview.resume.com`.
4. Reviewer clicks. Tests the change in a near-prod environment.
5. PR merges or closes -> namespace torn down.

## Trade-offs

- **Pro:** Catches bugs that only appear at the integration level. Stakeholder-friendly.
- **Pro:** Forces frontend/backend to share a real network early.
- **Con:** Cost - one running stack per open PR. Auto-tear-down required.
- **Con:** Secret leakage risk if previews are publicly accessible.
- **Mitigation:** Basic auth or VPN-gate the preview URLs.

## Decision criteria

Adopt when:
- Team has > 3 reviewers per PR (worth the cost).
- Frontend changes are visual (screenshots aren't enough).
- Backend changes need integration check (API contract changes).

Skip when:
- Solo dev or 2-person team.
- Pure backend lib with no UI surface.
- Cost-constrained.
