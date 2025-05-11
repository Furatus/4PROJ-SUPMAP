# Configuration HTTPS

### API

###### Technologies utilisées
- Node.js avec Express.js pour le serveur web
- HTTPS via  Node.js
- Certificats SSL auto-signés
- Redirection HTTP ➜ HTTPS avec le module http

###### Explication du fonctionnement
Le serveur Node.js est configuré pour :
1) Charger les certificats SSL (clé privée et certificat) depuis le dossier sslcerts/.
2) Créer deux serveurs distincts :
   - Un serveur HTTP (port 5000 par défaut) qui redirige automatiquement tout le trafic vers le serveur HTTPS.
   - Un serveur HTTPS (port 5443 par défaut) qui héberge réellement l’API.
3) Appliquer la redirection pour forcer la navigation sécurisée.

En cas d'erreur lors du chargement des certificats, le serveur s'arrête immédiatement, évitant un démarrage en mode non sécurisé.

```js
let privateKey, certificate;
try {
    privateKey = fs.readFileSync('./sslcerts/api-server.key', 'utf8');
    certificate = fs.readFileSync('./sslcerts/api-server.crt', 'utf8');
} catch (err) {
    console.error('Error loading SSL certificates, Are Certificates files into folder ? Error : ', err.message);
    process.exit(1);
}
const credentials = { key: privateKey, cert: certificate };

const HttpPORT = process.env.PORT || 5000;
const HttpsPORT = process.env.HTTPS_PORT || 5443;

dotenv.config();

const httpApp = express();
httpApp.get("*", (req, res) => {
    res.redirect(`https://${req.hostname}:${HttpsPORT}${req.url}`);
});
createHttpServer(httpApp).listen(HttpPORT, () => {
    console.log(`HTTP server running on port ${HttpPORT} and redirecting to HTTPS`);
});
```

