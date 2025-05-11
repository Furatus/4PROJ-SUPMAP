import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import fs from "fs";
import passport from "./config/passport.js";
import authRoutes from "./routes/authRoutes.js";
import incidentRoutes from "./routes/incidentRoutes.js";
import navigationRoutes from "./routes/navigationRoutes.js";
import positionTrackerRoutes from "./routes/positionTrackerRoutes.js";
import connectDB from "./config/db.js";
import swaggerUi from "swagger-ui-express";
import swaggerJsDoc from "swagger-jsdoc";
import initWebSocket from "./websockets/webSocketServer.js";
import {createServer as createHttpServer} from "http";
import {createServer as createHttpsServer} from "https";
import './utils/IncidentExpireCleanupUtil.js';
import './utils/watchdogUtils.js';
import watchdogMW from "./middleware/watchdog.js";

let privateKey, certificate;
try {
    privateKey = fs.readFileSync('./sslcerts/api-server.key', 'utf8');
    certificate = fs.readFileSync('./sslcerts/api-server.crt', 'utf8');
} catch (err) {
    console.error('Error loading SSL certificates, Are Certificates files into folder ? Error : ', err.message);
    process.exit(1);
}
const credentials = { key: privateKey, cert: certificate };

const HttpPORT = process.env.HTTP_PORT || 3080;
const HttpsPORT = process.env.HTTPS_PORT || 3000;

dotenv.config();

const httpApp = express();
httpApp.get("*", (req, res) => {
    res.redirect(`https://${req.hostname}:${HttpsPORT}${req.url}`);
});
createHttpServer(httpApp).listen(HttpPORT, () => {
    console.log(`HTTP server running on port ${HttpPORT} and redirecting to HTTPS`);
});

const app = express();
const httpsServer = createHttpsServer(credentials,app);
const io = initWebSocket(httpsServer);

const PassportMW = passport.initialize();

app.use(cors());
app.use(express.json());
app.use(PassportMW);
app.use(watchdogMW);

// Swagger configuration

const swaggerOptions = {
    swaggerDefinition: {
        openapi: "3.0.0",
        info: {
            title: "API Documentation",
            version: "1.0.0",
            description: "API documentation for the application.",
        },
        servers: [
            {
                url: `https://localhost:${HttpsPORT}/api`,
            },
        ],
    },
    apis: ["./routes/*.js"],
};
const swaggerDocs = swaggerJsDoc(swaggerOptions);
app.use("/docs", swaggerUi.serve, swaggerUi.setup(swaggerDocs));
connectDB();

app.use("/api/auth", authRoutes);
app.use("/api/incidents", incidentRoutes);
app.use("/api/navigation", navigationRoutes);
app.use("/api/positionTracker", positionTrackerRoutes);

app.get("/", (req, res) => {
    //res.send("Se référer à la documentation pour utiliser l'API");
    res.redirect("/docs");
})

//app.listen(PORT, () => console.log(`Serveur démarré sur le port ${PORT}`));
httpsServer.listen(HttpsPORT, () => {
    console.log(`Serveur démarré sur le port ${HttpsPORT}`);
});
