import mongoose from "mongoose";

const PositionTrackerSchema = new mongoose.Schema({
    userId: {type: mongoose.Schema.Types.ObjectId, ref: 'users', required: true},
    location: {
        lat: {type: Number, required: true, default : 0.0},
        lon: {type: Number, required: true, default : 0.0}
    },
    isActive: {type: Boolean, default: false},
    createdAt: {type: Date, default: Date.now},
    updatedAt: {type: Date, default: Date.now},
});

export default mongoose.model('positionTracker', PositionTrackerSchema);