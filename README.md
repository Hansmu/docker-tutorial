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

# Docker networks

Each container connected to a private virtual network "bridge". 
Each virtual network routes through NAT firewall on host IP. Best practice is to create a new
virtual network for each app. That is an app and its DB and such.

`docker container port <container>` can be used to check the exposed port.

The below command can be used to filter out a specific parameter from the configuration JSON.

``docker container inspect --format "{{ .NetworkSettings.IPAddress }}" webhost``

If the -p option is not used when running a container, then that container will not be exposed to the network.
What -p does is that it opens up a port on the Ethernet interface and all traffic
that comes in through that port gets routed to the container's mapped port.

If -p isn't specified, then containers within a single network can still communicate with each other,
but they don't know anything of the outside world, that includes other virtual networks.

`docker network ls` - show all the networks that have been created.

`docker network inspect bridge` - shows us that a random container we created is connected to the bridge
underneath the containers section.

The "host" network, listed by the `docker network ls` command, is to connected directly to the host's physical 
connection. This can provide a performance boost at the cost of security. Also it may help overcome issues with
specific software.

The none network is an interface that isn't connected to anything.

`docker network create udemy_network` - creates our own custom network. By default it uses
the bridge driver as its driver. A network driver is a built-in or 3rd party extension that
gives the virtual network features. A new network has its subnet incremented by one. Generally
the network has a /16 subnet.

`docker container run -d --name new_nginx --network udemy_network nginx` - to add a new container
into our newly created network.

`docker network connect <network identifier> <container identifier>` - connects an existing
container into the network that we've created.

If we inspect our container now, then it can be seen that it's on two networks - the original
bridge and in our newly created network.

`docker network disconnect <network identifier> <container identifier>` - removes the container
from our network.

With Docker it's easier to protect your apps. In the real world with physical machines and virtual machines
they were often overexposed. In Docker you can keep them in a single host and only expose a single port.

You can't rely on IP addresses inside of containers because things are dynamic. Forget IPs
static IPs and using IPs for talking to containers is an anti-pattern. Do your best to avoid it.

Docker DNS is a built-in DNS server in the docker daemon that containers use by default.
The default implementation provides DNS routing using your container names.

`docker container exec -it my_nginx ping new_nginx` - Pinging the other container just works 
out of the box.

The bridge network does not have DNS functionality, so if you try to ping another container
within the bridge network, then you won't find them. You can manually declare the connections
within the bridge network using --link, but it's much easier to just create your own custom network.

When running a container, you can specify --rm so that it removes the container as soon as you 
exit the shell. Makes testing faster.
`docker container run --rm -it centos:7 bash`

You can add multiple DNS aliases to networks. The use is that in order to make sure something
is up 24/7, then behind a single IP can be multiple servers. `-net-alias` can be used to 
add an alias to the container. If you ping them, then you'll hit them one after the other or just randomly.
So the first ping hits the first container, second hits the second, third hits the first again
and round and round it goes.

`docker container run -d --net <network name> --net-alias <alias for the container> elasticsearch:2`

# Docker Images

Images are app binaries and dependencies, with metadata about the image data and how to 
run the image. It's not a complete OS. No drivers and such. It's not booting up a full 
OS, just starting an application. It can be pretty small.

When choosing images from hub.docker.com, then it's safest to start with the official ones.
They're the ones with the word official under them. It doesn't have a forward slash in front of it.
When a user creates an image, then it has to be done from under a user. So the image name
becomes `<username>/<image repository names>`. Docker has a group of people actually working
on the official images, to make sure they are well documented and tested. They usually work
with the official team of that specific software.

Images have tags on the Docker hub with which they can be referred to. E.g. with Nginx 
1/1.11/latest/1.11.9 all of these would refer to the same thing during the filming of the tutorial.
When you're actually using images in your application, then you'd probably want the most specific version.
Otherwise if you'd specify say just nginx:1, then it'd download the newest version of nginx that
starts with the version 1, so 1.X.X. But that can lead to inconsistencies during installation.

The image ID is based on the cryptographic sha of each image in the Docker hub. So if you
download the latest version using different specifiers, like 1.11, 1.11.9, latest, then you'd get
images listed locally that have the same image ID for those three specifiers. So it's just 3
tags with the same image ID. It's not taking up 3x the space, they're all just referring to the same
image that locally exists on the machine.

Images are made up of file system changes and metadata. A Docker image looks like a layer of pancakes.
It consists of several layers. It begins with a blank layer known as scratch. Every 
set of changes that happens after that on the file system in the image is another layer.
The layers have their unique identifiers. Each layer does something to the image. Each 
layer gets cached onto the user machine. This means that if  different images are using 
the same layers, then they aren't saved several times, but each  layer is cached and 
then the cached layer is used within that image's stack. So suppose that you have a 
MySQL DB saved on your machine and different images perform different operations on it,
then for both of those images the very bottom layer is the same MySQL DB layer. When you
run `docker history <image>`, then you can see everything that has been done to the image.
It displays all the layers. Each layer represents when and how an image was changed on
Docker Hub. When you look at the IMAGE column, then there's `<missing>`, that doesn't
actually mean something's missing. It means that the image itself has the ID of the 
only layer that has an ID present. All the other layers that don't represent the image
itself are with the missing tag. The present ID is the same as when you use `docker image ls`

When you run a container off of an image, then all Docker does is creates a new 
read-write layer on top of the image. However when you're changing files in the image
then a thing happens which is known as copy on write. The file system will take that
changed file out of the image and copy it into the container.

`docker image inspect <image identifier>` - this can be used to see all sorts of 
information about the image. For example what ports need to be opened up 
("ExposedPorts").

Images don't really have a name property. If you do a `docker image ls`, then you can see 
that there is no name column. You have repository, tag and image ID. An image ID
is difficult to remember, but we have the repository for reference. As mentioned
above then it has `<user>/<image>`, where official ones don't have a user in front
of it. A tag is a pointer to a specific image commit. 

You can create a custom image from an existing repository by using the command
`docker image tag <existing repository> <new repository>`. For example: 
`docker image tag nginx UserMcUser/nginx`. To add it to Docker
Hub, then use `docker image push <new repository>`. For example: 
`docker image push UserMcUser/nginx`. To add additional tags to
the release, then you can use `docker image tag <existing repository> <new repository>:<tag>`. For example
`docker image tag UserMcUser/nginx UserMcUser/nginx:bananas`. Then to add it to the 
Hub, then you'd use `docker image push UserMcUser/nginx:bananas`. If there are 
layers that already exist, then Docker won't bother re-uploading them. You can
also set a repository to be private on Docker Hub.

When you login to docker with `docker login`, then your login key gets stored on 
the machine under the current profile. If it's a machine you don't trust, then 
you should use `docker logout` after you're done.

A Dockerfile is a recipe for creating your image. A Dockerfile might look like a shell
script but it isn't. It's a thing on its own. The syntax is specific to Docker. By default
the file `Dockerfile` is searched for, but if you have a custom name, then you can use
a custom name e.g. `docker build -f some-docker-file`. Each statement in the file 
is a layer in our Docker image, so the order matters. The basic statements that are 
inside of a Dockerfile are: 
```
FROM ...
ENV ...
RUN ...
EXPOSE ...
CMD ...
```

`docker image build -t <repository> .` - to build a Docker image from a Dockerfile.
The `.` means that it'll be put into this directory. The first build takes the longest
amount of time, because the layers haven't been cached. If you make a change after
the first build, then the layer that you changed and every layer after it will get
rebuilt. Keep the things that change the least at the top of your Dockerfile and 
things that change the most at the bottom.

Ideally, if you can get an official image to get the job done, then it'd be a lot
easier to maintain your image's Dockerfile. E.g. adding Nginx related things to a
Linux distribution instead of just starting by including the Nginx image. However,
sometimes the default image can limit what you need. In that case you can go
searching for custom images that seem trustworthy or start building it from scratch.
Building from scratch is just more work and upkeep over time.

##Volumes
Containers are usually immutable(unchanging) and ephemeral(temporary).
It means that when we need to update the container, then we'll have to re-deploy it,
never change the existing one. But what happens to the data?

Docker has two solutions to keeping persistent data. Volumes and bind mounts.
Volumes are in a special location outside of the container unified file system.
Allows us to attach it to any container. The container sees it as a regular file path.
Bind mount is linking a host file path to a container.

`VOLUME /path/to/directory` is used to define the directory path for the volume inside
of the container. Which means that any file we put in that directory inside of the container
will outlive the container until we manually delete the volume. Volumes need manual 
deletion.

`docker volume prune` can be used to clean up unused volumes.

When you do an image inspect, then you can see that there is a volumes property.
You can very with that that volumes are in use. If you create a container from
the image, then you should see a volumes property there as well. Additionally
there should be a volumes entry under mounts. Destination specifies where the 
container is trying to find the data internally and source specifies where the
volumes actually exist on the host. With Linux, you can navigate to that path 
to actually see the data. However, on Mac and Windows, Docker is creating a VM
in the background. So the data is inside of the VM, so you can't go to the path
to actually see the file.

`docker volume inspect <id>` can be used to inspect the volumes. We can't see from
the volume's perspective what it's connected to. To fix this problem we can use
`-v` when creating the container to specify the volume name. You have to specify
the volumes folder as well.

Example: `docker container run -d --name mysql -e MYSQL_ALLOW_EMPTY_PASSWORD=True 
-v mysql-my-custom-volume-name:/var/lib/mysql mysql`

Now if go under `docker volume ls`, then you can see that a named volume has been 
created.

Additionally, you can use that setup to reuse a volume by just changing the `--name`
to another one.

Sometimes you might need to create a Docker volume ahead of time. For local development
that isn't necessary. But you can do this with `docker volume create`

Bind mounting is mapping a host file or directory to a container file or directory.
It doesn't overwrite any data. However, it takes precedence over the file in the 
container. If the bind mount is removed, then the file that existed before gets used
again. Can't specify them in a Dockerfile because you need them to exist at a certain
path on the host. Has to be added with `container run`. For example: `container run 
-v //c/Users/bob/doc/things:/path/in/container`

`docker container run -d --name nginx -p 80:80 -v ${pwd}:/usr/share/nginx/html nginx` - 
${pwd} prints out the working directory. So we're mounting our current directory to be 
in the nginx/html folder. If you'd add a new file to the folder, then you'd see it inside 
of the Docker container as well. If you delete the file inside of the container, then it
gets removed from the host as well.