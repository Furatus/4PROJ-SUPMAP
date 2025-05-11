import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supmap/app_routes.dart';
import 'package:supmap/features/home/home_screen.dart';
import 'package:supmap/ui/theme/app_theme.dart';
import 'package:supmap/utils/theme_notifier.dart';
import 'package:supmap/providers/user_provider.dart';
import 'package:supmap/providers/google_maps_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_links/app_links.dart';

void main() async {
  // Charger les variables d'environnement
  await dotenv.load(fileName: ".env");
  HttpOverrides.global = MyHttpOverrides();

  // Créer une instance de UserProvider
  final userProvider = UserProvider();

  // Charger le thème depuis le stockage sécurisé
  await loadTheme();


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userProvider),
        ChangeNotifierProvider(create: (_) => GoogleMapProvider()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, themeMode, _) {
          return AppLinksWidget(
            child: MaterialApp(
              locale: const Locale('fr', 'FR'),
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
                  child: child!,
                );
              },
              color: Colors.teal,
              title: 'SupMap',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home:  const HomeScreen(),
              routes: AppRoutes.routes,
            ),
          );
        },
      ),
    ),
  );
}

// Fonction pour charger l'utilisateur depuis SecureStorage
Future<void> loadUserFromStorage(UserProvider userProvider) async {
  final storage = FlutterSecureStorage();
  final userJson = await storage.read(key: 'user');
  if (userJson != null) {
    final user = jsonDecode(userJson);
    userProvider.setUser(user);  // Charger l'utilisateur dans le Provider
  }
}
class AppLinksWidget extends StatefulWidget {
  final Widget child;

  const AppLinksWidget({super.key, required this.child});

  @override
  _AppLinksWidgetState createState() => _AppLinksWidgetState();
}

class _AppLinksWidgetState extends State<AppLinksWidget> {
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _listenToAppLinks();
  }

  void _listenToAppLinks() {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        // Traitez l'URI ici
        print('App Link reçu : $uri');
        // Naviguez ou effectuez une action en fonction de l'URI
        if (uri.pathSegments.isNotEmpty) {
          final path = uri.pathSegments[0];
          if (path == 'overview') {
            // Naviguer vers l'écran de visualisation d'itinéraire (pour que si quelqu'un scanne le QR code, il soit redirigé vers l'écran de visualisation d'itinéraire)
            Navigator.pushNamed(
              context,
              '/overview',
              arguments: {
                'address': uri.queryParameters['address'],
                'coordinates': {
                  'lat': uri.queryParameters['lat'],
                  'lon': uri.queryParameters['lon'],
                },
              },
            );
          } else  {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}