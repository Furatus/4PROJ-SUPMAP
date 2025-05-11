import Incident from '../models/Incident.js';

export async function closeExpiredIncidents() {
    const now = new Date();

    try {
        const result = await Incident.updateMany(
            {
                expiresOn: { $lt: now },
                status: { $ne: 'closed' }
            },
            {
                $set: { status: 'closed', closedAt: now }
            }
        );
        console.log(`closed ${result.modifiedCount} expired incidents`);
        return result.modifiedCount;
    } catch (err) {
        console.error('Error on closing incidents :', err);
    }
}

// Close incidents on start
closeExpiredIncidents().catch(console.error);

// then close every 5 minutes
setInterval(() => {
    closeExpiredIncidents().catch(console.error);
}, 5 * 60 * 1000);