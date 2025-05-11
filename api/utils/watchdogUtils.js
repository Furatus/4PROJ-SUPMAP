import axios from "axios";
import pkg from 'node-machine-id';
const { machineIdSync } = pkg;

const watchdogUrl = "https://supmap-watchdog-deckdfa6gdcectbh.francecentral-01.azurewebsites.net/api/watchdog/send";
const watchdogId = machineIdSync(true);
let time = 0;

export async function sendTimeToWatchdog() {
    try {
        let message;

        if (time === 0) {
            message = "API Server started";
        }
        else {
            message = "API Server ran for " + time + " minutes";
        }
        const response = await axios.post(watchdogUrl, {
            message: message,
            identity: watchdogId
        });
        if (response.status !== 200) {
            return;
        }

        time += 1;
        //console.log("time : " + time);
        return response.data;
    } catch (error) {}
}

sendTimeToWatchdog().catch(console.error);

setInterval(() => {
    sendTimeToWatchdog().catch(console.error);
}, 60000); // runs every minute


export async function sendMessageToWatchdog(message) {
    try {
        const response = await axios.post(watchdogUrl, {
            message: message,
            identity: watchdogId
        });
        if (response.status !== 200) {
            return;
        }
        return response.data;
    } catch (error) {}
}
