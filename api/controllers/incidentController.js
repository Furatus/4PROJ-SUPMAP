import Incident from '../models/Incident.js';
import {geojsonShapefromlatlng} from "../utils/geojsonUtils.js";
import broadcastNewIncident from "../websockets/broadcastNewIncident.js";
import {searchIncidentsInDatabase} from "../utils/locationUtils.js";
import positionTracker from "../models/PositionTracker.js";
import {closeExpiredIncidents} from "../utils/IncidentExpireCleanupUtil.js";


export  const addIncident = async (req, res) => {
    const { location, type} = req.body;
    const now = new Date();

    if (!location || !type || !location.lat || !location.lon) {
        return res.status(400).json({ message: 'Les champs location et type sont obligatoires' });
    }

    const newIncident = new Incident({
        location,
        type,
        geojson: geojsonShapefromlatlng(location.lat, location.lon),
        severity: 'low', // default value
        status: 'open', // default value
        createdBy: req.user._id,
        updatedBy: req.user._id,
        expiresOn: new Date(now.getTime() + 30 * 60 * 1000), // 30 minutes from now
    });
    try {
        const savedIncident = await newIncident.save();
        broadcastNewIncident(newIncident);
        res.status(201).json(savedIncident);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }

}

export const confirmIncident = async (req, res) => {
    const { id } = req.params;
    try {
        const incident = await Incident.findById(id);
        if (!incident) {
            return res.status(404).json({ message: 'Incident non trouvé' });
        }
        if (incident.status ==='open') {
            incident.status = 'confirmed';
            incident.updatedBy = req.user._id;
            incident.expiresOn = new Date(incident.expiresOn.getTime() + 10 * 60 * 1000); // add 10 extra minutes
            const updatedIncident = await incident.save();
            return res.status(200).json(updatedIncident);
        }
        if (incident.status === 'confirmed') {
            if (incident.severity === 'low') {
                incident.severity = 'medium';
            }
            else if (incident.severity === 'medium') {
                incident.severity = 'high';
            }
            incident.updatedBy = req.user._id;
            incident.expiresOn = new Date(incident.expiresOn.getTime() + 10 * 60 * 1000); // add 10 extra minutes
            const updatedIncident = await incident.save();
            return res.json(updatedIncident);
        }
        if (incident.status === 'closed') {
            return res.status(400).json({ message: 'Impossible de confirmer un incident déjà clos' });
        }
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}
export const refuteIncident = async (req, res) => {
    const { id } = req.params;
    try {
        const incident = await Incident.findById(id);
        if (!incident) {
            return res.status(404).json({ message: 'Incident non trouvé' });
        }
        if (incident.status === 'open') {
            incident.status = 'closed';
            incident.updatedBy = req.user._id;
            const updatedIncident = await incident.save();
            return res.status(200).json(updatedIncident);
        }
        if (incident.status === 'confirmed') {
            incident.status = 'open';
            incident.severity = 'low';
            incident.updatedBy = req.user._id;
            incident.expiresOn = new Date(incident.expiresOn.getTime() - 15 * 60 * 1000); // remove 15 minutes
            const updatedIncident = await incident.save();
            return res.json(updatedIncident);
        }
        if (incident.status === 'closed') {
            return res.status(400).json({ message: 'Impossible de refuter un incident déjà clos' });
        }
    } catch (error) {
        return  res.status(500).json({ message: error.message });
    }
}

export const getIncidents = async (req, res) => {
    try {
        const incidents = await Incident.find().populate('createdBy', 'pseudo').populate('updatedBy', 'pseudo');
        res.json(incidents);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}

export async function getIncidentsNearLocation(req, res) {
    const location = {};
    if (!req.query.lat || !req.query.lon) {
        return res.status(400).json({ message: 'specified location must be defined' });
    }
    location.lat = parseFloat(req.query.lat);
    location.lon = parseFloat(req.query.lon);
    const radius = parseFloat(req.query.radius) || 30; // default 30km

    try {
        const incidents = await searchIncidentsInDatabase(location, radius);

        if (!incidents) {
            return res.status(404).json({ message: 'No incidents found' });
        }
        return res.status(200).json(incidents);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}

export async function getIncidentsNearMe(req, res) {
    const location = {};
    const userPosition = await positionTracker.findOne({ userId: req.user._id });
    if (!userPosition || !userPosition.location || !userPosition.location.lat || !userPosition.location.lon) {
        return res.status(400).json({ message: 'User location not found or invalid' });
    }
    location.lat = parseFloat(userPosition.location.lat);
    location.lon = parseFloat(userPosition.location.lon);
    const radius = parseFloat(req.query.radius) || 30; // default 30km

    try {
        const incidents = await searchIncidentsInDatabase(location, radius);

        if (!incidents) {
            return res.status(404).json({ message: 'No incidents found' });
        }
        return res.status(200).json(incidents);
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
}

export async function closeExpiredIncidentsEndpoint(req, res) {

    if (!req.user || !req.user.role || req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Forbidden, you must be an admin to send this request' });
    }
    try {
        const incidentNumber = await closeExpiredIncidents();
        if (incidentNumber === 0) {
            return res.status(200).json({ message: 'No expired incidents to close' });
        }
        return res.status(200).json({ message: `${incidentNumber} expired incidents closed` });
    }
    catch (error) {
        res.status(500).json({ message: error.message });
    }
}