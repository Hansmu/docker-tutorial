FROM nginx:1.23

COPY customNginx.conf /etc/nginx/conf.d/default.conf