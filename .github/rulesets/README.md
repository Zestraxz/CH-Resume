# Rulesets as Code

> GitHub Rulesets (the modern replacement for branch protection) checked into the repo.

---

## Apply via gh CLI

```bash
gh api repos/Zestraxz/resume/rulesets \
  --method POST \
  --input .github/rulesets/main.json
```

## Or via Terraform

```hcl
resource "github_repository_ruleset" "main" {
  name        = "Protect main"
  repository  = "resume"
  target      = "branch"
  enforcement = "active"
  # ... (parse main.json)
}
```

## Why ruleset-as-code

- Click-ops branch protection is invisible. Code is auditable.
- Reviewable in PRs.
- Identical across forks / re-creations.
- Required SOC 2 evidence.

## Edit workflow

1. Modify `main.json`.
2. Apply via `gh api`.
3. Commit the change with explanation.

## Reference

- [GitHub - available ruleset rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets)
