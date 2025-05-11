# Serveur

Le projet est organisé en modules clairs et maintenables, regroupés par fonctionnalité. Voici un aperçu des différentes parties techniques de l’application :

- **[Graphhopper](Graphhopper.md)**:
  Gère le calcul d’itinéraires et le map matching via le moteur GraphHopper, basé sur les données OpenStreetMap.

- **[API](API.md)**:
  Regroupe les routes REST du serveur pour interagir avec le client mobile (itinéraires, signalements, etc.).

- **[Base de Données](Base-de-Données.md)**:
  Définit la structure et les modèles de données utilisés pour stocker les informations (signalements, utilisateurs...).

- **[Configuration HTTPS](Configuration HTTPS.md)**

### Technologies utilisées
- Node.js	Environnement d'exécution JavaScript côté serveur.
- Express.js	Framework HTTP minimaliste pour créer les routes et les APIs REST.
- Socket.IO	Bibliothèque WebSocket pour la communication en temps réel avec le client.
- GraphHopper API	Intégré via des requêtes HTTP pour le calcul d'itinéraires.
- dotenv	Pour charger les variables d’environnement depuis un fichier .env.
- CORS	Middleware de sécurité pour les échanges avec le client Flutter.