# Incidents

### Technologies utilisées
- Google Maps Flutter (LatLng)
- HTTP (http package pour les requêtes REST)
- Socket.IO (socket_io_client pour les événements en temps réel)
- StreamController (pour diffuser les incidents en temps réel)

###  Fonctionnement
Le module de gestion des incidents permet aux utilisateurs de signaler, recevoir et confirmer des incidents en temps réel sur la carte. Il repose sur une communication entre le client Flutter et un serveur distant via HTTP et WebSocket. Le flux global s’articule autour de trois composantes clés :

###### Signalement d’un incident
Lorsqu’un utilisateur repère un incident (ex. : embouteillage, accident), il peut cliquer sur un bouton dans l’interface de navigation pour ouvrir le widget de sélection d’incident (IncidentSelectionWidget). Une grille d’icônes lui permet de choisir le type d’incident.
Une fois un incident sélectionné :
- Une requête HTTP POST est envoyée au serveur (/incidents/create) avec :
  - le type d’incident
  - la position GPS actuelle
- Une confirmation est affichée à l’utilisateur (via un SnackBar).

###### Diffusion en temps réel des incidents
Le service d’incident (IncidentService) établit une connexion WebSocket sécurisée avec le serveur grâce au token utilisateur. Ce service :
- écoute les événements new_incident émis par le backend
- diffuse les incidents reçus via un StreamController
- peut être utilisé par d’autres widgets pour réagir aux incidents en temps réel

De plus ce n'est que les nouveaux incident qui utilise la technologie websocket.
Par ailleurs, ce service envoie périodiquement la position de l’utilisateur toutes les 5 minutes, ce qui permet d’identifier les utilisateurs proches d’un incident.

###### Confirmation ou infirmation d’un incident
Lorsqu’un incident est détecté proche de la position de l’utilisateur, le serveur envoie une notification en temps réel via WebSocket. Cette donnée est interceptée et transmise à l’UI, qui affiche un widget de confirmation (IncidentConfirmationWidget).
Ce widget :
- affiche les détails de l’incident avec un compte à rebours visuel
- propose deux actions :
  - Confirmer l’incident (GET /incidents/confirm/:id)
  - Refuser l’incident (GET /incidents/refute/:id)
- se ferme automatiquement après 10 secondes si aucune action n’est prise

Cette validation contribue à filtrer les faux signalements et à renforcer la fiabilité des informations affichées aux autres utilisateurs.

### Signaler un incident :
```dart
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
```

### Confirmer ou rejeter un incident :
```dart
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
```

### Réception d’un incident via WebSocket:
```dart
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
```