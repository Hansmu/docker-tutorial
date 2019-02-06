#Image vs Container

An image is the application we want to run. 

A container is an instance of that image running as a process.

You can have many containers running off of the same image.

Docker's default image "registry" is called Docker Hub. (hub.docker.com)

First example command:

docker container run --publish 80:80 nginx

1) Downloaded image 'nginx' from Docker Hub
2) Started a new container from that image
3) Opened port 80 on the host IP
4) Routes the traffic to the container IP, port 80

Adding --detach will make it run in the background. Returns the ID of our container.

**docker container ls = docker ps** - returns the list of containers that are running.

**docker container stop = docker stop <container id>** - stops the container. Have to type in enough digits to identify it uniquely.

In addition to an ID, an unique name is also generated for the container, if we don't specify one ourselves. 

**docker container rm <id>** - remove Docker container

### What happens in 'docker container run'
1) Looks for that image locally in image cache, doesn't find anything
2) Then looks in remote image repository (defaults to Docker Hub)
3) Downloads the latest version (nginx:latest by default)
4) Creates new container based on that image and prepares to start
5) Gives it a virtual IP on a private network inside docker engine 
6) Opens up port 80 on host and forwards to port 80 in container
7) Starts container by using the CMD in the image Docker file

Container is nothing like a virtual machine. It's a restricted process running on our host machine.