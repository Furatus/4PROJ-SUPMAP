import { useEffect, useState } from "react";
import axios from "axios";
import { useAuth } from "../hooks/useAuth";
import {
    BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend,
} from "recharts";

const COLORS = ['#14b8a6', '#2dd4bf', '#5eead4', '#99f6e4', '#ccfbf1'];

export default function StatisticsPage() {
    const { token } = useAuth();
    const apiUrl = import.meta.env.VITE_API_SERVER_URL;

    const [stats, setStats] = useState({
        byType: {},
        byStatus: {},
        hourlyData: [],
        topUsers : [],
        total: 0,
    });

    useEffect(() => {
        const fetchStatistics = async () => {
            try {
                const response = await axios.get(`${apiUrl}/incidents`, {
                    headers: {
                        Authorization: `Bearer ${token}`,
                    },
                });
                const data = response.data;

                const byType = data.reduce((acc, curr) => {
                    acc[curr.type] = (acc[curr.type] || 0) + 1;
                    return acc;
                }, {});

                const byStatus = data.reduce((acc, curr) => {
                    acc[curr.status] = (acc[curr.status] || 0) + 1;
                    return acc;
                }, {});
                // Groupement par heure
                const hoursMap = Array(24).fill(0);
                data.forEach((incident) => {
                    const hour = new Date(incident.createdAt).getHours();
                    hoursMap[hour]++;
                });
                const hourlyData = hoursMap.map((count, hour) => ({
                    hour: `${hour.toString().padStart(2, '0')}h`,
                    count,
                }));

                const incidentsByUser = {};
                data.forEach(incident => {
                    const pseudo = incident.createdBy?.pseudo || 'Inconnu';
                    incidentsByUser[pseudo] = (incidentsByUser[pseudo] || 0) + 1;
                });

// Extraction du top 5
                const topUsers = Object.entries(incidentsByUser)
                    .sort((a, b) => b[1] - a[1])
                    .slice(0, 5)
                    .map(([pseudo, count]) => ({ pseudo, count }));



                setStats({
                    byType,
                    byStatus,
                    hourlyData,
                    topUsers,
                    total: data.length,
                });
            } catch (error) {
                console.error("Erreur lors de la récupération des statistiques :", error);
            }
        };

        fetchStatistics();
    }, [token]);

    function formatLabel(label) {
        const map = {
            road_closed: "Route barrée",
            accident: "Accident",
            traffic_jam: "Embouteillage",
            police: "Police",
            object_on_road: "Obstacle",
            construction: "Travaux",
            open: "Ouvert",
            confirmed: "Confirmé",
            resolved: "Résolu",
            low: "Faible",
            medium: "Moyenne",
            high: "Élevée"
        };
        return map[label] || label.charAt(0).toUpperCase() + label.slice(1).replace(/_/g, " ");
    }

    // Formater pour les graphes
    const typeData = Object.entries(stats.byType).map(([key, value]) => ({
        name: formatLabel(key),
        value,
    }));

    const statusData = Object.entries(stats.byStatus).map(([key, value]) => ({
        name: formatLabel(key),
        value,
    }));


    return (
        <div className="min-h-screen bg-gray-100 p-6 flex flex-col items-center">
            <h1 className="text-4xl font-bold text-teal-600 mb-6">Statistiques du trafic</h1>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 w-full max-w-6xl">

                {/* Carte total */}
                <div className="bg-white shadow-md rounded-xl p-6 text-center col-span-1 md:col-span-2">
                    <h2 className="text-xl font-semibold text-teal-600 mb-2">Total des incidents</h2>
                    <p className="text-3xl font-bold text-gray-800">{stats.total}</p>
                </div>

                {/* Graphe par type */}
                <div className="bg-white shadow-md rounded-xl p-6">
                    <h2 className="text-xl font-semibold text-teal-600 mb-4">Par type d'incident</h2>
                    <ResponsiveContainer width="100%" height={250}>
                        <BarChart data={typeData}>
                            <XAxis dataKey="name" />
                            <YAxis allowDecimals={false} />
                            <Tooltip />
                            <Bar dataKey="value" fill="#14b8a6" />
                        </BarChart>
                    </ResponsiveContainer>
                </div>

                {/* Graphe par statut */}
                <div className="bg-white shadow-md rounded-xl p-6">
                    <h2 className="text-xl font-semibold text-teal-600 mb-4">Par statut</h2>
                    <ResponsiveContainer width="100%" height={250}>
                        <PieChart>
                            <Pie
                                data={statusData}
                                dataKey="value"
                                nameKey="name"
                                cx="50%"
                                cy="50%"
                                outerRadius={80}
                                fill="#14b8a6"
                                label
                            >
                                {statusData.map((entry, index) => (
                                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                ))}
                            </Pie>
                            <Legend />
                            <Tooltip />
                        </PieChart>
                    </ResponsiveContainer>
                </div>
                {/* Graphique de congestion par heure */}
                <div className="bg-white shadow-md rounded-xl p-6">
                    <h2 className="text-xl font-semibold text-teal-600 mb-4">Incidents par heure</h2>
                    <ResponsiveContainer width="100%" height={300}>
                        <BarChart data={stats.hourlyData}>
                            <XAxis dataKey="hour" />
                            <YAxis allowDecimals={false} />
                            <Tooltip />
                            <Bar dataKey="count" fill="#14b8a6" />
                        </BarChart>
                    </ResponsiveContainer>
                </div>
                {/* Top contributeurs */}
                <div className="bg-white shadow-md rounded-xl p-6">
                    <h2 className="text-xl font-semibold text-teal-600 mb-4">Top 5 contributeurs</h2>
                    <ul className="divide-y divide-gray-200">
                        {stats.topUsers.map((user, index) => (
                            <li key={user.pseudo} className="py-2 flex justify-between text-gray-700">
                                <span className="font-medium">{index + 1}. {user.pseudo}</span>
                                <span>{user.count} incident{user.count > 1 ? 's' : ''}</span>
                            </li>
                        ))}
                    </ul>
                </div>

            </div>
        </div>
    );
}
