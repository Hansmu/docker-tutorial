# Commands

The old way for the commands was to just have `docker <command> (options)`.
However, it started getting out of control.

The new format is `docker <command> <sub-command> (options)`.
The old format still works, but it's recommended to go with the new as it supports new features.

## Containers

When referring to a container, you can use either the generated ID or name.

### Running a container

To run a container, you can use:
```bash
docker container run --publish 80:80 --detach nginx
```

* The `--publish` flag exposes a port inside the container to the host machine.
  * In the example, that's saying that from the host machine port 80 (on the left), you can access the container's port 80 (on the right).
* The `--detach` flag means that it's going to be running in the background.
* You can specify a name with `--name` if you want a specific one. Otherwise, one will be generated automatically.

To break down the above command, then you have
```
docker container run --publish <host-port>:<port-inside-container> <image-name>
```

### Viewing containers

To view running containers, you can use:
```bash
docker container ls
```

To also see stopped containers, then the `--a` flag can be added for "all".

```bash
docker container ls -a
```

### Stopping a container

To stop a container, you can use:
```
docker container stop <container-ref>
```

### Staring an existing container

To start an existing container, you can use:
```
docker container start <container-ref>
```

### Removing containers

To remove a container, you can use:
```
docker container rm <container-ref>
```

You can specify multiple refs in the same command
```
docker container rm a2 f2 d2
```

A running container cannot be removed by default.
If you want to remove a running container, then you can either stop it and then remove or you can add the force flag.

In order to force remove a container:
```
docker container rm -f <container-ref>
```

### Getting a shell inside a container

If you're just starting a container and want a shell into it, then you can add the `-it` flags to the run command:
It's a combination of two flags:
* `t` - opens up a terminal
* `i` - keeps the terminal open and makes it interactable

After the image name you can add a command that'll be run inside the container.

So the example below opens up bash in the terminal.

```bash
docker container run -it nginx bash
```

The full structure of the run command is this:
```
docker container run [OPTIONS] IMAGE [COMMAND] [ARG...]
```

To connect to an already running container, then you can use:
```
docker container exec -it <container-ref> bash
```

## Networks

### See all networks

```bash
docker network ls
```

By default, you'll see three:
* bridge - the default bridge network
* host - the host network, so if you want to directly connect to the host
* null - if you want to detach from all networks 

### See specific network details

```
docker network inspect <specific-network>
```

You can see there, for example, the containers that are on that network.

### Create a new network

```
docker network create <network-name>
```

To attach a container to the new network, add the `--network <network-name>` flag when creating the container. 

### Attach an existing container to a network

```
docker network connect <network-ref> <container-ref>
```

The network-ref is either by ID or name. Same for the container-ref.

### Remove an existing container from a network

```
docker network disconnect <network-ref> <container-ref>
```