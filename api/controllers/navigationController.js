import incident from "../models/Incident.js";
import buildCustomModelForIncidents from "../utils/incidentUtils.js";
import axios from "axios";

export async function getCustomModel(req, res) {
    try {
        const incidents = await incident.find({status: {$ne: 'closed'}});
        if (!incidents) {
            res.status(500).json({message: "Error fetching incidents"});
        }
        if (incidents.length === 0) {
            res.status(200).json([]);
        }
        return res.status(200).json(await buildCustomModelForIncidents(incidents));
    } catch (err) {
        return res.status(500).json({message: err.message});
    }
}

export async function route(req, res) {
    try {
        const reqBody = req.body;

        const incidents = await incident.find({status: {$ne: 'closed'}});
        if (!incidents) {
            return res.status(500).json({message: 'Error fetching incidents'});
        }
        const customIncidents = await buildCustomModelForIncidents(incidents);

        const graphhoperBody = {...reqBody, custom_model: {...customIncidents}, "ch.disable": true};
        if (graphhoperBody.toll === false) {
            delete graphhoperBody.toll;
            graphhoperBody.custom_model.priority.push({
                "if": "toll != NO",
                "multiply_by": 0.0
            });
        }
        if (graphhoperBody.toll === true) {
            delete graphhoperBody.toll;
        }

        const response = await axios.post(`${process.env.GRAPHHOPPER_URL}/route`, graphhoperBody, {
            headers: {
                'Content-Type': 'application/json',
            }
        });
        if (response.status !== 200) {
            return res.status(500).json({message: 'Error fetching route from GraphHopper'});
        }
        return res.status(200).json(response.data);

    } catch (err) {
        res.status(500).json({message: err.message});
    }
}