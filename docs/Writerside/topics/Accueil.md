# Accueil

SUPMAP est une application de navigation en temps réel développée pour la société fictive Trafine. Ce projet vise à proposer une alternative innovante et communautaire à des services tels que Waze. L'application permet aux utilisateurs de recevoir des informations sur la circulation, les incidents routiers, et d'obtenir des itinéraires optimisés selon les conditions en temps réel. Elle offre également des fonctionnalités participatives pour améliorer la fiabilité des données grâce à la contribution des utilisateurs.

SUPMAP repose sur une architecture micro-services et comprend trois axes principales :

Une [Application Mobile](Application-Mobile.md) pour la navigation et les signalements.

Une [Interface Web](Interface-Web.md) pour la visualisation et la gestion des données.

Un [Serveur](Serveur.md) pour le traitement des données et la gestion des fonctionnalités.

### Justification des Technologies utilisée

###### Flutter (pour l'application mobile)
Points forts :
- Cross-platform natif (iOS et Android avec une seule base de code)
- Excellentes performances 
- Intégration facile avec Google Maps via des plugins comme google_maps_flutter 
- Bon support de la géolocalisation et du GPS (via geolocator)

**Justification** :

Flutter permet de développer rapidement une application mobile performante sur Android et iOS.De plus, Flutter propose une large gamme de plugins pour le GPS, la carte et les permissions.

###### Vite
Points forts :
- Démarrage ultra-rapide grâce à l’utilisation de ES modules
- configuration simple et moderne
- Compatible avec React 
- Optimisé pour la performance en dev
- 
**Justification** :

Vite est utilisé comme outil de build et de développement pour la partie web (React). Il permet de gagner du temps en développement avec un rafraîchissement rapide, et de générer un build optimisé pour la production. Cela améliore l’expérience du développeur et les performances du tableau de bord.

###### Graphhopper

GraphHopper a été choisi pour ce projet en raison de sa simplicité d’installation, de ses performances solides et de la qualité de sa documentation. Contrairement à Valhalla, qui est plus complexe d'intégré des donées personnalisées comme les incidents, GraphHopper s’installe facilement à l’aide d’un simple fichier JAR et d’une carte OSM, ce qui permet un déploiement rapide. Côté performance, il offre des temps de réponse rapides avec une faible consommation mémoire, ce qui le rend parfaitement adapté à une application de navigation en temps réel comme Waze.

### Base de Données

 Voici le lien de la [BD](Base-de-Données.md)