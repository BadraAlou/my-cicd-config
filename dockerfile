# Utiliser une image légère de Nginx (compatible ARM et x86)
FROM nginx:alpine

# Copier les fichiers du site dans le dossier par défaut de Nginx
COPY . /usr/share/nginx/html

# Exposer le port 80
EXPOSE 80