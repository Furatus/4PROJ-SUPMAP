import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocation {
  static Future<Position> getAndDisplayLocation(
      {required GoogleMapController mapController,
      required Set<Marker> markers,
      bool focus = true,
      bool locationMarker = true}) async {
    bool serviceEnabled;
    LocationPermission permission;

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
  }
}
