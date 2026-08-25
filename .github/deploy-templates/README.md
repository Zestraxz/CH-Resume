# Deploy Templates

> Alternative deployment configs as `.example` files. Copy to project root + customize.

---

## What's here

| File | Target | When to use |
|---|---|---|
| `fly.toml.example` | Fly.io | Fast solo hosting; sin-region default; auto-stop-machines |
| `kubernetes.yaml.example` | Generic K8s | Enterprise / self-hosted; needs ingress controller + cert-manager |

Plus the existing `docker-compose.prod.yml` at project root (Docker host / Coolify / Dokku style).

## Usage

Pick ONE deploy target. Copy the `.example` to its real name:

```bash
# Fly.io
cp .github/deploy-templates/fly.toml.example fly.toml
flyctl launch --copy-config
flyctl secrets set JWT_SECRET=... DATABASE_URL=...
flyctl deploy

# Kubernetes
cp .github/deploy-templates/kubernetes.yaml.example kubernetes-deployment.yaml
# Edit image: line to your registry/tag
kubectl create secret generic resume-secrets \
  --from-literal=database-url='...' \
  --from-literal=jwt-secret='...' \
  -n resume
kubectl apply -f kubernetes-deployment.yaml
```

## Don't ship all three side-by-side at project root

That's noise. Pick one, delete the rest from `.github/deploy-templates/` if you're certain you won't switch.

## Existing CI workflow

`.github/workflows/deploy.yml` (in enterprise profile) ships with the SLSA L3 + Cosign build pipeline. After build, you wire the deploy step to whichever target you copied above.
