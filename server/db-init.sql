-- ================================
-- Script d'initialisation MySQL
-- ================================
-- Ce script est exécuté automatiquement au premier démarrage du conteneur MySQL
-- Il crée la base de données et configure les permissions

-- Sélectionne la base de données
USE devops_db;

-- Note: Les tables seront créées automatiquement par Prisma migrations
-- qui sont montées dans /docker-entrypoint-initdb.d

-- Affiche un message de confirmation
SELECT 'Base de données devops_db initialisée avec succès!' AS message;

-- Vérifie que l'utilisateur devops_user a les bonnes permissions
SHOW GRANTS FOR 'devops_user'@'%';
