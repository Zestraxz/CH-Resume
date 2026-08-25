# Access Reviews

> Quarterly. Signed by manager. Filed for audit retention.

---

## Format

`YYYY-Q[1-4]-access-review.md` per quarter.

```markdown
# Access Review - YYYY Q[N]

**Conducted:** YYYY-MM-DD
**Approver:** <manager name>
**Scope:** All repository access; secrets; cloud roles.

## Repository access

| User | Role | Justification | Action |
|---|---|---|---|
| <user1> | Admin | Repo owner | Keep |
| <user2> | Write | Active contributor | Keep |
| <user3> | Read | Departed 2026-MM-DD | **REMOVE** |

## Secret access

| Secret | Who can read | Last rotated | Action |
|---|---|---|---|
| `DATABASE_URL` (prod) | Ops team | 2026-MM-DD | Keep |
| `STRIPE_API_KEY` | Backend + ops | 2026-MM-DD | Rotate (>180 days) |

## Cloud roles

(IAM dump - per cloud provider)

## Sign-off

By: <signature / commit by manager>
```

## Cadence

End of every quarter. Calendar reminder for the maintainer.
