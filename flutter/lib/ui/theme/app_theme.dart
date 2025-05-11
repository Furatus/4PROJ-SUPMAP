import 'package:flutter/material.dart';

class AppTheme {
  // Thème clair (nuances de vert)
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF047857),
    // Teal 600
    scaffoldBackgroundColor: const Color(0xFFF0FDF4),
    // Teal 100 (plus léger)
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF047857), // Teal 600
      foregroundColor: Colors.white,
      elevation: 4.0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.teal,
      brightness: Brightness.light,
      backgroundColor: const Color(0xFFE0F2F1), // Light Teal background
    ),
    switchTheme: SwitchThemeData(
      thumbColor:
          WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.teal;
        }
        return Colors.grey;
      }),
      trackColor:
          WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.teal.withOpacity(0.5);
        }
        return Colors.grey.withOpacity(0.5);
      }),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87, fontSize: 16.0),
      bodyMedium: TextStyle(color: Colors.black54, fontSize: 14.0),
    ),
    iconTheme: const IconThemeData(
      color: Colors.black54,
    ),
    dividerColor: Colors.black12,
    cardColor: Colors.white,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF047857),
      unselectedItemColor: Colors.grey,
    ),
    // Autres propriétés de thème...
  );

  // Thème sombre (nuances de vert foncé)
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF047857),
    // Teal 600
    scaffoldBackgroundColor: const Color(0xFF1A2E35),
    // Dark Teal background
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0E4D40), // Dark Teal
      foregroundColor: Colors.white,
      elevation: 4.0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.teal,
      brightness: Brightness.dark,
      backgroundColor: const Color(0xFF1A2E35), // Dark Teal background
    ),
    switchTheme: SwitchThemeData(
      thumbColor:
          WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return Colors
              .tealAccent; // Couleur du pouce lorsque le switch est activé
        }
        return Colors.grey; // Couleur du pouce lorsque le switch est désactivé
      }),
      trackColor:
          WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.tealAccent.withOpacity(
              0.5); // Couleur de la piste lorsque le switch est activé
        }
        return Colors.grey.withOpacity(
            0.5); // Couleur de la piste lorsque le switch est désactivé
      }),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70, fontSize: 16.0),
      bodyMedium: TextStyle(color: Colors.white60, fontSize: 14.0),
    ),
    iconTheme: const IconThemeData(
      color: Colors.white60,
    ),
    dividerColor: Colors.white12,
    cardColor: const Color(0xFF2E404E),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A2E35),
      selectedItemColor: Color(0xFF047857),
      unselectedItemColor: Colors.grey,
    ),
    // Autres propriétés de thème...
  );
}
