# Signalement à proximité

### Technologies utilisées
- React 19 : Interface utilisateur et état local/global.
- @vis.gl/react-google-maps : Affichage des incidents sur la carte.
- Socket.IO (client) : Communication en temps réel avec le backend (WebSocket).
- Lucide : Icônes SVG pour représenter les types d'incidents.
- Tailwind CSS : Mise en forme des boutons et menus de signalement.
- React Hooks (useEffect, useState) : Pour la connexion temps réel et l'affichage dynamique.

### Fonctionnement
La fonctionnalité de signalement en temps réel permet aux utilisateurs :
- D’écouter en temps réel tous les nouveaux incidents signalés par d’autres utilisateurs.
- D’afficher dynamiquement des marqueurs sur la carte à l’endroit de l’incident.
- De regrouper les incidents s’ils sont trop proches (via @googlemaps/markerclusterer).
