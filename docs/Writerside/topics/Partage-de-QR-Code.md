# Partage de QR Code

### Technologies utilisées
- qrcode.react : Bibliothèque pour générer des QR codes à partir de l'url
- app_link : permet de créer des liens qui redirigent automatiquement l'utilisateur vers une application mobile installée,


### Fonctionnement

La fonctionnalité de partage de QR code permet à un utilisateur :
- De générer dynamiquement un QR code contenant un lien unique et de l'afficher dans une popup.
- De permettre à un autre utilisateur de scanner ce QR code avec un smartphone pour être redirigé automatiquement.
- De copier le lien associé dans le presse-papier.

Ce QR code encode l'url avec les coordonnées d'arrivée et non départ puisque l'itinéraire est toujours debuter a la postion de l'utilisateur.
L'utilisateur peut choisir l'itinéraire qu'il souhaite utiliser.

###### Code

Cette méthode écoute en continu les liens d'application (App Links) reçus lorsque l'utilisateur ouvre l'application via un QR code ou une URL spéciale.

**Détail du fonctionnement** :

- La méthode utilise le flux uriLinkStream pour surveiller en temps réel l'arrivée de liens (Uri).
- Lorsqu’un lien est reçu, elle l’analyse pour :
  - Vérifier si l'URL contient un chemin valide (overview, etc.). 
  - Extraire des paramètres comme l’adresse ou les coordonnées GPS. 
  - Naviguer automatiquement vers un écran spécifique de l'app, comme l’écran de visualisation d’itinéraire (/overview), avec les données incluses dans le lien.
- Si aucun chemin spécifique n’est détecté, elle redirige l'utilisateur vers l’écran principal (HomeScreen).

```dart
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
```