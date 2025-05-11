import 'package:flutter/material.dart';
import 'package:supmap/features/account/account_page.dart';
import 'package:supmap/features/account/login_screen.dart';
import 'package:supmap/features/account/register_screen.dart';
import 'package:supmap/features/navigation/screens/navigation_screen.dart';
import 'package:supmap/features/search/screens/overview_screen.dart';
import 'package:supmap/features/settings/screens/settings_screen.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/navigation': (BuildContext context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return NavigationScreen(
        address: args?['address'],
        coordinates: args?['coordinates'],
        itinerary: args?['itinerary'],
      );
    },
    '/overview': (BuildContext context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return OverviewScreen(
        address: args?['address'],
        coordinates: args?['coordinates'],
      );
    },
    '/settings': (BuildContext context) => const SettingsScreen(),
    '/account': (BuildContext context) => const AccountPage(),
    '/login': (BuildContext context) => LoginScreen(),
    '/register': (BuildContext context) => RegisterScreen(),
  };
}
