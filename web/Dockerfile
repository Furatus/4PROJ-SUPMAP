FROM node:23-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npx vite build

EXPOSE 443

CMD ["npx", "vite", "dev"]
