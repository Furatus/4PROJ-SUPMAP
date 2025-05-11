import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';

class IncidentConfirmationWidget extends StatefulWidget {
  final Map<String, dynamic> incidentData;

  const IncidentConfirmationWidget({
    super.key,
    required this.incidentData,
  });

  @override
  State<IncidentConfirmationWidget> createState() =>
      _IncidentConfirmationWidgetState();
}

class _IncidentConfirmationWidgetState extends State<IncidentConfirmationWidget>
    with SingleTickerProviderStateMixin {
  late String token;
  late AnimationController _progressController;
  bool _hasInteracted = false;

  final List<Map<String, dynamic>> incidentTypes = [
    {
      'icon': Icons.car_crash,
      'label': 'Accident',
      'color': Colors.red,
      'value': 'accident'
    },
    {
      'icon': Icons.traffic,
      'label': 'Embouteillages',
      'color': Colors.orange,
      'value': 'traffic_jam'
    },
    {
      'icon': Icons.block,
      'label': 'Route barrée',
      'color': Colors.deepPurple,
      'value': 'road_closed'
    },
    {
      'icon': Icons.local_police,
      'label': 'Contrôle policier',
      'color': Colors.blue,
      'value': 'police'
    },
    {
      'icon': Icons.warning,
      'label': 'Objet sur la route',
      'color': Colors.amber,
      'value': 'object_on_road'
    },
  ];

  final String apiUrl = dotenv.env['SERVER_API_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    token = userProvider.token!;

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    // Fermer automatiquement la modal après 5 secondes
    Future.delayed(const Duration(seconds: 10), () {
      if (!_hasInteracted && mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Map<String, dynamic> getIncidentType(String type) {
    return incidentTypes.firstWhere(
      (element) => element['value'] == type,
      orElse: () => {
        'icon': Icons.help_outline,
        'label': 'Inconnu',
        'color': Colors.grey
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final incidentType = getIncidentType(widget.incidentData['type']);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barre de progression animée
          LinearProgressIndicator(
            value: _progressController.value,
            valueColor: AlwaysStoppedAnimation<Color>(incidentType['color']),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(height: 16),

          CircleAvatar(
            radius: 36,
            backgroundColor: incidentType['color'],
            child: Icon(
              incidentType['icon'],
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${incidentType['label']} sur votre itinéraire',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Toujours là ?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Confirmer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _hasInteracted = true;
                  _confirmIncident(context);
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Il n\'est plus là'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _hasInteracted = true;
                  _rejectIncident(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmIncident(BuildContext context) async {
    final response = await http.get(
      Uri.parse('$apiUrl/incidents/confirm/${widget.incidentData['_id']}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la confirmation de l\'incident')),
      );
      log('Erreur confirmation incident: ${response.statusCode}');
      log('Body: ${response.body}');
    }
  }

  Future<void> _rejectIncident(BuildContext context) async {
    final response = await http.get(
      Uri.parse('$apiUrl/incidents/refute/${widget.incidentData['_id']}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du rejet de l\'incident')),
      );
      log('Erreur rejet incident: ${response.statusCode}');
      log('Body: ${response.body}');
    }
  }
}
