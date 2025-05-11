# Base de Données

###### Positiontrackers
**Objectif** :

Stocker la position des utilisateurs en temps réel pour le suivi de la circulation, pour leurs envoyer les nouveaux incidents qui sont à proximité.

**Utilité** :

Cela permet un suivi en temps réel de la position des utilisateurs, ce qui est essentiel pour la navigation et la gestion des incidents. La structure de données est optimisée pour les requêtes géospatiales, permettant une recherche rapide des incidents à proximité.

###### Incidents
**Objectif** :

Enregistrer des incidents (accidents, ralentissements, dangers, etc.) signalés manuellement ou automatiquement.

**Types d'incidents** :
- Accident (accident) : Impacte légerement la vitesse de circulation dans le calcul d'itinéraire sur la portion concernée.
- Police (police) : A titre informatif, pas d'impact sur la circulation.
- Objet sur la route (objet_on_road) : A titre informatif, pas d'impact sur la circulation.
- Bouchon (traffic_jam) : Impacte fortement la vitesse de circulation dans le calcul d'itinéraire sur la portion concernée.

- **Utilité** :

L’usage du format GeoJSON pour la propriété "geoson" permet de surcharger lors de l'appel à Graphhopper pour le calcul d'itinéraires en tenant compte des incidents.

###### users
**Objectif** :

Gérer l’identité et les droits des utilisateurs de l’application.

**Utilité** :

Structure pour l’authentification et l’autorisation. Le champ role permet de gérer les permissions (visualisation des statistiques sur les incidents par exemple).

<img src="mongo.png" alt="BD" border-effect="line"/>
