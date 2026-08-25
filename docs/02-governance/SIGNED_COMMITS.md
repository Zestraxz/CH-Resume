# Signed Commits

> Sigstore `gitsign` for keyless OIDC commit signing. Replaces GPG (no key management).

---

## Why

- Auditors (SOC 2, ISO 27001) want proof that commits came from authenticated authors.
- GPG is a UX nightmare (key generation, rotation, lost keys).
- gitsign uses your existing OIDC identity (GitHub, Google, Microsoft) - no keys to manage.

## Local setup

```bash
# Install gitsign (one-time)
go install github.com/sigstore/gitsign@latest
# Or: brew install gitsign

# Configure git
git config --global gpg.format x509
git config --global gpg.x509.program gitsign
git config --global commit.gpgsign true

# First commit triggers browser-based OIDC login (saves a short-lived cert)
git commit -m "first signed commit"

# Verify
git log --show-signature -1
```

## CI verification

```yaml
# .github/workflows/verify-commits.yml
- name: Verify commits are signed
  run: |
    git log --format='%H %G?' origin/main..HEAD | awk '$2 != "G" { print "Unsigned: " $1; exit 1 }'
```

## Branch protection

Enable "Require signed commits" in GitHub branch protection (or via Rulesets). Combined with gitsign, this enforces the policy.

## What `gitsign` does under the hood

1. On commit, gitsign asks Sigstore Fulcio for a short-lived (~10 min) x509 cert tied to your OIDC identity.
2. Cert signs the commit.
3. Entry logged in Rekor transparency log.
4. Verifiers can confirm signer identity without you managing any keys.

## References

- [Sigstore gitsign](https://docs.sigstore.dev/cosign/signing/gitsign/)
- [GitHub - require signed commits](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule)
