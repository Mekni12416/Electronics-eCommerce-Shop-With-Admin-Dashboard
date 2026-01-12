# ================================
# STAGE 1: Builder
# ================================
# Utilise une image Alpine légère pour réduire la taille finale
FROM node:18-alpine AS builder

# Définit le répertoire de travail
WORKDIR /app

# Copie uniquement les fichiers de dépendances pour optimiser le cache Docker
# Si package.json ne change pas, cette layer sera réutilisée
COPY package*.json ./

# Installe uniquement les dépendances de production
# --only=production exclut les devDependencies
# npm ci est plus rapide et déterministe que npm install
RUN npm ci --only=production && \
    npm cache clean --force

# Copie le reste du code source de l'application
COPY . .

# Génère le client Prisma (nécessaire pour l'ORM)
RUN npx prisma generate

# ================================
# STAGE 2: Production
# ================================
# Nouvelle image propre pour la production
FROM node:18-alpine AS production

# Installe dumb-init pour gérer correctement les signaux (SIGTERM, SIGINT)
# Cela permet un arrêt gracieux du conteneur
RUN apk add --no-cache dumb-init

# Crée un utilisateur non-root pour des raisons de sécurité
# L'exécution en tant que root dans un conteneur est une faille de sécurité
RUN addgroup -g 1001 -S nodeuser && \
    adduser -S -u 1001 -G nodeuser nodeuser

# Définit le répertoire de travail
WORKDIR /app

# Copie les node_modules depuis le stage builder
# Cela évite de réinstaller les dépendances
COPY --from=builder --chown=nodeuser:nodeuser /app/node_modules ./node_modules

# Copie le code source depuis le stage builder
COPY --from=builder --chown=nodeuser:nodeuser /app ./

# Crée le dossier logs avec les bonnes permissions
# L'application écrit des logs dans ce dossier
RUN mkdir -p logs && chown -R nodeuser:nodeuser logs

# Variables d'environnement par défaut
# Ces valeurs peuvent être surchargées au runtime avec docker run -e
ENV NODE_ENV=production \
    PORT=5000 \
    DB_HOST=localhost \
    DB_USER=root \
    DB_PASSWORD="" \
    DB_NAME=singitronic_nextjs

# Expose le port sur lequel l'application écoute
# Note: Le code utilise process.env.PORT || 3001, donc on expose 5000 comme demandé
EXPOSE 5000

# Bascule vers l'utilisateur non-root
USER nodeuser

# Utilise dumb-init pour gérer les signaux système correctement
# Lance l'application avec le fichier principal app.js
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "app.js"]
