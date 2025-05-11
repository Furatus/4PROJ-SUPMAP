import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:supmap/ui/widgets/snackbar_info.dart';

import '../../providers/user_provider.dart';

class IncidentSelectionWidget extends StatelessWidget {
  final LatLng incidentLocation;

  final String? apiUrl = dotenv.env['SERVER_API_URL'];
  final List<Map<String, dynamic>> incidentTypes = [
    {'icon': Icons.car_crash, 'label': 'Accident', 'color': Colors.red , 'value': 'accident'},
    {'icon': Icons.traffic, 'label': 'Embouteillages', 'color': Colors.orange, 'value': 'traffic_jam'},
    {'icon': Icons.block, 'label': 'Route barrée', 'color': Colors.deepPurple, 'value': 'road_closed'},
    {'icon': Icons.local_police, 'label': 'Contrôle policier', 'color': Colors.blue, 'value': 'police'},
    {'icon': Icons.warning, 'label': 'Objet sur la route', 'color': Colors.amber , 'value': 'object_on_road'}
  ];

  IncidentSelectionWidget({super.key, required this.incidentLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // **Titre**
          Text(
            'Que voulez-vous signaler ?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // **Grille d'icônes**
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 colonnes
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.1, // Proportion entre largeur et hauteur
            ),
            itemCount: incidentTypes.length,
            itemBuilder: (context, index) {
              final incident = incidentTypes[index];

              return GestureDetector(
                onTap: () => _addIncident(incident['value'], context),
                child: Column(
                  children: [
                    Ink(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: incident['color'].withOpacity(0.2), // Fond léger
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(
                          incident['icon'],
                          color: incident['color'],
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      incident['label'],
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // **Bouton Annuler**
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addIncident(String incidentType, BuildContext context) {
    log('Incident de type $incidentType au point $incidentLocation');


    final token = context.read<UserProvider>().token;

    final response = http.post(
      Uri.parse('$apiUrl/incidents/create'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'type': incidentType,
        'location': {
          'lat': incidentLocation.latitude,
          'lon': incidentLocation.longitude,
        },
      }),
    );
    response.then((res) {
      if (res.statusCode == 201) {
        // Si l'incident a été ajouté avec succès
        log('Incident ajouté avec succès');
        // Afficher un message de confirmation
        SnackbarInfo.show(context, 'Merci pour votre signalement !', 3,
            isError: false);
        Navigator.of(context).pop(); // Fermer le modal
      } else {
        // En cas d'erreur
        log('Erreur lors de l\'ajout de l\'incident: ${res.body}');
      }
    }).catchError((error) {
      log('Erreur de connexion: $error');
    });


  }
}
