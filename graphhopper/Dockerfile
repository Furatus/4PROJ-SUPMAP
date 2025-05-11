# Utiliser l'image de base
FROM israelhikingmap/graphhopper

# Définir le répertoire de travail
WORKDIR /graphhopper

# Copier les fichiers de configuration et de données
ENV JAVA_OPTS: "-Xmx4g -Xms2g"
EXPOSE 8989
COPY ./config/graphhopper-config.yml ./
# Télécharger le fichier .pbf
RUN wget -O /data/centre-latest.osm.pbf https://download.geofabrik.de/europe/france/centre-latest.osm.pbf
# Commande par défaut pour exécuter GraphHopper
ENTRYPOINT [ "./graphhopper.sh", "-c", "graphhopper-config.yml" ]

#CMD ["java", "-Ddw.graphhopper.datareader.file=/data/france.osm.pbf", "-Ddw.graphhopper.graph.location=france-gh", "-jar", "*.jar", "server", "config-example.yml"]

