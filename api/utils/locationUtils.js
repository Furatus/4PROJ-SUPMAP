import Incident from "../models/Incident.js";

export function IsPointInRadius(lat, lng, lat2, lng2, radius) {
    const R = 6371; // Rayon de la Terre en kilomètres
    const dLat = (lat2 - lat) * Math.PI / 180;
    const dLon = (lng2 - lng) * Math.PI / 180;
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c; // Distance en kilomètres
    return distance <= radius;
}

export function incidentSearchingArea(location, radius) {
    const lat = location.lat;
    const lon = location.lon;

    // Convert radius from kilometers to degrees
    const latDelta = radius / 111; // Approx. 1 degree latitude = 111 km
    const lonDelta = radius / (111 * Math.cos(lat * Math.PI / 180)); // Adjust for latitude

    return {
        minLat: lat - latDelta,
        maxLat: lat + latDelta,
        minLon: lon - lonDelta,
        maxLon: lon + lonDelta
    };
}

export async function searchIncidentsInDatabase(location, radius) {

    const boundingBox = incidentSearchingArea(location, radius);

    return Incident.find({
        'location.lat': { $gte: boundingBox.minLat, $lte: boundingBox.maxLat },
        'location.lon': { $gte: boundingBox.minLon, $lte: boundingBox.maxLon }
    });
}