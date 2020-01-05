To have completion in PowerShell, use `Import-Module DockerCompletion`

From a certain point the way commands are structured changes - 
the old way still works, but there's a different grouping now. There were so many commands
that they needed to create an easier way to manage the commands.

The old way is `docker <command>`

The new way is `docker <management command> <command>`

E.g. `docker run` vs `docker container run`

To get help with a specific command, you can use `docker <management command> --help`

#Image (like a class) vs Container (like an object)

An image is the application we want to run. 

A container is an instance of that image running as a process.

You can have many containers running off of the same image.

Docker's default image "registry" is called Docker Hub. (hub.docker.com)

First example command:

`docker container run --publish 80:80 nginx` The left port is the host listening port. 
Right hand is within the container

What happened with the command:

1) Downloaded image 'nginx' from Docker Hub
2) Started a new container from that image
3) Opened port 80 on the host IP
4) Routes the traffic to the container IP, port 80

Adding --detach will make it run in the background. Returns the ID of our container.

Each time we run the command, we create a new container from the image.

`docker container ls` = `docker ps` - returns the list of containers that are running.
If you add `-a`, then you can see containers that have been stopped, but not removed.

`docker container stop` = `docker stop <container id>` - stops the container. Have to type in enough digits to identify it uniquely.

In addition to an ID, an unique name is also generated for the container, if we don't specify one ourselves.
`--name <name>` can be used to specify a name. 

`docker container logs <id>` - gives logs for that specific container.

`docker container top <id>` - gives list of processes running inside of that container.

`docker container rm <id>` - remove Docker container

### What happens in 'docker container run'
1) Looks for that image locally in image cache, doesn't find anything
2) Then looks in remote image repository (defaults to Docker Hub)
3) Downloads the latest version (nginx:latest by default)
4) Creates new container based on that image and prepares to start
5) Gives it a virtual IP on a private network inside docker engine 
6) Opens up port 80 on host and forwards to port 80 in container
7) Starts container by using the CMD in the image Docker file

Container is nothing like a virtual machine. It's a restricted process running on our host machine.

`--env` = `-e` can be used to pass environment variables

## Container inspect

`docker container top` - process list in one container.

`docker container inspect <name>` - shows a JSON about how the container was started. Its config.

`docker container stats <name>` - shows performance data. Memory, CPU etc.

## Open a shell into a container

`docker container run -it ... bash` - runs and enters a shell instantly. -i keeps the session 
open and -t opens a prompt with bash. If we exit the shell, then the container stops.

`docker container exec -it ... bash` - opens a shell separately. If you exit it, then the
container keeps running.