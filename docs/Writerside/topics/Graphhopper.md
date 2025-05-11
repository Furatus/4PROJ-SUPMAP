# Graphhopper

### Technologies utilisées
- GraphHopper	Moteur de calcul d’itinéraires basé sur des données OpenStreetMap (OSM).
- OpenStreetMap	Base de données cartographiques libres utilisée pour générer les graphes.
- Docker	Conteneurisation de l’application pour simplifier le déploiement.
- Java (via JDK)	Langage et environnement requis pour exécuter GraphHopper.
- YAML: Fichier de configuration (graphhopper-config.yml).
- Fichier PBF (.osm.pbf)	Format compressé contenant les données OSM utilisées comme source de routage.

### Fonctionnement général de GraphHopper

Le dossier graphhopper sert à héberger et configurer le moteur de routage GraphHopper, qui permet :
- De calculer des itinéraires optimaux entre deux points géographiques.
- D’utiliser des données cartographiques locales (OSM) pour améliorer la précision.

**Calcul d’itinéraires (Routing)**

GraphHopper permet de calculer l’itinéraire optimal entre un point de départ et une destination, en tenant compte d’un profil de transport. Il s’appuie sur un graphe routier dérivé des données OSM, dans lequel les routes sont représentées sous forme de nœuds et d’arêtes pondérées selon la distance, le temps ou d’autres critères.


**Map Matching (Alignement de trace GPS)**

GraphHopper permet également de corriger une trace GPS pour l’aligner avec le réseau routier réel. Cette technique est appelée map matching. Elle est utile dans les cas où les données GPS sont bruitées ou inexactes (par exemple en zone urbaine dense).