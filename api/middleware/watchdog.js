import {sendMessageToWatchdog} from "../utils/watchdogUtils.js";

export default async function watchdogMW(req,res,next) {
    const endpoint = req.originalUrl;
    sendMessageToWatchdog(`Used route ${endpoint}`);
    next();
}