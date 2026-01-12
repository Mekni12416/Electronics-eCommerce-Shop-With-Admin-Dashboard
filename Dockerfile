# ================================
# STAGE 1: Dependencies
# ================================
# Installation des dépendances dans un stage séparé pour optimiser le cache
FROM node:18-alpine AS dependencies

# Définit le répertoire de travail
WORKDIR /app

# Copie uniquement les fichiers de dépendances
# Cette layer sera mise en cache si package.json ne change pas
COPY package*.json ./

# Installe toutes les dépendances (dev + production)
# npm ci est déterministe et plus rapide que npm install
RUN npm ci

# ================================
# STAGE 2: Builder
# ================================
# Build de l'application Next.js
FROM node:18-alpine AS builder

# Définit le répertoire de travail
WORKDIR /app

# Copie les node_modules depuis le stage dependencies
# Évite de réinstaller les dépendances
COPY --from=dependencies /app/node_modules ./node_modules

# Copie tout le code source de l'application
COPY . .

# Crée le fichier .env.production avec la variable d'environnement API_URL
# ARG permet de passer la valeur au moment du build: docker build --build-arg API_URL=http://...
ARG API_URL=http://localhost:3001
RUN echo "NEXT_PUBLIC_API_BASE_URL=${API_URL}" > .env.production

# Build l'application Next.js
# Prisma generate est nécessaire car le script build l'appelle
RUN npm run build

# Liste le contenu de .next pour vérification
# Utile pour debugger si le build échoue
RUN echo "=== Contenu de .next ===" && ls -la .next

# ================================
# STAGE 3: Runner (Production)
# ================================
# Image finale légère pour la production
FROM node:18-alpine AS runner

# Définit le répertoire de travail
WORKDIR /app

# Définit l'environnement en production
ENV NODE_ENV=production

# Désactive la télémétrie Next.js (optionnel)
ENV NEXT_TELEMETRY_DISABLED=1

# Crée un groupe et un utilisateur non-root pour la sécurité
# L'exécution en tant que root est une faille de sécurité
RUN addgroup -g 1001 -S nodejs && \
    adduser -S -u 1001 -G nodejs nextjs

# Copie le dossier public (assets statiques)
COPY --from=builder /app/public ./public

# Copie le build Next.js depuis le stage builder
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next

# Copie les node_modules (uniquement les dépendances de production seraient idéales)
# Mais Next.js a besoin de certaines dépendances au runtime
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules

# Copie next.config.js (configuration Next.js)
COPY --from=builder --chown=nextjs:nodejs /app/next.config.mjs ./next.config.mjs

# Copie package.json (nécessaire pour npm start)
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./package.json

# Change le propriétaire de tous les fichiers vers nextjs
RUN chown -R nextjs:nodejs /app

# Expose le port 3000 (port par défaut de Next.js)
EXPOSE 3000

# Bascule vers l'utilisateur non-root
USER nextjs

# Démarre l'application Next.js en mode production
# npm start lance "next start" qui sert le build optimisé
CMD ["npm", "start"]
