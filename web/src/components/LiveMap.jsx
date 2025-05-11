import { useMap } from "@vis.gl/react-google-maps";
import { useEffect, useRef, useState } from "react";
import { MarkerClusterer } from "@googlemaps/markerclusterer";
import accident from "../assets/incidents/accident.png";
import object_on_road from "../assets/incidents/object_on_road.png";
import police from "../assets/incidents/police.png";
import road_closed from "../assets/incidents/road_closed.png";
import traffic_jam from "../assets/incidents/traffic_jam.png";
import cluster from "../assets/incidents/cluster.svg";
import { useAuth } from "../hooks/useAuth.js";
import axios from "axios";

export default function LiveMap({ liveMapActive }) {
    const map = useMap();
    const { token } = useAuth();
    const [markers, setMarkers] = useState([]);
    const markerClusterRef = useRef(null);

    const getLabelFromType = (type) => {
        switch (type) {
            case "road_closed":
                return "Route barrée";
            case "accident":
                return "Accident";
            case "traffic_jam":
                return "Embouteillage";
            case "police":
                return "Contrôle de police";
            case "object_on_road":
                return "Objet sur la route";
            default:
                return "Incident";
        }
    };
    const getLabelFromSeverity = (severity) => {
        switch (severity) {
            case "low":
                return "Faible";
            case "medium":
                return "Moyenne";
            case "high":
                return "Élevée";
            default:
                return "Inconnue";
        }
    }

    useEffect(() => {
        if (!map) return;

        axios
            .get(`${import.meta.env.VITE_API_SERVER_URL}/incidents`, {
                headers: {
                    Authorization: `Bearer ${token}`,
                },
            })
            .then((res) => {
                const incidentsData = res.data;

                const newMarkers = incidentsData.map((incident) => {
                    const iconUrl =
                        incident.type === "road_closed" ? road_closed :
                            incident.type === "accident" ? accident :
                                incident.type === "traffic_jam" ? traffic_jam :
                                    incident.type === "police" ? police :
                                        object_on_road;

                    const iconSize = incident.severity >= 3
                        ? new window.google.maps.Size(40, 40)
                        : new window.google.maps.Size(30, 30);

                    const marker = new window.google.maps.Marker({
                        icon: {
                            url: iconUrl,
                            scaledSize: iconSize,
                        },
                        position: {
                            lat: incident.location.lat,
                            lng: incident.location.lon,
                        },
                        title: `${getLabelFromType(incident.type)} - ${getLabelFromSeverity(incident.severity)}`,
                    });

                    marker.setOptions({ cursor: "pointer" });

                    const infowindow = new window.google.maps.InfoWindow({
                        content: `
                            <div style="font-family: sans-serif; padding: 4px; max-width: 200px;">
                                <strong>${getLabelFromType(incident.type)}</strong><br />
                                Impact : ${getLabelFromSeverity(incident.severity)}<br />
                            </div>
                        `,
                    });

                    marker.addListener("click", () => {
                        infowindow.open({ anchor: marker, map });
                    });

                    return marker;
                });

                setMarkers(newMarkers);

                // Adapter la vue à tous les incidents
            });
    }, [map, token]);

    useEffect(() => {
        if (!map) return;

        if (liveMapActive && markers.length > 0) {
            if (markerClusterRef.current) {
                markerClusterRef.current.clearMarkers();
                markerClusterRef.current.addMarkers(markers);
                markerClusterRef.current.setMap(map);
            } else {
                markerClusterRef.current = new MarkerClusterer({
                    map,
                    markers,
                    renderer: {
                        render: ({ count, position }) => {
                            const clusterColor = count > 50 ? "red" : count > 20 ? "orange" : "teal";
                            const clusterSize = count > 50 ? 50 : count > 20 ? 45 : count > 10 ? 40 : 35;

                            return new window.google.maps.Marker({
                                position,
                                icon: {
                                    url: cluster,
                                    fillColor : clusterColor,
                                    scaledSize: new window.google.maps.Size(clusterSize, clusterSize),
                                    anchor: new window.google.maps.Point(clusterSize / 2, clusterSize),
                                },
                                label: {
                                    text: String(count),
                                    color: "white",
                                    fontSize: "14px",
                                    fontWeight: "bold",
                                },
                            });
                        },
                    },
                });
            }
        } else if (!liveMapActive && markerClusterRef.current) {
            markerClusterRef.current.clearMarkers();
            markerClusterRef.current.setMap(null);

        }
    }, [map, markers, liveMapActive]);

    return null;
}
