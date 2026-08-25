# Architecture Tradeoffs

> Documented pillar conflicts. Azure Well-Architected practice - explicit tradeoff records prevent revisiting the same arguments.

| Tradeoff | Chose | Over | Why |
|---|---|---|---|
| {{TODO}} | Cost | Performance | Self-hosting Postgres saves $300/mo vs managed; we accept the ops burden because team has DBA experience |
| {{TODO}} | Simplicity | Flexibility | One ORM (Prisma) - locks us in but cuts onboarding from 2 weeks to 2 days |
| {{TODO}} | Reliability | Velocity | Required code review even for solo dev; slower shipping but caught bugs in retrospect |

## Format

Each row: chose-this OVER that BECAUSE reason. Two-line max. If reasoning needs more, write an ADR.

## When to add a row

Whenever you knowingly accept a downside of one pillar to gain another. The whole point of WAF reviews is surfacing these.
