# ── Stage 1: build ────────────────────────────────────────────────────────────
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# ── Stage 2: serve ────────────────────────────────────────────────────────────
FROM node:22-alpine AS runner

RUN npm install -g serve@14

WORKDIR /srv
COPY --from=builder /app/dist .

EXPOSE 3000

CMD ["serve", "-s", ".", "-l", "3000"]
