# Add-only GPT / Claude / Antigravity review — CH-Resume

Date: 2026-11-03
Source repository: Zestraxz/CH-Resume
Source branch: main
Review level: initial source inspection; runtime and CI not executed

## Project boundary

Public repository currently containing a generic project scaffold

## Verified source context

README.md and AGENTS.md still describe an undefined Resume product, with placeholder target user and framework tooling. The GitHub repository is public.

## Findings requiring independent confirmation

1. Do not invent a resume product or publish identifiable CV, employment, salary, contact or candidate details on this public repository.
2. Current generic templates are not evidence of a functioning resume builder; dedicated domain tests and use case definition would be prerequisites.
3. Existing governance asks for editing STATUS.md, which conflicts with the new add-only requirement.

## Proposed new artifacts and measurements

1. Create a generic, non-personal MVP requirements decision template for owner approval.
2. Add a privacy threat-model proposal for CV parsing, document retention and export, without using real resume samples.
3. Define synthetic-only validation cases and a standalone progress-snapshot pattern rather than updating shared template files.

## Safety restrictions for this project

All new content must be safe for PUBLIC disclosure and contain no private user details, HR records, PII, API keys or original resume materials.

## Immutable three-agent handshake (proposal)

### Owner's absolute add-only rule

GPT, Claude and Antigravity are prohibited from editing, overwriting, renaming, deleting, reverting, auto-formatting or regenerating existing tracked repository artifacts. Only previously absent paths are allowed. Domain-specific safety and privacy restrictions still apply. Nothing is merged into `main` automatically.

1. **DISCOVER**: verify the repository URL, current default-branch commit SHA, README, governance rules, local limitations, prior evidence and known defects.
2. **PROPOSE**: create `docs/ai-cowork/events/<utc>-<task-id>-<agent>-propose.json` as a new file. Specify proposed paths, source SHA, acceptance checks, risk and next agent. Do not store private source content.
3. **ACK and CLAIM**: the receiver creates another *new* file referencing the proposal's path and hash, then claims the task on its own isolated branch. Conflicting claims must stop for arbitration.
4. **DELIVER**: create only new files (including new versioned successors if an existing artifact needs improvement). Never modify the predecessor. Include test evidence and remaining limitations.
5. **REVIEW**: a different agent checks source fidelity, privacy, regressions and actually executed tests. Verdict is recorded in a new review event.
6. **ACCEPT**: propose a draft pull request. Human approval or explicitly delegated maintainership is required for merge. The proposed artifact is not authoritative until the owner accepts it.

Example event (all values illustrative, no actual task has been assigned to Claude/Antigravity):

```json
{
  "protocol_version": "ch-ai-cowork-event/1",
  "event_id": "20261103T000000Z-gpt-example-unique",
  "task_id": "TASK-20261103-example",
  "event_type": "PROPOSE",
  "agent": "gpt",
  "repo": "Zestraxz/CH-Resume",
  "target_branch": "main",
  "source_commit": "<40-character SHA>",
  "predecessor_event_path": null,
  "source_paths": [],
  "proposed_new_paths": [],
  "acceptance_checks": [],
  "evidence_paths": [],
  "risk_level": "LOW|MEDIUM|HIGH|RESTRICTED",
  "verdict": "PENDING"
}
```

Each event path must be unique, never reused. Event relationships are proven by preceding path/hash references, not date ordering alone. Use dedicated clones or worktrees per simultaneous agent. Two agents must never write in the same working directory.

### Merge-time protection

Before a draft PR is accepted, compare the source branch to the latest target-branch HEAD and require every change to be `A` (added). Reject `M`, `D`, `R`, `C`, `T` and any existing destination path. Recheck after the target moves or a merge conflict appears. Inspect generators, formatters, schedulers and tests for in-place mutations before running them. A review document does **not** activate CI, change permissions or establish that this gate is installed.

## Limitations and reviewer handoff

This review is based on the repository inventory plus selected source/governance files, not a comprehensive file-by-file audit, full security assessment, or runtime test. No real Claude/Antigravity acknowledgement occurred in this session. The next reviewer should independently verify every finding, then deliver a distinct new artifact and separate PR; never amend this review file after it is merged.

