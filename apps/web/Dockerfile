# syntax=docker/dockerfile:1.7
# =============================================================================
# {{PROJECT_NAME}} — Web Dockerfile (multistage)
# =============================================================================
# Targets:
#   dev         — Vite dev server on port 5173
#   builder     — runs `pnpm build` to produce static assets
#   production  — nginx:alpine serving /dist
# =============================================================================

# ---- Base -------------------------------------------------------------------
FROM node:20.18.0-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable && corepack prepare pnpm@9.12.0 --activate
WORKDIR /app

# ---- Dev --------------------------------------------------------------------
FROM base AS dev
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/web/package.json ./apps/web/
COPY packages/shared/package.json ./packages/shared/
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
COPY . .
EXPOSE 5173
CMD ["pnpm", "--filter", "@{{PROJECT_NAME_KEBAB}}/web", "dev", "--host", "0.0.0.0"]

# ---- Builder ----------------------------------------------------------------
FROM base AS builder
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/web/package.json ./apps/web/
COPY packages/shared/package.json ./packages/shared/
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
COPY . .
RUN pnpm --filter "@{{PROJECT_NAME_KEBAB}}/web^..." build
RUN pnpm --filter "@{{PROJECT_NAME_KEBAB}}/web" build

# ---- Production -------------------------------------------------------------
FROM nginx:1.27-alpine AS production
COPY --from=builder /app/apps/web/dist /usr/share/nginx/html
COPY apps/web/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD wget -qO- http://localhost/ >/dev/null || exit 1
CMD ["nginx", "-g", "daemon off;"]
