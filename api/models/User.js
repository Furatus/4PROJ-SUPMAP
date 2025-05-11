import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
    createdAt: { type: Date, default: Date.now },
    email: { type: String, required: true, unique: true },
    pseudo: { type: String, required: true },
    role: { type: String, default: "user" },
    picture:String,
    password: { type: String, required: false },

}, { timestamps: true });

export default mongoose.model("User", userSchema);
