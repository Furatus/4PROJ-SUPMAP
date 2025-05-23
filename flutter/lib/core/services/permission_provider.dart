import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supmap/constants/constants.dart';
import 'package:supmap/ui/widgets/custom_dialog.dart';

class PermissionProvider {
  static PermissionStatus locationPermission = PermissionStatus.denied;
  static DialogRoute? permissionDialogRoute;
  static bool isServiceOn = false;

  static Future<void> handleLocationPermission() async {
    isServiceOn = await Permission.location.serviceStatus.isEnabled;
    locationPermission = await Permission.location.status;
    if (isServiceOn) {
      switch (locationPermission) {
        case PermissionStatus.permanentlyDenied:
          permissionDialogRoute = myCustomDialogRoute(
              title: "Location Service",
              text:
                  "To use navigation, please allow location usage in settings.",
              buttonText: "Go To Settings",
              onPressed: () {
                Navigator.of(Constants.globalNavigatorKey.currentContext!)
                    .removeRoute(PermissionProvider.permissionDialogRoute!);
                openAppSettings();
              });
          Navigator.of(Constants.globalNavigatorKey.currentContext!)
              .push(permissionDialogRoute!);
        case PermissionStatus.denied:
          Permission.location.request().then((value) {
            locationPermission = value;
          });
          break;
        default:
      }
    } else {
      permissionDialogRoute = myCustomDialogRoute(
          title: "Location Service",
          text: "To use navigation, please turn location service on.",
          buttonText: Platform.isAndroid ? "Turn It On" : "Ok",
          onPressed: () {
            Navigator.of(Constants.globalNavigatorKey.currentContext!)
                .removeRoute(PermissionProvider.permissionDialogRoute!);
            if (Platform.isAndroid) {
              const AndroidIntent intent =
                  AndroidIntent(action: Constants.androidLocationIntentAddress);
              intent.launch();
            }
          });
      Navigator.of(Constants.globalNavigatorKey.currentContext!)
          .push(permissionDialogRoute!);
    }
  }
}
