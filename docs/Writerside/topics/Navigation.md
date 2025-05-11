# Navigation

**La navigation contient** :

- **[Géolocalisation](Géolocalisation.md)**:
  Affichage du positionnement.

- **[Incidents](Signalement.md)**:
  Gestion des signalements.

### Technologies utilisées
- google_maps_flutter : Affichage et interaction avec Google Maps.
- geolocator : Récupération de la position GPS de l’utilisateur.
- polyline_points : Pour dessiner des polylignes (itinéraires).

### Fonctionnement
Ce fichier implémente l’écran principal de carte. Il permet d’afficher une Google Map centrée sur la position actuelle de l’utilisateur, d’y ajouter des marqueurs dynamiquement, et de réagir à certaines actions utilisateur via une interface flottante personnalisée.
Fonctionnalités clés :
- Initialisation de la position : Lors de l’ouverture de la carte, la position GPS actuelle est récupérée et utilisée pour centrer la carte.
- Google Maps personnalisé : Affichage de la carte avec des paramètres personnalisés (MapType.terrain, désactivation du zoom controls, etc.).
- Ajout de marqueurs : Marqueurs définis dans le MapController.
- Widget d’interface flottant (FloatingSearchBar) : Permet de gérer des interactions utilisateurs (non encore développées dans cet extrait).
- Bouton de centrage : En bas à droite, permet de recentrer la carte sur la position de l’utilisateur.

```dart
GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude)
                  : _initialCameraPosition,
              zoom: _currentZoomLevel,
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.4,
            ),
            polylines: Set<Polyline>.from(myRouteList),
            markers: Set<Marker>.of(markerList + iconMarkers + incidentMarkers),
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapType: MapType.normal,
            style: _mapStyle,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;

              Future.delayed(Duration(milliseconds: 250), () {
                checkPermissionAndListenLocation();
              });
            },
          ),
```

### Recalcul de l'Itinéraire

Cette fonction a pour objectif de recalculer la distance restante et d’ajuster dynamiquement l’itinéraire lorsque l’utilisateur s’écarte du trajet initialement prévu.

En faisant:
- Détection de la manœuvre en cours via l’index de position.
- Calcul précis de la distance restante jusqu'à la prochaine étape.
- Mise à jour en temps réel de l'affichage pour guider l’utilisateur (zoom, distance, rue).

###### Code 

```dart
for (int i = 0; i < maneuvers.length; i++) {
      int startIndex = (maneuvers[i]["interval"][0] as num).toInt();
      int endIndex = (maneuvers[i]["interval"][1] as num).toInt();

      if (globalclosestIndex >= startIndex && globalclosestIndex <= endIndex) {
        if (_currentManeuver != maneuvers[i]) {
          _currentManeuver = maneuvers[i];
          break;
        }
        //  Calcul de la distance restante jusqu'à la prochaine instruction (comme on connait l'index de notre position par rapport a la prochaine instruction)
        int? nextBeginIndex;
        if (i + 1 < maneuvers.length) {
          nextBeginIndex = maneuvers[i + 1]["interval"][0];
        }

        // On somme la distance jusqu’à nextBeginIndex
        double totalDistance = 0.0;
        for (int j = globalclosestIndex;
            j < (nextBeginIndex ?? allLatLngList.length - 1);
            j++) {
          if (j >= allLatLngList.length - 1) break;
          totalDistance += mtk.SphericalUtil.computeDistanceBetween(
              allLatLngList[j], allLatLngList[j + 1]);
        }
        _currentRemainingDistance = formatDistance(totalDistance);

        _currentZoomLevel = getZoomLevel(totalDistance);
        // Mise à jour du nom de la rue
        if (_currentManeuver.containsKey("street_name")) {
          _currentStreetName = _currentManeuver["street_name"];
        } else {
          _currentStreetName = "Route inconnue";
        }
        break;
      }
    }
```

### Calcul de la vitesse

Cette fonctionnalité permet de suivre en temps réel la vitesse de l'utilisateur ainsi que de détecter la limitation de vitesse applicable à sa position actuelle sur l'itinéraire.

Cela permet de :
- informer l’utilisateur en temps réel de la limite de vitesse sur la portion actuelle, 
- vérifier d’éventuels dépassements de vitesse, 
- ajouter des fonctionnalités de sécurité ou d’alerte visuelle en cas d’excès.

###### Code

```dart
 // Mise à jour de la limite de vitesse
    if (speedLimits.isNotEmpty) {
      for (int i = 0; i < speedLimits.length; i++) {
        if (globalclosestIndex >= speedLimits[i][0] &&
            globalclosestIndex <= speedLimits[i][1]) {
          _currentSpeedLimit =
              speedLimits[i][2] != null ? "${speedLimits[i][2].toInt()}" : "--";
          break;
        }
      }
    }
    // Mise à jour de la vitesse
    _calculateSpeed();
```

### Calcul du temps

Cette fonctionnalité calcule en temps réel la distance totale restante jusqu’à la destination ainsi que le temps estimé d’arrivée (ETA).
Elle s'appuie sur la position actuelle de l'utilisateur dans l'itinéraire et les données de navigation reçues.

Concrètement, le système :
- Mesure la distance qu’il reste à parcourir à partir du point actuel jusqu’à la fin de l’itinéraire. 
- Additionne les durées prévues de chaque segment du trajet (ou "manœuvre"). 
- Estime l’heure d’arrivée en ajoutant ce temps restant à l’heure actuelle.

###### Code

```dart
 //  Calcul de la distance totale restante jusqu'à l'arrivée
    double totalRemainingDistance = 0.0;
    for (int i = globalclosestIndex; i < allLatLngList.length - 1; i++) {
      totalRemainingDistance += mtk.SphericalUtil.computeDistanceBetween(
          allLatLngList[i], allLatLngList[i + 1]);
    }
    _currentTotalRemainingDistance = formatDistance(totalRemainingDistance);

    // Calcul du temps restant

    int remainingTimeInMilliseconds = 0;
    for (int i = 0; i < maneuvers.length; i++) {
      if (maneuvers[i].containsKey("time")) {
        remainingTimeInMilliseconds += (maneuvers[i]["time"] as num).toInt();
      }
    }
    _totalRemainingTime = (remainingTimeInMilliseconds / 60000).round();
    _estimatedArrivalTime =
        DateTime.now().toLocal().add(Duration(minutes: _totalRemainingTime));

    if (mounted) setState(() {});
```
