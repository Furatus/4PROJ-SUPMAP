import 'dart:async';

import 'package:custom_marker/marker_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supmap/providers/google_maps_provider.dart';
import 'package:supmap/utils/theme_notifier.dart';

import '../../../constants/constants.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final Set<Marker> _markers = {};
  StreamSubscription<Position>? _positionStream;
  final LatLng _initialCameraPosition = const LatLng(47.3779, 0.4913);
  BitmapDescriptor? customIcon;
  bool _darkMode = false;
  String _mapStyle = '';

  @override
  void initState() {
    super.initState();
    _darkMode = themeNotifier.value == ThemeMode.dark;

    _loadMapStyles().then((_) {
      if (mounted) setState(() {});
    });

    themeNotifier.addListener(() {
      setState(() {
        _darkMode = themeNotifier.value == ThemeMode.dark;
        _loadMapStyles().then((_) {
          if (mounted) setState(() {});
        });
      });
    });

    _startLocationUpdates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Préchargement des icônes de début et de fin
    MarkerIcon.markerFromIcon(
            Icons.location_on, Theme.of(context).primaryColor, 150)
        .then((icon) {
      setState(() {
        customIcon = icon;
      });
    });
  }

  /// Vérifie les permissions et démarre le suivi de la localisation
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        print('Permission refusée définitivement');
        return;
      }
    }
  }

  /// Démarre la mise à jour en temps réel de la localisation
  void _startLocationUpdates() async {
    await _checkLocationPermission();

    _positionStream =
        Geolocator.getPositionStream().listen((Position position) async {
      final googleMapsProvider =
          Provider.of<GoogleMapProvider>(context, listen: false);

      if (googleMapsProvider.controller != null) {
        googleMapsProvider.controller!.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
      }

      setState(() {
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(position.latitude, position.longitude),
          icon: customIcon ?? BitmapDescriptor.defaultMarker,
        ));
      });
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _zoomIn() async {
    final googleMapsProvider =
        Provider.of<GoogleMapProvider>(context, listen: false);
    googleMapsProvider.controller?.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    final googleMapsProvider =
        Provider.of<GoogleMapProvider>(context, listen: false);
    googleMapsProvider.controller?.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<GoogleMapProvider>(
          builder: (context, googleMapsProvider, child) {
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialCameraPosition,
                zoom: 14.0,
              ),
              style: _mapStyle,
              onMapCreated: (GoogleMapController controller) {
                googleMapsProvider.setController(controller);
              },
              zoomControlsEnabled: false,
              markers: _markers,
            );
          },
        ),
        Positioned(
          top: 40.0,
          right: 16.0,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'ZoomInButton',
                onPressed: _zoomIn,
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'ZoomOutButton',
                onPressed: _zoomOut,
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _loadMapStyles() async {
    if (_darkMode) {
      _mapStyle = await rootBundle.loadString(Constants.darkMapStyleJson);
    } else {
      _mapStyle = "";
    }
  }
}
