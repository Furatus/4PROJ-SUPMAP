import customModel from "../models/CustomModel.js";

export default async function buildCustomModelForIncidents(incidents) {
    let ghcustomModel = new customModel();

    incidents.forEach((incident) => {
        //Convertir l'incident en partie du customModel de Graphhopper
        let coefficient = 1;
        switch (incident.type) {

            case "traffic_jam":
                if (incident.severity === "low") {
                    coefficient = 0.9;
                } else if (incident.severity === "medium") {
                    coefficient = 0.7;
                } else if (incident.severity === "high") {
                    coefficient = 0.5;
                }
                ghcustomModel.speed.push({"if" : `in_${incident._id}`, "multiply_by" : `${coefficient}`});
                break;

            case "road_closed":
                ghcustomModel.priority.push({"if" : `in_${incident._id}`, "multiply_by" : "0"});
                break;

            case "accident":
                if (incident.severity === "low") {
                    coefficient = 0.9;
                }
                if (incident.severity === "medium") {
                    coefficient = 0.7;
                }
                if (incident.severity === "high") {
                    coefficient = 0.5;
                }
                ghcustomModel.priority.push({"if" : `in_${incident._id}`, "multiply_by" : `${coefficient}`});
                break;


        }

        ghcustomModel.areas.features.push({
            "type": "Feature",
            "properties": {
                "id": incident._id,
                "type": incident.type,
                "severity": incident.severity,
                "status": incident.status
            },
            "id": incident._id,
            "geometry": incident.geojson.geometry
        });
    });
    return ghcustomModel;
}

export function handleTimeofIncidents(){
    //Passer les incidents trop anciens à l'état "closed" ou voir pour leur mettre un date de fin
}


