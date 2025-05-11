# api/Dockerfile

FROM node:23

WORKDIR /app

# Copier les fichiers spécifiques à ce service
COPY package*.json ./
RUN npm install --loglevel verbose

COPY . .
EXPOSE 3000

EXPOSE 3080

CMD ["node", "server.js"]
