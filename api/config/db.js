import mongoose from "mongoose";

// Connect to MongoDB

const connectDB = async () => {
    mongoose
        .connect(process.env.MONGO_URI, {useNewUrlParser: true, useUnifiedTopology: true, authSource: "admin"})
        .then(() => console.log("MongoDB connecté"))
        .catch((err) => console.log(err));

};

export default connectDB;
