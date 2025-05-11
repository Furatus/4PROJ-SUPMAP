import PositionTrackerSchema from "../models/PositionTracker.js";
import {locationSchema} from "../validations/locationSchema.js";
import {now} from "mongoose";

export async function updateLocation(req, res) {
    if (!req.body.location || !req.body.location.lat || !req.body.location.lon) {
        return res.status(400).json({ message: 'location field : {lat,lon} is mandatory' });
    }
        const {error} = locationSchema.validate(req.body.location);
        if (error) return res.status(400).json({error: error.details[0].message});

    try {
        const positionTracker = await PositionTrackerSchema.findOne({ userId: req.user._id});

        if (!positionTracker) {
            const newPositionTracker = new PositionTrackerSchema({
                userId: req.user._id,
                location: req.body.location
            });
            await newPositionTracker.save();
            return res.status(201).json({message: 'Position Tracker created', positionTracker: newPositionTracker});
        }
        positionTracker.location = req.body.location;
        positionTracker.updatedAt = now();
        await positionTracker.save();
        return res.status(200).json({message: 'Update location success', positionTracker: positionTracker});
    }
    catch (err) {
        res.status(500).json({message: err.message});
    }
}