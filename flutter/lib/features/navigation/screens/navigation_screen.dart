import 'dart:async';
import 'dart:convert' as convert;
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:maps_toolkit/maps_toolkit.dart' as mtk;
import 'package:permission_handler/permission_handler.dart';
import 'package:polyline_codec/polyline_codec.dart';
import 'package:provider/provider.dart';
import 'package:supmap/constants/constants.dart';
import 'package:supmap/core/services/permission_provider.dart';
import 'package:supmap/features/incidents/incident_confirmation_widget.dart';
import 'package:supmap/features/incidents/incident_selection_widget.dart';
import 'package:supmap/ui/widgets/snackbar_info.dart';
//Incidents
import 'package:supmap/features/incidents/incident_service.dart';
import 'package:supmap/features/navigation/widgets/bottom_instructions_bar_widget.dart';
import 'package:supmap/features/navigation/widgets/route_instructions.dart';
import 'package:supmap/providers/user_provider.dart';

class NavigationScreen extends StatefulWidget {
  final String? address;
  final Map<String, dynamic>? coordinates;
  final Map<String, dynamic>? itinerary;

  const NavigationScreen(
      {super.key, this.address, this.coordinates, this.itinerary});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with WidgetsBindingObserver {
  late GoogleMapController mapController;
  late IncidentService _incidentService;
  final LatLng _initialCameraPosition = const LatLng(47.3779, 0.4913);
  final String? apiUrl = dotenv.env['GRAPHHOPPER_API_URL'];
  final String? serverUrl = dotenv.env['SERVER_API_URL'];
  Map<String, dynamic> _currentItinerary = {};
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  List<Marker> markerList = [];
  List<List<dynamic>> speedLimits = [];
  StreamSubscription<Position>? _positionStream;
  Position? _currentPosition;
  Position? _lastPosition;
  Marker? myLocationMarker;
  List<Polyline> myRouteList = [];
  List<LatLng> allRoutePoints = [];
  List<dynamic> maneuvers = [];
  UserProvider? userProvider;

  List<Marker> iconMarkers = [];
  BitmapDescriptor? directionIcon;

  Map<String, dynamic> _currentManeuver = {
    'text': 'Départ',
    'type': 8,
    'interval': [0, 0],
    'sign': 0,
  };
  String _currentRemainingDistance = "--";
  String _currentTotalRemainingDistance = "--";
  int _currentSpeed = 0;
  String _currentSpeedLimit = "--";
  double _currentZoomLevel = 16.0;
  DateTime _estimatedArrivalTime = DateTime.now();
  int _totalRemainingTime = 0;

  String _currentStreetName = "Route inconnue";
  bool _darkMode = false;
  String _mapStyle = '';

  // Timer pour envoyer la position toutes les 10 minutes
  Timer? _locationUpdateTimer;

  // Incidents
  List<Map<String, dynamic>> incidents = [];
  List<Marker> incidentMarkers = [];

  // Gérer la tolérance de la position
  int toleranceRecalcul = 50;

  @override
  void initState() {
    super.initState();
    _incidentService = IncidentService();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _incidentService.connect(context);
      // Si  l'incident est pas loin sur la route, afficher la notification
      _incidentService.incidentStream.listen((incident) async {
        print('Nouvel incident reçu dans NavigationScreen: $incident');

        incidents.add(incident);
        checkIncidentsOnRoad();
      });
      setCustomIconForUserLocation();
      _loadMapStyles().then((_) {
        setState(() {});
      });
    });
  }

  Future<void> _startLocationUpdateTimer() async {
    // Attendre que _currentPosition ne soit pas null
    while (_currentPosition == null) {
      await Future.delayed(Duration(milliseconds: 500));
    }

    // Envoyer la position immédiatement lors du démarrage
    print("Sending initial location to server");
    _incidentService.sendLocationToServer(
      context,
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
    );
    fetchExistingIncidents();

    // Initialiser le Timer pour envoyer la position toutes les 5 minutes
    _locationUpdateTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      if (_currentPosition != null) {
        _incidentService.sendLocationToServer(
          context,
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        );
        fetchExistingIncidents();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _incidentService.disconnect();
    _positionStream?.cancel();
    _locationUpdateTimer?.cancel();
    if (mounted) {
      mapController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
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

          // Instructions en haut
          Positioned(
            top: 30.0,
            left: 10.0,
            right: 10.0,
            child: Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: RouteInstructionsWidget(
                maneuver: _currentManeuver,
                distance: _currentRemainingDistance,
              ),
            ),
          ),

          // Colonne contenant les boutons de limite de vitesse et signalement d'incident
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bouton affichant la limite de vitesse (côté gauche)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.red, width: 5),
                        ),
                        child: Center(
                          child: Text(
                            _currentSpeedLimit,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Bouton pour signaler un incident (côté droit)
                      FloatingActionButton(
                        backgroundColor: Colors.teal,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            Icon(Icons.warning, color: Colors.white, size: 28),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            clipBehavior: Clip.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            builder: (context) => IncidentSelectionWidget(
                              incidentLocation: LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Instructions de navigation en bas
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: BottomInstructionsBarWidget(
              currentSpeed: _currentSpeed,
              totalRemainingDistance: _currentTotalRemainingDistance,
              estimatedArrivalTime: _estimatedArrivalTime,
              totalRemainingTime: _totalRemainingTime,
            ),
          ),

          // Route actuelle en bas de la carte
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _currentStreetName,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setCustomIconForUserLocation() {
    Future<Uint8List> getBytesFromAsset(String path, int width) async {
      ByteData data = await rootBundle.load(path);
      Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
          targetWidth: width);
      FrameInfo fi = await codec.getNextFrame();
      return (await fi.image.toByteData(format: ImageByteFormat.png))!
          .buffer
          .asUint8List();
    }

    getBytesFromAsset('assets/user_location.png', 64).then((onValue) {
      markerIcon = BitmapDescriptor.bytes(onValue);
    });
  }

  Future<void> _loadMapStyles() async {
    if (_darkMode) {
      _mapStyle = await rootBundle.loadString(Constants.darkMapStyleJson);
    } else {
      _mapStyle = "";
    }
  }

  void checkPermissionAndListenLocation() {
    PermissionProvider.handleLocationPermission().then((_) {
      if (_positionStream == null &&
          PermissionProvider.isServiceOn &&
          PermissionProvider.locationPermission == PermissionStatus.granted) {
        startListeningLocation();
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> initializeItinerary() async {
    final String encodedPolyline = _currentItinerary["points"];
    final List<List<num>> decodedPolyline =
        PolylineCodec.decode(encodedPolyline, precision: 5);

    // Convertir le List<List<num>> en List<LatLng>
    List<LatLng> myRoute = decodedPolyline
        .map((point) => LatLng(point[0].toDouble(), point[1].toDouble()))
        .toList();

    allRoutePoints = myRoute;

    myRouteList.add(Polyline(
        polylineId: const PolylineId("route"),
        points: myRoute,
        color: Colors.blue,
        width: 10));
    if (mounted) setState(() {});

    maneuvers = _currentItinerary["instructions"];
    _currentManeuver = maneuvers[0];
    _currentStreetName = _currentManeuver["street_name"] ?? "Route inconnue";
    speedLimits = (_currentItinerary["details"]["max_speed"] as List)
        .map((e) => e as List<dynamic>)
        .toList();

    navigationProcess();
  }

  Future<void> startListeningLocation() async {
    _positionStream = Geolocator.getPositionStream(
            locationSettings: LocationSettings(accuracy: LocationAccuracy.high))
        .listen((Position? position) {
      _currentPosition = position;
      if (_currentPosition != null && _currentItinerary.isNotEmpty) {
        navigationProcess();
      }
    });

    //Initialiser le depart de la navigation

    // Vérifie si l'itinéraire initial est déjà chargé
    if (widget.itinerary == null) {
      getNewRouteFromAPI();
    } else {
      _currentItinerary = widget.itinerary ?? {};
      initializeItinerary();
    }
    _startLocationUpdateTimer();

    /*// Initialiser le Timer pour envoyer la position toutes les 5 minutes
    _startLocationUpdateTimer();*/
    if (mounted) setState(() {});
  }

  void showMyLocationOnMap() {
    if (_currentPosition == null) return;
    markerList.removeWhere((e) => e.markerId == MarkerId("myLocation"));
    myLocationMarker = Marker(
        markerId: MarkerId("myLocation"),
        position:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        icon: markerIcon,
        anchor: const Offset(0.5, 0.5),
        zIndex: 3);

    LatLng adjustedTarget =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: adjustedTarget,
      zoom: _currentZoomLevel,
      bearing: _currentPosition!.heading,
    )));

    if (markerIcon != BitmapDescriptor.defaultMarker) {
      markerList.add(myLocationMarker!);
    }
    if (mounted) setState(() {});
  }

  void navigationProcess() {
    if (myRouteList.isEmpty || _currentPosition == null || maneuvers.isEmpty) {
      return;
    }

    //Mettre à jour la position de l'utilisateur
    showMyLocationOnMap();

    mtk.LatLng myPosition =
        mtk.LatLng(_currentPosition!.latitude, _currentPosition!.longitude);


    List<mtk.LatLng> allLatLngList = allRoutePoints
        .map((point) => mtk.LatLng(point.latitude, point.longitude))
        .toList();

    int globalclosestIndex = mtk.PolygonUtil.locationIndexOnPath(
        myPosition, allLatLngList, true,
        tolerance: toleranceRecalcul);
    if (globalclosestIndex == -1) {
        getNewRouteFromAPI();
        return;
    }

    for (int i = 0; i < maneuvers.length; i++) {
      int startIndex = (maneuvers[i]["interval"][0] as num).toInt();
      int endIndex = (maneuvers[i]["interval"][1] as num).toInt();

      if (globalclosestIndex >= startIndex && globalclosestIndex <= endIndex) {
        // Mise à jour de la manœuvre actuelle
        _currentManeuver = maneuvers[i];

        // Calcul de la distance restante jusqu'à la prochaine instruction
        int? nextBeginIndex;
        if (i + 1 < maneuvers.length) {
          nextBeginIndex = maneuvers[i + 1]["interval"][0];
        }

        // On somme la distance jusqu'à nextBeginIndex
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
        break; // Sortir de la boucle une fois la manœuvre trouvée
      }
    }
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
    checkIncidentsOnRoad();
    if (mounted) setState(() {});
  }

  void getNewRouteFromAPI() async {
    if (myRouteList.isNotEmpty) myRouteList.clear();
    if (maneuvers.isNotEmpty) maneuvers.clear();

    log("GETTING NEW ROUTE !!");
    SnackbarInfo.show(context, 'Recalcul de l\'itinéraire en cours...', 3,
        isError: false);

    // Appel API
    final url = Uri.parse("$apiUrl/route");

    final routeBody = {
      "points": [
        [
          _currentPosition!.longitude,
          _currentPosition!.latitude,
        ],
        [widget.coordinates!["lon"], widget.coordinates!["lat"]]
      ],
      "profile": "car",
      "locale": "fr",
      "calc_points": true,
      "points_encoded": true,
      "algorithm": "alternative_route",
      "details": ["toll", "max_speed"],
      "toll": userProvider!.useToll ? true : false,
    };
    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: convert.jsonEncode(routeBody));
      if (response.statusCode == 200) {
        final data =
            convert.jsonDecode(convert.utf8.decode(response.bodyBytes));
        _currentItinerary = data["paths"][0];
        initializeItinerary();
      } else {
        print(
            'Erreur lors de la récupération de la route. Code d\'erreur: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération de la route: $e');
    }

    if (mounted) setState(() {});
  }

  Future<void> fetchExistingIncidents() async {
    print("Fetching existing incidents");
    final url = Uri.parse("$serverUrl/incidents/get/nearme");
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${userProvider!.token}',
        },
      );
      if (response.statusCode == 200) {
        final data =
            convert.jsonDecode(convert.utf8.decode(response.bodyBytes));
        incidents = List<Map<String, dynamic>>.from(data);
        print("Incidents: $incidents");
        for (var incident in incidents) {
          final customIcon = getCustomIcon(incident['type']);
          incidentMarkers.add(Marker(
            markerId: MarkerId(incident['id'].toString()),
            position: LatLng(
                incident['location']['lat'], incident['location']['lon']),
            icon: await customIcon,
            infoWindow: InfoWindow(
              title: incident['type'],
              snippet: incident['description'],
            ),
          ));
        }
      } else {
        print(
            'Erreur lors de la récupération des incidents. Code d\'erreur: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des incidents: $e');
    }
  }

  String formatDistance(double distance) {
    if (distance < 1000) {
      return "${(distance / 10).round() * 10} m";
    }
    if (distance < 10000) {
      return "${(distance / 1000).toStringAsFixed(1)} km";
    } else {
      return "${(distance / 1000).round()} km";
    }
  }

  void checkIncidentsOnRoad() {
    if (_currentPosition == null) return;
    for (var incident in incidents) {
      if (incident['isDisplayed'] == true) return;
      num distance = mtk.SphericalUtil.computeDistanceBetween(
        mtk.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        mtk.LatLng(incident['location']['lat'], incident['location']['lon']),
      );
      if (distance < 100 ) {
        // Si l'incident est à moins de 100 mètres de la position actuelle
        // On verifie qu'il est devant sur la route(Polyline)
        if (allRoutePoints.isNotEmpty) {
          int closestIndex = mtk.PolygonUtil.locationIndexOnPath(
              mtk.LatLng(
                  _currentPosition!.latitude, _currentPosition!.longitude),
              allRoutePoints
                  .map((point) => mtk.LatLng(point.latitude, point.longitude))
                  .toList(),
              true,
              tolerance: 12);
          if (closestIndex != -1 && closestIndex < allRoutePoints.length - 1) {
            // Si l'incident est devant sur la route
            // Ajouter a l'incident un champ "isDisplayed" pour ne pas le réafficher
            incident['isDisplayed'] = true;
            // Afficher la notification
            showIncidentConfirmationDialog(context, incident);
          }
        }
      }
    }
  }

  void _calculateSpeed() {
    if (_currentPosition == null) return;
    if (_lastPosition != null) {
      final num distance = mtk.SphericalUtil.computeDistanceBetween(
        mtk.LatLng(_lastPosition!.latitude, _lastPosition!.longitude),
        mtk.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      );
      final int? timeInSeconds = _currentPosition?.timestamp
          .difference(_lastPosition!.timestamp)
          .inSeconds;
      if (timeInSeconds! > 0) {
        _currentSpeed = (distance / timeInSeconds * 3.6).round(); // km/h
      }
    }
    _lastPosition = _currentPosition;
    if (mounted) setState(() {});
  }

  double getZoomLevel(double distance) {
    double targetZoom;
    if (distance > 5000) {
      targetZoom = 12.0;
    } else if (distance > 3000) {
      targetZoom = 13.0;
    } else if (distance > 1500) {
      targetZoom = 14.0;
    } else if (distance > 700) {
      targetZoom = 15.0;
    } else if (distance > 300) {
      targetZoom = 16.0;
    } else if (distance > 100) {
      targetZoom = 17.0;
    } else {
      targetZoom = 18.0;
    }

    // Lissage pour éviter les changements brutaux
    double smoothingFactor =
        0.15; // Plus c'est bas, plus le changement est fluide
    _currentZoomLevel =
        _currentZoomLevel + (targetZoom - _currentZoomLevel) * smoothingFactor;

    return _currentZoomLevel;
  }

  void showIncidentConfirmationDialog(BuildContext context, incidentData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      isDismissible: true,
      builder: (context) => IncidentConfirmationWidget(
        incidentData: incidentData,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      clipBehavior: Clip.none,
    );
  }

  Future<BitmapDescriptor> getCustomIcon(String type) async {
    String assetPath;
    switch (type) {
      case 'accident':
        assetPath = 'assets/incidents/accident.png';
        break;
      case 'traffic_jam':
        assetPath = 'assets/incidents/traffic_jam.png';
        break;
      case 'road_closed':
        assetPath = 'assets/incidents/road_closed.png';
        break;
      case 'police':
        assetPath = 'assets/incidents/police.png';
        break;
      case 'object_on_road':
        assetPath = 'assets/incidents/object_on_road.png';
        break;
      default:
        assetPath = 'assets/incidents/object_on_road.png';
    }

    return await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      assetPath,
    );
  }
}
