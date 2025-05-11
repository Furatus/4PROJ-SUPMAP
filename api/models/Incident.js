import mongoose from "mongoose";


const IncidentSchema = new mongoose.Schema({
    location: {
        lat: { type: Number, required: true },
        lon: { type: Number, required: true }
    },
    status: { type: String, required: true, enum: ['open', 'confirmed', 'closed'] },
    severity: { type: String, required: true , enum: ['low', 'medium', 'high'] },
    type: { type: String, required: true, enum: ['traffic_jam', 'road_closed', 'accident', 'police', 'object_on_road'] },
    geojson : { type: Object, required: true },
    expiresOn: { type: Date, required: false, default: new Date() },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    updatedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
}, {
    timestamps: true,
});

export default mongoose.model('Incident', IncidentSchema);
