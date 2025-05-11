FROM nginx:alpine

# Copier les fichiers de build React
COPY ./SUPMAP-DOC /usr/share/nginx/html

# Copier la config personnalisée dans conf.d
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 4000

CMD ["nginx", "-g", "daemon off;"]
