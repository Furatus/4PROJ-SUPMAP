# Interface Web

Le projet est organisé en modules clairs et maintenables, regroupés par fonctionnalité. Voici un aperçu des différentes parties techniques de l’application :

- **[Carte interactive](Carte-interactive.md)**:
  Intègre une carte avec affichage de l'utilisateur, suivi en temps réel, gestion des itinéraires, marqueurs, zoom, etc.

- **[Recherche](Recherche.md)**:
  Permet la sélection d’un point de départ et d’arrivée, avec affichage du trajet sous forme de polyligne sur la carte.

- **[Signalement](Signalement-à-proximité.md)**:
  Affiche les signalements en temps réel à proximité de l'utilisateur, avec mise à jour automatique via WebSocket.

- **[Authentification](Authentification-Web.md)**:
  Connexion, inscription, gestion des erreurs de formulaire, validation avec zod, redirection sécurisée.

- **[QR Code](Partage-de-QR-Code.md)**:
  Génération d’un QR code à partir d’un identifiant de session ou de profil, partageable via une pop-up.

### Technologies utilisées

###### Environnement et outils
- **React 19**
Bibliothèque JavaScript pour construire l’interface utilisateur.

- **Vite**
Outil de build rapide pour projets React.

- **React Router DOM**
Gestion du routage côté client avec protection des routes.

###### Communication & Backend
- **Axios**
Gestion des appels HTTP vers le backend (authentification, récupération des données).

###### Authentification
- **React Hook Form**
Gestion des formulaires d’inscription/connexion.


- **JWT (via localStorage)**
Stockage du token pour maintenir la session active.

###### Cartographie et géolocalisation
- **React Google Maps**
Affichage de la carte Google Maps avec intégration de marqueurs et polylignes.
- 


- ** Polyline**
Decodage des polylignes pour afficher les trajets sur la carte.

- **Geolocation API (navigateur)**
Suivi en temps réel de la position de l'utilisateur.

###### Partage & Interface
- **react-qr-code**
Génération de QR codes dynamiques pour le partage de profils ou de trajets.

- **Tailwind CSS**
Framework CSS utilitaire pour styliser rapidement l'interface.

- **Lucide React**
Ensemble d’icônes modernes et minimalistes utilisées dans l’UI.