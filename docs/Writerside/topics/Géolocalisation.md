# Géolocalisation

### Technologies utilisées
- geolocator : Pour vérifier l’état des services de localisation, les autorisations, et obtenir la position GPS actuelle de l’utilisateur.
- google_maps_flutter : Pour manipuler la carte Google Maps (contrôle de caméra, marqueurs).

### Fonctionnement
Ce fichier contient une classe utilitaire UserLocation avec une méthode statique getAndDisplayLocation destinée à :
- Obtenir la position actuelle de l’utilisateur
- Centrer la carte Google Maps sur cette position
- Ajouter un marqueur sur cette position 

Étapes détaillées :
- Vérification des services de localisation
- Utilise Geolocator.isLocationServiceEnabled() pour s’assurer que le service est actif sur le téléphone.
- **Vérification des permissions**:
Si les autorisations sont refusées, on les demande via Geolocator.requestPermission().
- **Récupération de la position**:
Une fois les autorisations accordées, Geolocator.getCurrentPosition() permet d’obtenir la position GPS.
- **Centrage de la carte (focus = true)**:
Si l’option focus est activée, la caméra de la carte est déplacée vers la position utilisateur.
- **Ajout d’un marqueur (locationMarker = true)**:
Si cette option est activée, un marqueur nommé "userLocation" est ajouté (ou remplacé) à la position détectée.

Vérification des permissions et récupération de la position :
```dart
// Vérifier si le service de localisation est activé.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Demander à l'utilisateur d'activer le service de localisation.
      return Future.error('Le service de localisation est désactivé.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Les autorisations sont refusées, aucune autre action possible.
        return Future.error('Les autorisations de localisation sont refusées');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Les autorisations sont refusées pour toujours, gérez en conséquence.
      return Future.error(
          'Les autorisations de localisation sont refusées pour toujours.');
    }

    // Lorsque nous avons les autorisations, récupérez la position actuelle.
    final position = await Geolocator.getCurrentPosition();
```
Centrage de la carte et ajout de marqueur :
```dart
if (focus) {
      // Centrer la caméra sur la position de l'utilisateur avec un léger zoom
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 16, // Niveau de zoom légèrement plus élevé
      )));
    }

    if (locationMarker) {
      // Supprimer l'ancien marqueur de localisation
      markers.removeWhere((marker) => marker.markerId.value == 'userLocation');

      // Ajouter un nouveau marqueur à la position de l'utilisateur
      markers.add(
        Marker(
          markerId: const MarkerId('userLocation'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: 'Ma position'),
        ),
      );
    }
    return position;
```