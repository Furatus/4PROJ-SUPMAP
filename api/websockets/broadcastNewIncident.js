import {getWebSocketServer} from "./webSocketServer.js";
import positionTrackerSchema from "../models/PositionTracker.js";
import {IsPointInRadius} from "../utils/locationUtils.js";


export default async function broadcastNewIncident(incident) {
  const io = getWebSocketServer();

    let sockets = io.sockets.sockets;

    //console.log('sockets:', sockets);

  const clientLocations = await positionTrackerSchema.find({});
    sockets.forEach( (socket) => {
        const clientLocationData = clientLocations.find(loc => String(loc.userId) === String(socket.request.user._id));
        //console.log('clientLocationData:', clientLocationData);
        if (!clientLocationData || !clientLocationData.location || !clientLocationData.location.lat || !clientLocationData.location.lon) return;
        const isClientInRadius = IsPointInRadius(incident.location.lat, incident.location.lon, clientLocationData.location.lat, clientLocationData.location.lon, 30); // 30km radius
        if (!clientLocationData || !socket.request.user) {
            console.log('Client location data not found or user not found for socket:', socket.id);
            console.log('further info:', clientLocationData, socket.request.user);
            socket.emit("error", { type : "location_error", message: "Client location data not found or user not found" });
            return;
        }
        if (socket.readyState === socket.OPEN && isClientInRadius) {
            socket.emit("new_incident",{
                type: 'new_incident',
                data: incident
            });
        }
    });
};