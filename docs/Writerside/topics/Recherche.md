# Recherche

### Technologies utilisées
- Tailwind CSS : Pour le style responsive et rapide.
- React Hooks (useState, useEffect) : Gestion de l’état local (champ de saisie, résultats, etc.).
- @vis.gl/react-google-maps : Intégration de Google Maps pour afficher les trajets.
- @googlemaps/polyline-codec : Décodage des polylignes pour afficher des itinéraires.
### Fonctionnement

La barre de recherche permet à l’utilisateur de définir un point de départ et un point d’arrivée sur la carte. Une fois la recherche effectuée, l’utilisateur peut choisir parmi plusieurs itinéraires proposés. Les points de départ et d’arrivée sont affichés sur la carte avec des marqueurs personnalisés.
- L'utilisateur peut choisir d'éviter les péages.
- La recherche est effectuée en envoyant une requête au backend avec les coordonnées de départ et d’arrivée et les paramètres de recherche, qui surcharge avec les incidents, envoie la requete a GraphHopper et renvoie les résultats au frontend.
- L’itinéraire est récupéré sous forme de polyligne encodée.
- La polyligne est décodée avec @googlemaps/polyline-codec puis tracée sur la carte.

Ce mécanisme permet l'affichage fluide des itinéraires.

```dart
 // Créer des icônes SVG pour le départ et l'arrivée avec des couleurs différentes
    const startIconSVG = ReactDOMServer.renderToString(<MapPin color="green"/>);
    const endIconSVG = ReactDOMServer.renderToString(<MapPin color="red"/>);

    // Créer des objets Blob à partir des chaînes SVG
    const startSvgBlob = new Blob([startIconSVG], {type: 'image/svg+xml'});
    const endSvgBlob = new Blob([endIconSVG], {type: 'image/svg+xml'});
    const startSvgUrl = URL.createObjectURL(startSvgBlob);
    const endSvgUrl = URL.createObjectURL(endSvgBlob);

    useEffect(() => {
        if (itinerarys.length > 0) {
            // Supprimer les polylines existantes de la carte
            polylines.current.forEach(polyline => polyline.setMap(null));
            // Afficher le tracé de tous les itinéraires
            itinerarys.forEach((itinerary) => {
                const encodedShape = itinerary.points;
                const decodedCoordinates = decode(encodedShape, 5);
                const path = decodedCoordinates.map(coord => ({lat: coord[0], lng: coord[1]}));
                const weightShape = currentItinerary === itinerary ? 7 : 6;
                const opacityShape = currentItinerary === itinerary ? 1 : 0.5;

                const polyline = new window.google.maps.Polyline({
                    path: path,
                    strokeColor: '#0000FF', // Bleu
                    strokeOpacity: opacityShape,
                    strokeWeight: weightShape,
                    map: map,
                });
                // Gestionnaire d'événements pour le clic sur la polyline
                polyline.addListener('click', () => {
                    setCurrentItinerary(itinerary);
                });

                // Store the polyline in the ref
                polylines.current.push(polyline);
            });
            // Afficher les marqueurs de départ et d'arrivée
            const startMarker = new window.google.maps.Marker({
                position: {lat: startCoordinates.lat, lng: startCoordinates.lon},
                map: map,
                icon: {
                    url: startSvgUrl,
                    scaledSize: new window.google.maps.Size(30, 30),
                },
                title: 'Départ',
            });
            const endMarker = new window.google.maps.Marker({
                position: {lat: endCoordinates.lat, lng: endCoordinates.lon},
                map: map,
                icon: {
                    url: endSvgUrl,
                    scaledSize: new window.google.maps.Size(30, 30),
                },
                title: 'Arrivée',
            });
            markers.current.push(startMarker);
            markers.current.push(endMarker);
        }
    }, [itinerarys, currentItinerary, map]);
```