export function geojsonShapefromlatlng(lat, lng) {
    const delta = 0.00008983152; // 10 mètres en degrés
    return {
        "type": "Feature",
        "properties": {},
        "geometry": {
            "type": "Polygon",
            "coordinates": [
                [
                    [lat - delta, lng - delta],
                    [lat - delta, lng + delta],
                    [lat + delta, lng + delta],
                    [lat + delta, lng - delta],
                    [lat - delta, lng - delta]
                ]
            ]
        }
    }
}