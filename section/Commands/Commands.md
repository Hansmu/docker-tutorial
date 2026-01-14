# Commands

Docker commands originally used a flat structure:

```
docker <command> [OPTIONS]
```

As Docker grew, commands were reorganized into management command groups:

```
docker <command> <sub-command> [OPTIONS]
```

The old format still works (for example, `docker run`), but the newer format (`docker container run`) is clearer, better organized, and recommended.

---

## Containers

When referring to a container, you can use:
* the container name
* the container ID (full or shortened)

---

## Running a container

```bash
docker container run --publish 80:80 --detach nginx
```

This command does three things:
* Pulls the image (if it is not already present)
* Creates a container
* Starts the container

### Common options

* `--publish <host-port>:<container-port>`
  * Maps a port on the host machine to a port inside the container
  * Example: host port `80` → container port `80`

* `--detach` (`-d`)
  * Runs the container in the background

* `--name <name>`
  * Assigns a custom name to the container

### Command structure
```
docker container run [OPTIONS] IMAGE [COMMAND] [ARG...]
```

---

## Viewing containers

Show running containers:

```bash
docker container ls
```

Show all containers (including stopped ones):

```bash
docker container ls -a
```

---

## Stopping a container

```bash
docker container stop <container-ref>
```

This sends a graceful shutdown signal to the container’s main process.

---

## Starting an existing container

```bash
docker container start <container-ref>
```

`start` runs an already-created container.
It does not create a new container.

---

## Removing containers

Remove a stopped container:

```bash
docker container rm <container-ref>
```

Remove multiple containers:

```bash
docker container rm a2 f2 d2
```

A running container cannot be removed by default.

Force removal (stop + remove):

```bash
docker container rm -f <container-ref>
```

---

## Getting a shell inside a container

### Starting a container with an interactive shell

```bash
docker container run -it ubuntu bash
```

* `-i` keeps standard input open
* `-t` allocates a pseudo-terminal

> Note: Not all images include `bash`.
> 
> For minimal images (e.g. Alpine), use `sh`.


### Connecting to a running container

```bash
docker container exec -it <container-ref> bash
```

This executes a command inside an already running container.

--- 

## Networks
### List networks

```bash
docker network ls
```

Default networks include:
* `bridge` – default container network
* `host` – container shares the host’s network stack
* `none` – container has no network access

---

### Inspect a network

```bash
docker network inspect <network-ref>
```

Shows details such as connected containers and configuration.

---

### Create a network

```bash
docker network create <network-name>
```

Attach a container to a network at creation time:

```bash
docker container run --network <network-name> ...
```

--- 

### Connect or disconnect a container

Connect:

```bash
docker network connect <network-ref> <container-ref>
```

Disconnect:
```bash
docker network disconnect <network-ref> <container-ref>
```

---

## Docker Compose

Docker Compose is used to define and run multi-container applications.

--- 

### Running a Compose project

```bash
docker compose up
```

Run in the background:

```bash
docker compose up -d
```

> `docker-compose up` still works but is considered legacy.

The default file used for `docker compose` is `docker-compose.yml`.

You can use the `-f` flag to change the filename to use.

```bash
docker compose -f compose.yaml -f compose.admin.yaml up
```

---

### Stopping a Compose project

```bash
docker compose down
```

This:
* stops containers
* removes containers
* removes the default network