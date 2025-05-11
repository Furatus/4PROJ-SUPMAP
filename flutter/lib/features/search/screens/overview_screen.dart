import 'dart:async';
import 'dart:convert' as convert;
import 'dart:developer';

import 'package:custom_marker/marker_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_loadingkit/flutter_animated_loadingkit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:polyline_codec/polyline_codec.dart';
import 'package:provider/provider.dart';
import 'package:supmap/providers/google_maps_provider.dart';

import '../../../constants/constants.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/theme_notifier.dart';

class OverviewScreen extends StatefulWidget {
  final String? address;
  final Map<String, dynamic>? coordinates;

  const OverviewScreen({super.key, this.address, this.coordinates});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen>
    with WidgetsBindingObserver {
  late GoogleMapController mapController;
  final String? apiUrl = dotenv.env['SERVER_API_URL'];
  Position? _currentPosition;
  List<Polyline> myRouteList = [];
  List<Marker> markerList = [];
  final List<Map<String, dynamic>> _itinerarys = [];
  Map<String, dynamic> _currentItinerary = {};
  bool _isLoading = true;
  String distance = "Calcul...";
  String duration = "Calcul...";
  bool hasToll = false;
  bool useToll = true;
  bool _darkMode = false;
  String _mapStyle = '';
  List<Color> routeColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red
  ];
  UserProvider? userProvider; // Initialisation de userProvider

  BitmapDescriptor? startIcon;
  BitmapDescriptor? endIcon;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    userProvider = Provider.of<UserProvider>(context, listen: false);

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

    // Préchargement des icônes de début et de fin
    MarkerIcon.markerFromIcon(Icons.flag_rounded, Colors.blue, 100)
        .then((icon) {
      startIcon = icon;
    });

    MarkerIcon.markerFromIcon(Icons.sports_score_rounded, Colors.black, 100)
        .then((icon) {
      endIcon = icon;
    });
  }

  Future<void> _initializeScreen() async {
    await _getCurrentLocation();
    if (_currentPosition != null) {
      getRouteFromAPI();
    } else {
      print("Impossible de récupérer la position actuelle !");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              "Votre position → ${widget.address ?? "Destination inconnue"}")),
      body: Consumer<GoogleMapProvider>(
          builder: (context, googleMapProvider, child) {
        return Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition != null
                      ? LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude)
                      : LatLng(widget.coordinates!["lat"],
                          widget.coordinates!["lon"]),
                  zoom: 14,
                ),
                polylines: Set<Polyline>.from(myRouteList),
                markers: Set<Marker>.from(markerList),
                style: _mapStyle,
                onMapCreated: (controller) {
                  if (googleMapProvider.controller == null) {
                    googleMapProvider.setController(controller);
                  }
                  mapController = controller;

                  // Ajuste la caméra immédiatement si un itinéraire est déjà chargé
                  if (myRouteList.isNotEmpty) {
                    Future.delayed(Duration(milliseconds: 300), () {
                      List<LatLng> routePoints = myRouteList.first.points;
                      if (routePoints.isNotEmpty) {
                        LatLngBounds bounds = _getLatLngBounds(routePoints);
                        mapController.animateCamera(
                            CameraUpdate.newLatLngBounds(bounds, 80));
                      }
                    });
                  }
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _itinerarys.isEmpty
                      ? _isLoading
                          ? Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: AnimatedLoadingJumpingDots(
                                  speed: const Duration(milliseconds: 600),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                "Aucun itinéraire disponible",
                                style: TextStyle(
                                    fontSize: 16, fontStyle: FontStyle.italic),
                              ),
                            )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _itinerarys.length,
                          itemBuilder: (context, index) {
                            var itinerary = _itinerarys[index];
                            bool isSelected = itinerary == _currentItinerary;
                            // Couleur associée à cet itinéraire.
                            final itineraryColor =
                                routeColors[index % routeColors.length];

                            double itinDistance =
                                (itinerary["distance"] as num).toDouble();
                            int itinDurationMilliSec =
                                (itinerary["time"] as num).toInt();
                            bool hasToll = itinerary["details"] != null &&
                                itinerary["details"]["toll"] != null &&
                                (itinerary["details"]["toll"] as List)
                                    .any((toll) => toll[2] == "all");
                            String itinDuration =
                                formatDuration(itinDurationMilliSec);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentItinerary = itinerary;
                                });
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            itineraryColor
                                                .withAlpha((0.4 * 255).toInt()),
                                            itineraryColor
                                                .withAlpha((0.2 * 255).toInt()),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : Theme.of(context).cardColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: isSelected ? 6 : 4,
                                      offset: Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Card(
                                  elevation: 0,
                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: itineraryColor,
                                      child: Icon(
                                        Icons.directions_car,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    title: Text(
                                      "Itinéraire ${index + 1}${hasToll ? " (Péage)" : ""}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "Durée: $itinDuration ( ${(itinDistance / 1000).toStringAsFixed(1)} km )",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                    ),
                                    trailing: hasToll
                                        ? Icon(
                                            Icons.toll_rounded,
                                            color: Colors.red,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _currentItinerary.isEmpty
                        ? null
                        : () {
                            Navigator.of(context)
                                .pushNamed('/navigation', arguments: {
                              'address': widget.address,
                              'coordinates': widget.coordinates,
                              'itinerary': _currentItinerary,
                            });
                          },
                    icon: Icon(Icons.navigation),
                    label: Text('Démarrer'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/settings');
                    },
                    icon: Icon(Icons.settings),
                    label: Text('Paramètres'),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  void getRouteFromAPI() async {
    setState(() {
      _itinerarys.clear();
      myRouteList.clear();
      markerList.clear();
    });
    if (_currentPosition == null) {
      print("Position actuelle non disponible !");
      _isLoading = false;
      return;
    }

    log("GETTING ROUTE !!");

    final url = Uri.parse("$apiUrl/navigation/route");
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
        List<Polyline> newRouteList = [];
        List<Marker> newMarkerList = [];

        if (data.containsKey("paths") && data["paths"] != null) {
          _itinerarys.addAll((data["paths"] as List)
              .map((alt) => alt as Map<String, dynamic>));
        } else {
          log("Aucun itinéraire alternatif trouvé.");
        }

        // Sélectionne le premier itinéraire comme le principal
        if (_itinerarys.isNotEmpty) {
          _currentItinerary = _itinerarys.first;
        }

        // Décodage des polylignes et ajout sur la carte
        for (var i = 0; i < _itinerarys.length; i++) {
          var itinerary = _itinerarys[i];

          // Vérifier que "shape" existe bien
          if (itinerary["points"].isNotEmpty && itinerary["points"] != null) {
            final String encodedPolyline = itinerary["points"];
            final List<List<num>> decodedPolyline =
                PolylineCodec.decode(encodedPolyline, precision: 5);

            List<LatLng> myRoute = decodedPolyline
                .map(
                    (point) => LatLng(point[0].toDouble(), point[1].toDouble()))
                .toList();

            newRouteList.add(Polyline(
              polylineId: PolylineId("route_$i"),
              points: myRoute,
              color: routeColors[i % routeColors.length],
              // Change de couleur pour chaque itinéraire
              width: 5,
            ));
          }
        }

        if (_itinerarys.isNotEmpty && _itinerarys.first.containsKey("bbox")) {
          var startLocation = {
            "lat": _itinerarys.first["bbox"][1],
            "lon": _itinerarys.first["bbox"][0]
          };
          var endLocation = {
            "lat": _itinerarys.first["bbox"][3],
            "lon": _itinerarys.first["bbox"][2]
          };

          // Vérification des données avant d'ajouter les marqueurs
          if (startLocation["lat"] != null &&
              startLocation["lon"] != null &&
              endLocation["lat"] != null &&
              endLocation["lon"] != null) {
            newMarkerList.add(Marker(
                markerId: MarkerId("Départ"),
                position: LatLng(startLocation["lat"], startLocation["lon"]),
                icon: startIcon ?? BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(
                  title: "Départ",
                  snippet: "Votre position actuelle",
                )));

            newMarkerList.add(Marker(
                markerId: MarkerId("Arrivée"),
                position: LatLng(endLocation["lat"], endLocation["lon"]),
                icon: endIcon ?? BitmapDescriptor.defaultMarker,
                infoWindow: InfoWindow(
                  title: "Arrivée",
                  snippet: widget.address ?? "Destination inconnue",
                )));
          }
        }

        Future.delayed(Duration(milliseconds: 300), () async {
          if (myRouteList.isNotEmpty) {
            List<LatLng> routePoints = myRouteList.first.points;
            if (routePoints.isNotEmpty) {
              LatLngBounds bounds = _getLatLngBounds(routePoints);
              mapController
                  .animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
            }
          }
        });
        _isLoading = false;
        // Mise à jour de l'affichage
        setState(() {
          myRouteList = newRouteList;
          markerList = newMarkerList;
        });
      } else {
        print("Erreur HTTP: ${response.statusCode}");
        print(
            "Erreur lors de la récupération de l'itinéraire: ${response.body}");
      }
    } catch (e) {
      print('Erreur lors de la récupération de la route: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log("❌ Service de localisation désactivé !");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        log("❌ Permission de localisation refusée !");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Permission de localisation refusée définitivement !");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (_currentPosition == null ||
          _currentPosition!.latitude != position.latitude ||
          _currentPosition!.longitude != position.longitude) {
        setState(() {
          _currentPosition = position;
          log("Position actuelle : ${position.latitude}, ${position.longitude}");
        });
      }
    } catch (e) {
      log(" Erreur lors de la récupération de la position : $e");
    }
  }

  Future<void> _loadMapStyles() async {
    if (_darkMode) {
      _mapStyle = await rootBundle.loadString(Constants.darkMapStyleJson);
    } else {
      _mapStyle = "";
    }
  }

  String formatDuration(int milliSeconds) {
    int hours = (milliSeconds ~/ 3600000);
    int minutes = ((milliSeconds % 3600000) ~/ 60000);

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }

  // Fonction pour calculer les limites de l'itinéraire
  LatLngBounds _getLatLngBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
