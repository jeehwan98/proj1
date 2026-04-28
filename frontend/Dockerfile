# Stage 1 — install dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --frozen-lockfile

# Stage 2 — build the Next.js app
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# NEXT_PUBLIC_* vars are baked in at build time, not runtime
# /api is relative — the browser resolves it to the same origin so the ALB routes it to the backend
ENV NEXT_PUBLIC_API_URL=/api
RUN npm run build

# Stage 3 — minimal runtime image
# Only copies the standalone server bundle and static assets — no source, no node_modules
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder --chown=appuser:appgroup /app/.next/standalone ./
COPY --from=builder --chown=appuser:appgroup /app/.next/static ./.next/static

USER appuser

EXPOSE 3000
CMD ["node", "server.js"]
