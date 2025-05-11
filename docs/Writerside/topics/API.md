# API

### Introduction
L’API SupMap permet la gestion des utilisateurs, des incidents, de la navigation, ainsi que du suivi de position. Elle suit les standards REST et retourne des réponses JSON.

Nous avons heberger un swagger, url du server a la racine

### Authentification (`/auth`)
Cette section permet de gérer tout ce qui concerne l’identité des utilisateurs : inscription, connexion, récupération de profil, suppression de compte, et connexion via Google.

| Méthode | Endpoint     | Description                        | Authentification requise |
|---------|--------------|------------------------------------|---------------------------|
| POST    | /register    | Inscription d’un nouvel utilisateur | ❌                        |
| POST    | /login       | Connexion d’un utilisateur          | ❌                        |
| GET     | /profile     | Récupère le profil de l’utilisateur | ✅ Token JWT              |
| DELETE  | /delete      | Supprime le compte utilisateur      | ✅ Token JWT              |
| POST    | /google      | Authentification via Google OAuth   | ❌                        |

### Incidents (`/incidents`)
Gérer les incidents signalés par les utilisateurs, comme des accidents, bouchons ou dangers sur la route. Chaque incident peut être confirmé ou réfuté par les autres utilisateurs.

| Méthode | Endpoint              | Description                                                    |
|---------|-----------------------|----------------------------------------------------------------|
| POST    | /create               | Créer un nouvel incident                                       |
| GET     | /confirm/{id}         | Confirmer un incident (vote de validation)                     |
| GET     | /refute/{id}          | Réfuter un incident (vote de rejet)                            |
| GET     | /get/nearme           | Incidents proches de la localisation actuelle de l’utilisateur |
| GET     | /get/nearlocation     | Incidents proches d'une localisation précise (lat/lng)         |
| GET     | /incident             | Récupérer tous les incidents                                   |
| GET     | /closeExpired         | Clôturer automatiquement les incidents expirés                 |


### Navigation (`/navigation`)
Fournir des itinéraires personnalisés basés sur des modèles de coût (vitesse, type de route, conditions…).

| Méthode | Endpoint          | Description                              |
|---------|-------------------|------------------------------------------|
| GET     | /getCustomModel   | Récupère le modèle de coût personnalisé   |
| POST    | /traceroute       | Calculer un itinéraire                   |

##### Explication générale de la fonction route
La fonction route est un point d'entrée API qui permet de calculer un itinéraire routier personnalisé en tenant compte :
- des préférences de l'utilisateur (comme éviter les routes à péage),
- et des incidents en cours (accidents, travaux, routes fermées, etc.).
Elle agit comme un intermédiaire entre l'application cliente et l'API de routage GraphHopper.

###### Ce que fait la fonction en résumé :
1) Récupère les données d’entrée envoyées par l'utilisateur (ex : points de départ et d’arrivée). 

2) Cherche dans la base de données tous les incidents en cours (non clos).

3) Transforme ces incidents en un format compréhensible par GraphHopper, pour influencer le choix des routes.

4) Construit un modèle de routage personnalisé : par exemple, éviter les routes à péage si l'utilisateur ne veut pas les emprunter.

5) Envoie une requête à GraphHopper avec ce modèle personnalisé pour calculer un itinéraire optimal.

6) Retourne à l'utilisateur le résultat : une route calculée, tenant compte des incidents et préférences.

###### Pourquoi c’est utile ?
Cette approche permet de calculer des itinéraires plus intelligents et dynamiques, adaptés à :
- l’état actuel du réseau routier (accidents, bouchons), 
- les préférences spécifiques de l’utilisateur (éviter les péages), 
- et les exigences métier (ex : ignorer certaines zones).

### Position Tracker (`/positionTracker`)
Permet aux utilisateurs d’envoyer leur position GPS en temps réel pour la localisation, la navigation ou le suivi.

| Méthode | Endpoint          | Description                               |
|---------|-------------------|-------------------------------------------|
| POST    | /updateLocation   | Met à jour la position GPS de l’utilisateur |
