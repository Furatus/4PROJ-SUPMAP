import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapProvider extends ChangeNotifier {
  GoogleMapController? _controller;

  GoogleMapController? get controller => _controller;

  void setController(GoogleMapController controller) {
    _controller = controller;
    notifyListeners();
  }
}
