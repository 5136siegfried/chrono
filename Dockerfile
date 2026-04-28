FROM nginx:alpine

# Static files
COPY index.html manifest.json sw.js /usr/share/nginx/html/

# Nginx config (container-level)
COPY nginx.container.conf /etc/nginx/conf.d/default.conf

EXPOSE 80