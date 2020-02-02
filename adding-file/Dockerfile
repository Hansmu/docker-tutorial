# this same shows how we can extend/change an existing official image from Docker Hub

FROM nginx:latest
# highly recommend you always pin versions for anything beyond dev/learn

WORKDIR /usr/share/nginx/html
# change working directory to root of nginx webhost
# using WORKDIR is preferred to using 'RUN cd /some/path'. It's a best practice way to change directories inside of Dockerfile.

COPY index.html index.html
# I don't have to specify EXPOSE or CMD because they're in my FROM. We inherit everything from the FROMed image.
