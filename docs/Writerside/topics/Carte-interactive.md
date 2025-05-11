# Carte interactive

### Technologies utilisées
- @vis.gl/react-google-maps : Intégration avancée de Google Maps avec React.
- @googlemaps/markerclusterer : Pour regrouper automatiquement les marqueurs (ex. incidents) sur la carte.
- @googlemaps/polyline-codec : Pour décoder les itinéraires ou trajets encodés en polylignes (utiles pour les tracés).
- Tailwind CSS : Pour le style réactif et les classes utilitaires.
- Lucide : Pour les icônes modernes (ex. boutons, contrôles sur carte).
- React Hooks : Gestion de l’état local (ex. position utilisateur, niveau de zoom…).



### Fonctionnement

La carte interactive est une des fonctionnalités centrales de l'application. Elle affiche une carte Google Maps à l'aide de la librairie @vis.gl/react-google-maps, intégrée dans des composants React (LiveMap.jsx, MapDisplay.jsx, etc.).
- Voici les principales capacités de cette carte :
- Affichage dynamique des positions et événements en temps réel.
- Ajout de marqueurs personnalisés (par exemple, accidents, bouchons) avec regroupement intelligent grâce à markerclusterer.
- Affichage d’itinéraires ou chemins sous forme de polylignes.
- Contrôles interactifs (zoom, recentrage, localisation utilisateur).
- Utilisation du GPS ou de l'API Google pour suivre la position de l'utilisateur.