# Application Mobile


Le projet est organisé en modules clairs et maintenables, regroupés par fonctionnalité. Voici un aperçu des différentes parties techniques de l’application :

- **[Navigation](Navigation.md)**:
Contient les écrans principaux tels que la page de navigation.

- **[Géolocalisation](Géolocalisation.md)**:
Affichage du positionnement.

- **[Incidents](Signalement.md)**:
Gestion des signalements.

- **[Paramètres](Paramètres.md)**:
  Paramètres du compte utilisateur.

- **[Authentification](Authentification.md)**:
Interface de connexion et d’inscription.

- **[QR Code](Partage-de-QR-Code.md)**:
  Redirection du site web vers l'application via QR code.

### Technologies utilisées

###### Flutter et environnement
- Flutter SDK : Framework principal pour le développement mobile multiplateforme.
- Dart SDK ≥ 3.6.1 : Langage de programmation utilisé avec Flutter.

###### Connexion et communication
- http : Requêtes HTTP pour la communication avec une API.
- socket_io_client : Communication en temps réel via WebSockets.


###### Authentification
- google_sign_in : Connexion via compte Google.

###### Autres
- google_maps_flutter : Intégration de Google Maps dans l'application.
- geolocator : Accès à la localisation de l'appareil (GPS).
- maps_toolkit : Outils pour les calculs géographiques (distance, angle, etc.).
- polyline_codec : Encodage/décodage de polylignes pour les trajets.


