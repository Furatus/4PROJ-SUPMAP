import {Car, Clock, Crosshair, LoaderCircle, MapPin, Search, X} from 'lucide-react';
import {useEffect, useRef, useState} from 'react';
import axios from 'axios';
import {useMap, useMapsLibrary} from "@vis.gl/react-google-maps";
import {decode} from '@googlemaps/polyline-codec';
import {Switch} from "@headlessui/react";
import ReactDOMServer from 'react-dom/server';

export default function SearchPanel({
                                        setStartCoordinates,
                                        setEndCoordinates,
                                        startCoordinates,
                                        endCoordinates
                                    }) {

    const map = useMap();
    useMapsLibrary('places');
    const [activeInput, setActiveInput] = useState(null);
    const [startInputValue, setStartInputValue] = useState('');
    const [endInputValue, setEndInputValue] = useState('');
    const [startSuggestions, setStartSuggestions] = useState([]);
    const [endSuggestions, setEndSuggestions] = useState([]);
    const startInputRef = useRef(null);
    const endInputRef = useRef(null);
    const [isSearching, setIsSearching] = useState(false);
    const [itinerarys, setItinerarys] = useState([]);
    const [useToll, setUseToll] = useState(true);
    const [currentItinerary, setCurrentItinerary] = useState([]);
    const polylines = useRef([]);
    const markers = useRef([]);

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

    const handleGeolocation = () => {
        if (navigator.geolocation) {
            console.log('Géolocalisation activée');
            navigator.geolocation.getCurrentPosition((position) => {
                const {latitude, longitude} = position.coords;
                const name = `Ma position (${latitude.toFixed(4)}, ${longitude.toFixed(4)})`;
                const coords = {name, lat: latitude, lon: longitude};

                if (activeInput === 'start') {
                    setStartInputValue(name);
                    setStartCoordinates(coords);
                } else if (activeInput === 'end') {
                    setEndInputValue(name);
                    setEndCoordinates(coords);
                }
            }, (error) => {
                console.error('Erreur de géolocalisation :', error);
            });
        } else {
            console.error('La géolocalisation n\'est pas supportée par ce navigateur.');
        }
    };

    useEffect(() => {
        const handleClickOutside = (event) => {
            const isClickInsideSuggestion = event.target.closest('.suggestion-list') !== null;
            if (
                !isClickInsideSuggestion
            ) {
                setStartSuggestions([]);
                setEndSuggestions([]);
                setActiveInput(null);
            }
        };

        document.addEventListener('mousedown', handleClickOutside);

        return () => {
            document.removeEventListener('mousedown', handleClickOutside);
        };
    }, []);

    let timeoutId;
    const autocompleteAddress = (query, setSuggestions) => {
        clearTimeout(timeoutId);

        timeoutId = setTimeout(async () => {
            if (query.trim().length < 2) {
                setSuggestions([]);
                return;
            }

            try {
                const request = {
                    input: query,
                    key: import.meta.env.VITE_GOOGLE_MAPS_API_KEY,
                    componentRestrictions: {
                        country: 'fr',
                    },
                    language: 'fr',
                    region: 'fr',
                };
                const service = new window.google.maps.places.AutocompleteService();
                await service.getPlacePredictions(request, (predictions, status) => {
                    if (status === window.google.maps.places.PlacesServiceStatus.OK) {
                        const suggestions = predictions.map((prediction) => ({
                            address: prediction.description,
                            place_id: prediction.place_id,
                        }));
                        setSuggestions(suggestions);
                    } else {
                        console.error('Erreur lors de l\'autocomplétion :', status);
                    }
                });
            } catch (error) {
                console.error('Erreur lors de l\'autocomplétion :', error);
            }
        }, 300);
    };


    const handleSuggestionSelect = (suggestion, field) => {

        const service = new window.google.maps.places.PlacesService(map);
        service.getDetails({placeId: suggestion.place_id}, (place, status) => {
            if (status === window.google.maps.places.PlacesServiceStatus.OK) {
                const coords = {
                    name: place.formatted_address,
                    lat: place.geometry.location.lat(),
                    lon: place.geometry.location.lng(),
                };
                if (field === 'start') {
                    setStartInputValue(place.formatted_address);
                    setStartCoordinates(coords);
                    setStartSuggestions([]);
                } else if (field === 'end') {
                    setEndInputValue(place.formatted_address);
                    setEndCoordinates(coords);
                    setEndSuggestions([]);
                }
            } else {
                console.error('Erreur lors de la récupération des détails du lieu :', status);
            }
        });
    };

    const searchItinerary = () => {
        if (startCoordinates.lat === endCoordinates.lat && startCoordinates.lon === endCoordinates.lon) {
            alert('Le point de départ et la destination ne peuvent pas être les mêmes.');
            return;
        }
        if (startCoordinates.lat && startCoordinates.lon && endCoordinates.lat && endCoordinates.lon) {
            setIsSearching(true);
            // Remove existing polylines from the map
            polylines.current.forEach(polyline => polyline.setMap(null));
            polylines.current = [];

            // Remove existing markers from the map
            markers.current.forEach(marker => marker.setMap(null));
            markers.current = [];

            axios.post(`${import.meta.env.VITE_API_SERVER_URL}/navigation/route`,

                {
                    "points": [
                        [
                            startCoordinates.lon,
                            startCoordinates.lat
                        ],
                        [
                            endCoordinates.lon,
                            endCoordinates.lat
                        ]
                    ],
                    "profile": "car",
                    "locale": "fr",
                    "toll": useToll,
                    "algorithm": "alternative_route",
                    "calc_points": true,
                    "points_encoded": true,
                    "details": [
                        "toll"
                    ],
                })
                .then(response => {
                    const responseData = response.data;
                    setItinerarys([]);

                    const itinerarys = responseData.paths;
                    setItinerarys(itinerarys);

                    const bounds = new window.google.maps.LatLngBounds();
                    bounds.extend(new window.google.maps.LatLng(startCoordinates.lat, startCoordinates.lon));
                    bounds.extend(new window.google.maps.LatLng(endCoordinates.lat, endCoordinates.lon));
                    map.fitBounds(bounds);

                    setCurrentItinerary(itinerarys[0]);

                    setIsSearching(false);
                })
                .catch(error => {
                    console.error('Erreur lors de la recherche d\'itinéraire :', error);
                    setIsSearching(false);
                });

        } else {
            alert('Choisissez un point de départ et une destination dans les suggestions pour valider la recherche.');
        }
    };

    return (
        <div className="absolute left-0 w-[360px] bg-white shadow-lg h-auto m-2 top-16 rounded-lg">
            <div className="p-4">
                <div className="space-y-2">
                    <div className="relative">
                        <div className="flex items-center bg-gray-100 rounded-lg p-3 relative">
                            <MapPin size={20} className="text-teal-600 mr-2"/>
                            <input
                                ref={startInputRef}
                                type="text"
                                placeholder="Départ"
                                className="bg-transparent w-full focus:outline-none text-gray-700"
                                value={startInputValue}
                                onFocus={() => setActiveInput('start')}
                                onChange={(e) => {
                                    setStartInputValue(e.target.value);
                                    autocompleteAddress(e.target.value, setStartSuggestions);
                                }}
                            />
                            {activeInput === 'start' && startInputValue.length < 2 && (
                                <button
                                    onClick={handleGeolocation}
                                    className="absolute right-3 text-gray-400 hover:text-teal-600"
                                >
                                    <Crosshair size={20}/>
                                </button>
                            )}
                            {activeInput === 'start' && startInputValue.length > 0 && (
                                <button
                                    onClick={() => {
                                        setStartInputValue('');
                                        setStartCoordinates(null);
                                    }}
                                    className="absolute right-3 text-gray-400 hover:text-teal-600"
                                >
                                    <X size={20}/>
                                </button>
                            )}
                        </div>
                        {activeInput === 'start' && (
                            <ul className="absolute z-10 w-full bg-white border border-gray-300 rounded-md shadow-lg mt-1 max-h-60 overflow-auto suggestion-list">
                                {startInputValue.length > 2 ? (
                                    startSuggestions.map((suggestion, index) => (
                                        <li
                                            key={index}
                                            className="flex items-center px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm"
                                            onClick={() => handleSuggestionSelect(suggestion, 'start')}
                                        >
                                            <MapPin size={16} className="mr-2"/>
                                            {suggestion.address}
                                        </li>
                                    ))
                                ) : (
                                    <li className="px-4 py-2 text-sm text-gray-500">
                                        Commencer à écrire pour voir les suggestions
                                    </li>
                                )
                                }
                            </ul>
                        )}
                    </div>
                    <div className="relative">
                        <div className="flex items-center bg-gray-100 rounded-lg p-3 relative">
                            <MapPin size={20} className="text-red-500 mr-2"/>
                            <input
                                ref={endInputRef}
                                type="text"
                                placeholder="Arrivée"
                                className="bg-transparent w-full focus:outline-none text-gray-700"
                                value={endInputValue}
                                onFocus={() => setActiveInput('end')}
                                onChange={(e) => {
                                    setEndInputValue(e.target.value);
                                    autocompleteAddress(e.target.value, setEndSuggestions);
                                }}
                            />
                            {activeInput === 'end' && endInputValue.length < 2 && (
                                <button
                                    onClick={handleGeolocation}
                                    className="absolute right-3 text-gray-400 hover:text-teal-600"
                                >
                                    <Crosshair size={20}/>
                                </button>
                            )}
                            {activeInput === 'end' && endInputValue.length > 0 && (
                                <button
                                    onClick={() => {
                                        setEndInputValue('');
                                        setEndCoordinates(null);
                                    }}
                                    className="absolute right-3 text-gray-400 hover:text-teal-600"
                                >
                                    <X size={20}/>
                                </button>
                            )}
                        </div>
                        {activeInput === 'end' && (
                            <ul className="absolute z-10 w-full bg-white border border-gray-300 rounded-md shadow-lg mt-1 max-h-60 overflow-auto suggestion-list">
                                {endInputValue.length > 2 ? (
                                    endSuggestions.map((suggestion, index) => (
                                        <li
                                            key={index}
                                            className="px-4 py-2 hover:bg-gray-100 cursor-pointer text-sm"
                                            onClick={() => handleSuggestionSelect(suggestion, 'end')}
                                        >
                                            {suggestion.address}
                                        </li>
                                    ))
                                ) : (
                                    <li className="px-4 py-2 text-sm text-gray-500">
                                        Commencez à écrire pour voir les suggestions
                                    </li>
                                )
                                }
                            </ul>
                        )}
                    </div>
                </div>
                <div className="mt-3 flex items-center">
                    <Switch
                        id={'avoidToll'}
                        checked={!useToll}
                        onChange={(e) => setUseToll(!e)}
                        className="group inline-flex h-6 w-11 items-center rounded-full bg-gray-200 transition data-[checked]:bg-teal-600"
                    >
                        <span
                            className="size-4 translate-x-1 rounded-full bg-white transition group-data-[checked]:translate-x-6"/>
                    </Switch>

                    <label htmlFor="avoidToll" className="ml-2 text-sm text-gray-700">
                        Éviter les péages
                    </label>
                </div>
                {!isSearching && (
                    <button onClick={() => searchItinerary()}
                            disabled={!startCoordinates || !endCoordinates}
                            className="w-full mt-3 bg-teal-600 hover:bg-teal-700 text-white justify-center gap-2 p-3 rounded-lg flex items-center">
                        <Search size={20}/>
                        Rechercher
                    </button>
                )}
                {isSearching && (
                    <div
                        className="w-full mt-3 bg-teal-600 text-white justify-center gap-2 p-3 rounded-lg flex items-center">
                        <LoaderCircle size={20} className="animate-spin"/>
                        Recherche en cours...
                    </div>
                )}
            </div>

            {itinerarys.length > 0 && (
                <div className="mt-4 p-4 bg-gray-50 rounded-lg">
                    <h3 className="font-semibold text-lg mb-2">Itinéraires <span className="text-sm text-gray-500">(inclut bouchons, accidents, etc.)</span>
                    </h3>
                    <div className="grid gap-4">
                        {itinerarys.map((itinerary, index) => (
                            <article
                                key={index}
                                className={`p-3 rounded-lg cursor-pointer relative ${currentItinerary === itinerary ? 'font-bold ring-2 ring-teal-600' : 'font-normal ring-2 ring-gray-200'}`}
                                onClick={() => setCurrentItinerary(itinerary)}
                            >
                                <div className="flex items-center">
                                    <span className="font-bold text-lg mr-2">{index + 1}</span>
                                    <div>
                                        <div className="flex items-center text-gray-600">
                                            <Car size={16} className="mr-1"/>
                                            <span>{(itinerary.distance / 1000).toFixed(0)} km</span>
                                            <Clock size={16} className="mx-2"/>
                                            <span>
                                            {Math.trunc(itinerary.time / 3600000)} h {Math.trunc((itinerary.time % 3600000) / 60000)} min
                                </span>
                                        </div>
                                        <p className="text-sm text-gray-500 mt-1">
                                            {itinerary.details?.toll?.some(toll => toll.includes('all')) ? '(Route à péage)' : 'Pas de péage'}
                                        </p>
                                    </div>
                                </div>
                            </article>
                        ))}
                    </div>
                </div>
            )}
        </div>
    );
}
