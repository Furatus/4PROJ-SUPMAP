# Statistiques

### Total des incidents

###### Objectif
Afficher le nombre total d'incidents enregistrés.

###### Code

```jsx
<div className="bg-white shadow-md rounded-xl p-6 text-center col-span-1 md:col-span-2">
  <h2 className="text-xl font-semibold text-teal-600 mb-2">Total des incidents</h2>
  <p className="text-3xl font-bold text-gray-800">{stats.total}</p>
</div>
```

### Graphique par type d'incident

###### Objectif
Montrer la répartition des types d’incidents (ex : Accident, Route barrée, Embouteillage…).

###### Type de graphique
BarChart (diagramme en barres)

###### Données
Générées avec :

```js
const byType = data.reduce((acc, curr) => {
  acc[curr.type] = (acc[curr.type] || 0) + 1;
  return acc;
}, {});
```
###### Code

```jsx
<ResponsiveContainer width="100%" height={250}>
  <BarChart data={typeData}>
    <XAxis dataKey="name" />
    <YAxis allowDecimals={false} />
    <Tooltip />
    <Bar dataKey="value" fill="#14b8a6" />
  </BarChart>
</ResponsiveContainer>
```
### Graphique par statut d'incident

###### Objectif
Afficher la répartition des incidents selon leur statut (open, confirmed, resolved).

###### Type de graphique
PieChart (diagramme circulaire)

###### Données
Générées avec :

```js
const byStatus = data.reduce((acc, curr) => {
  acc[curr.status] = (acc[curr.status] || 0) + 1;
  return acc;
}, {});
```

###### Code 

```jsx
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
```
### Graphique des incidents par heure

###### Objectif
Visualiser à quelle heure de la journée les incidents sont le plus signalés.

###### Type de graphique
BarChart

###### Données
Créées à partir de l’heure de création :
```js
const hoursMap = Array(24).fill(0);
data.forEach((incident) => {
  const hour = new Date(incident.createdAt).getHours();
  hoursMap[hour]++;
});
const hourlyData = hoursMap.map((count, hour) => ({
  hour: `${hour.toString().padStart(2, '0')}h`,
  count,
}));
```

###### Code 
```jsx
<ResponsiveContainer width="100%" height={300}>
  <BarChart data={stats.hourlyData}>
    <XAxis dataKey="hour" />
    <YAxis allowDecimals={false} />
    <Tooltip />
    <Bar dataKey="count" fill="#14b8a6" />
  </BarChart>
</ResponsiveContainer>
```

### Top 5 contributeurs

###### Objectif
Afficher les utilisateurs qui ont signalé le plus d’incidents.

###### Données

```js
const incidentsByUser = {};
data.forEach(incident => {
    const pseudo = incident.createdBy?.pseudo || 'Inconnu';
    incidentsByUser[pseudo] = (incidentsByUser[pseudo] || 0) + 1;
});
const topUsers = Object.entries(incidentsByUser)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)
    .map(([pseudo, count]) => ({ pseudo, count }));
```

###### Code
```jsx
<ul className="divide-y divide-gray-200">
    {stats.topUsers.map((user, index) => (
        <li key={user.pseudo} className="py-2 flex justify-between text-gray-700">
            <span className="font-medium">{index + 1}. {user.pseudo}</span>
            <span>{user.count} incident{user.count > 1 ? 's' : ''}</span>
        </li>
    ))}
</ul>
```