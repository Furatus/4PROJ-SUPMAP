import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supmap/providers/user_provider.dart';
import 'dart:convert';



class IncidentService {
  late IO.Socket _socket;
  final String apiUrl = dotenv.env['WEB_SOCKET_URL'] ?? '';
  late UserProvider userProvider;
  final serverUrl = dotenv.env['SERVER_API_URL'] ?? '';

  final StreamController<Map<String, dynamic>> _incidentController =
  StreamController.broadcast();

  Stream<Map<String, dynamic>> get incidentStream => _incidentController.stream;

  Future<void> connect(BuildContext context) async {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? token = userProvider.token;

    _socket = IO.io(
      apiUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          /*.enableAutoConnect()*/
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    _socket.onConnect((_) {
      print('Connecté au serveur WebSocket');
    });

    _socket.on('hello', (data) {
      print('Message de bienvenue: $data');
    });

    _socket.on('new_incident', (data) {
      _incidentController.add(Map<String, dynamic>.from(data['data'])); // << push dans le stream
    });

    _socket.onDisconnect((_) {
      print('Déconnecté du serveur WebSocket');
    });

    _socket.onError((error) {
      print('Erreur WebSocket: $error');
    });
  }

  void disconnect() {
    _incidentController.close(); // Fermer le stream proprement
    _socket.disconnect();
  }


  void sendLocationToServer(BuildContext context, LatLng location) {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? token = userProvider.token;

    final response = http.post(
      Uri.parse('$serverUrl/positiontracker/updatelocation'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // Ajout du type de contenu
      },
      body: jsonEncode({ // Sérialisation correcte du corps
        'location': {
          'lat': location.latitude,
          'lon': location.longitude,
        },
      }),
    );

    response.then((res) {
      if (res.statusCode == 200) {
        print('Localisation envoyée au serveur avec succès (5 min)');
      } else {
        print('Erreur lors de l\'envoi de la localisation: ${res.body}');
      }
    }).catchError((error) {
      print('Erreur de connexion: $error');
    });
  }
}
