# Installation / Déploiement

Cette section décrit les étapes nécessaires pour installer et déployer l'application SUPMAP sur une machine locale. 
Elle couvre les prérequis, la configuration de l'environnement, et les instructions spécifiques pour chaque composant de l'application.

Cette page sera découpée en deux types principaux (en fonction de la nature de l'installation):
- Docker compose, Dockerfiles et Server side
- build et déploiement de l'application mobile

Le fichier docker compose fera l'objet d'une section à part entière.

<tip>
    Tous les fichiers <code>.env</code> et le fichier <code>local.properties</code> viennent avec un exemple de configuration, dans les répertoires correspondants.
</tip>

## Serveur Web (frontend)

<note>type : Docker compose</note>

Le serveur web est développé avec Vite et React. Il suffit de lancer le fichier docker compose pour démarrer le serveur.

### Variables d'environnement {id="variables-d-environnement_webserver"}

<warning>
  <strong>Vérifiez la configutation de votre fichier .env avant de lancer le docker compose.</strong>

  le fichier .env du serveur web doit se trouver à la racine du dossier web : <code> ./web/ </code>.
</warning>

Liste des variables d'environnement :
```bash
VITE_GOOGLE_MAPS_API_KEY= <YOUR_GOOGLE_MAPS_API_KEY>
VITE_API_GRAPHHOPPER_URL= http:<IP of Server running the graphhopper>//:8989 # Uniquement si le serveur Graphhopper est lancé dans le même docker compose
VITE_API_SERVER_URL=https://<IP of Server running the api>:3000/api # Même raisonnement ici
VITE_GOOGLE_CLIENT_ID= <YOUR_GOOGLE_CLIENT_ID>
```

<warning>
<strong> Très important : le serveur nécessite l'utilisation de clés ssl pour se lancer. si les clés ssl sont manquantes à l'adresse 
<code> ./web/sslcerts </code> (voir le readme directement dans le dossier), le serveur refusera catégoriquement de se lancer.
Les clés ssl doivent être au format PEM et doivent être nommées web-server.key et web-server.crt.
</strong>

<emphasis> Vous pouvez générer des clés ssl auto-signées avec openssl, ou utiliser un certificat ssl valide. (au format "KEY,CRT") </emphasis>
</warning>

## Serveur API (backend)

<note>type : Docker compose</note>

Le serveur API est développé avec Node.js et Express. Il suffit de lancer le fichier docker compose pour démarrer le serveur.

### Variables d'environnement {id="variables-d-environnement_api"}

<warning>
  <strong>Vérifiez la configutation de votre fichier .env avant de lancer le docker compose.</strong>
  le fichier .env du serveur API doit se trouver à la racine du dossier api : <code> ./api/ </code>.
</warning>

Liste des variables d'environnement :
```bash
MONGO_URI = "mongodb://<root_user>:<password>@supmap-db:27017/" # User et password définis dans le .env de la racine, avec le docker compose. l'adresse utilisée est uniquement valide dans le docker compose
JWT_SECRET = <YOUR_JWT_SECRET> # Secret utilisé pour signer les tokens JWT
HTTP_PORT = 3080 # Port HTTP du serveur API, Il est recommandé de ne pas le changer, surtout si vous utilisez le docker compose
HTTPS_PORT = 3000 # Port HTTPS du serveur API, Il est recommandé de ne pas le changer, surtout si vous utilisez le docker compose
GOOGLE_WEB_CLIENT_ID= <YOUR_GOOGLE_WEB_CLIENT_ID>
GOOGLE_ANDROID_CLIENT_ID= <YOUR_GOOGLE_ANDROID_CLIENT_ID>
GRAPHHOPPER_URL = "http://graphhopper:8989" # Adresse du serveur Graphhopper, uniquement valide dans le docker compose
```

<warning>
<strong> Très important : le serveur nécessite l'utilisation de clés ssl pour se lancer. si les clés ssl sont manquantes à l'adresse 
<code> ./api/sslcerts </code> (voir le readme directement dans le dossier), le serveur refusera catégoriquement de se lancer.
Les clés ssl doivent être au format PEM et doivent être nommées api-server.key et api-server.crt. </strong>

<emphasis> Vous pouvez générer des clés ssl auto-signées avec openssl, ou utiliser un certificat ssl valide. (au format "KEY,CRT") </emphasis>
</warning>

## Serveur Graphhopper

<note>type : Docker compose</note>

Le serveur Graphhopper utilise directement l'image dockerhub oficielle de Graphhopper. Il suffit de lancer le fichier docker compose pour démarrer le serveur.

Nous effectuons tous les téléchargements et configurations nécessaires à son fonctionnement dans le docker compose.

<tip>
    <strong> Le conteneur graphhopper demande beaucoup de temps pour se build, il est donc important d'être <u>patient</u> et de <u>manipuler ses données et volumes avec précaution</u>.</strong>
</tip>

<note> Ce conteneur ne possède pas de variables d'environnement, simplement un fichier de configuration préconfiguré à l'adresse <code>./graphhopper/config/graphhopper-config.yml</code>. <u>Il est fortement déconseillé de le modifier.</u></note>


## Serveur Documentation

<note>type : Docker compose</note>

Le serveur de documentation (Peut-être la page sur laquelle vous vous trouvez) est développé avec Writerside (et délivré avec nginx). Il suffit de lancer le fichier docker compose pour démarrer le serveur.

<tip> Pas de variables d'environnement sur ce serveur</tip>

## Application Mobile

<note>type : Flutter</note>

L'application mobile est développée avec Flutter.

### Prérequis

- Flutter SDK installé sur votre machine
- Android Studio ou Visual studio code pour la compilation mobile.
- Un émulateur Android ou un appareil physique pour tester l'application

<tip>
    Pour installer Flutter, suivez les instructions sur le site officiel de Flutter :  <a href="https://flutter.dev/docs/get-started/install"> Guide d'installation de Flutter</a>
</tip>

### Variables d'environnement

Liste des variables d'environnement :

<p>
fichier .env : <code>./flutter/.env</code>
</p>

```bash
GOOGLE_MAPS_API_KEY= <YOUR_GOOGLE_MAPS_API_KEY>
SERVER_API_URL=https://<IP of Server running the api>:3000/api # Si le docker compose est lancé, utilisez l'adresse ip de la machine hôte
WEB_SOCKET_URL=wss://<IP of Server running the api>:3000 # Même raisonnement ici
GRAPHHOPPER_API_URL= http://<IP of Server running Graphhopper>:8989 # Même raisonnement ici
GOOGLE_ANDROID_CLIENT_ID= <YOUR_GOOGLE_ANDROID_CLIENT_ID> 
```

fichier local.properties (à ajouter aux clés déjà existantes) : <code>./flutter/android/local.properties</code>

```bash
GoogleMapsApiKey=<YOUR_GOOGLE_MAPS_API_KEY> # Même clé que dans le fichier .env
```
<tip>
Veillez bien à ouvrir les différents ports sur votre pare-feu (3000, 3080, 8989) pour permettre la communication entre l'application mobile et le Serveur.
</tip>

<procedure title="Compilation et installation de l'application mobile" id="installation-application-mobile">
<step>
Ouvrez un terminal à la racine du projet et naviguez jusqu'au répertoire de l'application mobile.

```bash
cd ./flutter/
```
</step>
<step>
Ensuite, exécutez la commande suivante pour installer les dépendances du projet (si elles ne sont pas déjà inclues):

```bash
flutter pub get
```
</step>
<step>
Vérifiez que le contenu de vos fichiers .env et local.properties (<code>./flutter/.env</code> et <code> ./flutter/android/local.properties </code>) soient corrects. Voir la section précédente pour le détail sur les variables d'environnement.
</step>
<step>
Compilez l'application pour Android en utilisant la commande suivante :

```bash
flutter build apk --release
```
</step>
<step>
Une fois la compilation terminée, vous trouverez le fichier APK dans le répertoire <code>./flutter/build/app/outputs/flutter-apk/</code>.
Vous pouvez l'installer sur un appareil Android en le transférant et en l'installant manuellement si vous avez un appareil physique à disposition, pensez à activer l'option d'installation par apk, si ce n'est pas déjà le cas.
</step>
<step>
Si vous préférez utiliser un émulateur Android, il est fortement conseillé d'utiliser Android Studio pour le lancer depuis ADB/AVD. Flutter/Android Studio vous proposera directement de lancer l'application sur vos appareils disponibles. <warning> Cette méthode est plus difficile.</warning>
</step>

</procedure>


## Docker compose

<note>type : Docker compose</note>
Le fichier docker compose est situé à la racine du projet. Il permet de lancer tous les services nécessaires au bon fonctionnement de l'application.
Il est configuré pour utiliser les images officielles de MongoDB, Graphhopper, Node et Nginx. Il est également configuré pour utiliser les Dockerfiles du serveur API, du serveur Web et du Serveur Nginx pour la documentation.

<tip>
    <strong> Il est fortement recommandé de ne pas modifier le docker compose, sauf si vous savez ce que vous faites.</strong>
</tip>

### Variables d'environnement {id="variables-d-environnement_docker-compose"}

Le fichier Docker compose utilise uniquement les variables d'environnement pour mongodb. On retrouve donc les deux variables suivantes :
```bash
MONGO_ROOT_USER = <YOUR_MONGO_ROOT_USER>
MONGO_ROOT_PASSWORD = <YOUR_MONGO_ROOT_PASSWORD>
```

<tip>
    <strong> Veillez à bien faire correspondre l'utilisateur et le mot de passe de MongoDB avec ceux utilisés dans le serveur API. Sinon, l'api ne pourra pas démarrer. </strong>
</tip>

-------

<note>
Une copie de cette page sera exportée en fichier PDF pour permettre une lecture hors ligne, nécessaire à la première utilisation.
</note>