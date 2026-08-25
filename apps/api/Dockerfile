# syntax=docker/dockerfile:1.7
# =============================================================================
# {{PROJECT_NAME}} — API Dockerfile (multistage)
# =============================================================================
# Targets:
#   dev         — installed deps + source, suitable for live-reload
#   builder     — compiles TS, prunes dev deps
#   production  — minimal runtime image (distroless or alpine)
# =============================================================================

# ---- Base -------------------------------------------------------------------
FROM node:20.18.0-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable && corepack prepare pnpm@9.12.0 --activate
WORKDIR /app

# ---- Dev (used by docker-compose.yml with bind mount) ----------------------
FROM base AS dev
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/api/package.json ./apps/api/
COPY packages/shared/package.json ./packages/shared/
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
COPY . .
EXPOSE 8000
CMD ["pnpm", "--filter", "@{{PROJECT_NAME_KEBAB}}/api", "dev"]

# ---- Builder ----------------------------------------------------------------
FROM base AS builder
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/api/package.json ./apps/api/
COPY packages/shared/package.json ./packages/shared/
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
COPY . .
RUN pnpm --filter "@{{PROJECT_NAME_KEBAB}}/api^..." build
RUN pnpm --filter "@{{PROJECT_NAME_KEBAB}}/api" build
RUN pnpm deploy --filter "@{{PROJECT_NAME_KEBAB}}/api" --prod /prod/api

# ---- Production -------------------------------------------------------------
FROM node:20.18.0-alpine AS production
RUN apk add --no-cache tini curl
WORKDIR /app
COPY --from=builder /prod/api/package.json ./package.json
COPY --from=builder /prod/api/node_modules ./node_modules
COPY --from=builder /prod/api/dist ./dist
ENV NODE_ENV=production
USER node
EXPOSE 8000
ENTRYPOINT ["/sbin/tini", "--"]
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -fsS http://localhost:8000/health || exit 1
CMD ["node", "dist/index.js"]
