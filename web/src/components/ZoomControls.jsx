import {Crosshair, Minus, Plus} from 'lucide-react'
import {useMap} from "@vis.gl/react-google-maps";

export default function ZoomControls() {
    const map = useMap();

    const handleZoomIn = () => {
        if (map) {
            const currentZoom = map.getZoom();
            map.setZoom(currentZoom + 1);
        }
    };

    const handleZoomOut = () => {
        if (map) {
            const currentZoom = map.getZoom();
            map.setZoom(currentZoom - 1);
        }
    };
    const handleLocate = () => {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition((position) => {
                const {latitude, longitude} = position.coords;
                if (map && window.google && window.google.maps) {
                    map.panTo({lat: latitude, lng: longitude});
                    new window.google.maps.Marker({
                        position: {lat: latitude, lng: longitude},
                        map: map,
                        icon: {
                            path: window.google.maps.SymbolPath.CIRCLE,
                            scale: 10,
                            fillColor: "#2C7A7B",
                            fillOpacity: 0.8,
                            strokeWeight: 2,
                            strokeColor: "#fff",
                            animation: window.google.maps.Animation.DROP
                        }
                    });
                    map.setZoom(15);
                }
            });
        }
    };


    return (
        <div className="absolute left-96 top-20 flex flex-col gap-2 -m-2">
            <button
                className="bg-white hover:bg-gray-100 text-gray-700 shadow-lg p-3 rounded-lg"
                onClick={handleLocate}
                aria-label="Ma localisation"
            >
                <Crosshair size={20}/>
            </button>
            <button
                className="bg-white hover:bg-gray-100 text-gray-700 shadow-lg p-3 rounded-lg"
                onClick={handleZoomIn}
                aria-label="Zoom in"
            >
                <Plus size={20}/>
            </button>
            <button
                className="bg-white hover:bg-gray-100 text-gray-700 shadow-lg p-3 rounded-lg"
                onClick={handleZoomOut}
                aria-label="Zoom out"
            >
                <Minus size={20}/>
            </button>
        </div>
    );
}