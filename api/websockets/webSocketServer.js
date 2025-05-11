import {Server} from "socket.io";
import passport from "passport";

var io = null;

const jwtAuthenticateSocket = (socket, next) => {
    passport.authenticate("jwt", { session: false }, (err, user, info) => {
        if (err) {
            console.error("Authentication error:", err.message);
            return next(new Error("Unauthorized"));
        }
        if (!user) {
            console.error("Authentication failed:", info ? info.message : "No user found");
            return next(new Error("Unauthorized"));
        }
        socket.request.user = user; // Attach the user to the socket request
        next();
    })(socket.request, {}, next);
};

export default function initWebSocket(httpServer) {

    io = new Server(httpServer);

    io.use(jwtAuthenticateSocket);

    io.on('connection', (socket) => {
        console.log('New ws client connected');
        socket.emit('hello',{ type: 'message', message: 'Connected to webSocket server', success: true });

        socket.on('error', console.error);

        socket.on('echo', (message) => {
            console.log('Received echo:', message);
            socket.emit('echo',{ type: 'echo', message });
        });

        socket.on('close', function close() {

        });

        socket.on('whoami', function whoami() {
           socket.emit('whoami', socket.request.user);
        });
    });

    return io;
}

export function getWebSocketServer() {
    if (!io) {
        throw new Error('WebSocket server not initialized. Call initWebSocket first.');
    }
    return io;
}
