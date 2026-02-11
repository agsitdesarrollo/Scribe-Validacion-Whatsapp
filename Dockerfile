# Scribe-Validacion/Dockerfile
# Bot de WhatsApp con BuilderBot - Requiere Chromium para funcionar
FROM node:20-alpine

# Instalar dependencias del sistema para BuilderBot/Baileys
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont

# Variables de entorno para Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

WORKDIR /app

COPY package*.json pnpm-lock.yaml ./
RUN corepack enable && corepack prepare pnpm@latest --activate
RUN pnpm install --frozen-lockfile

COPY . .

# Crear directorio para sesiones de WhatsApp
RUN mkdir -p /app/bot_sessions

EXPOSE 3008

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
  CMD node -e "require('http').get('http://localhost:3008/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})" || exit 1

CMD ["pnpm", "start"]
