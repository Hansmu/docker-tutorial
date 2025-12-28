# Images and containers

## What happens when you run ``docker container run``?

When you execute ``docker container run <image>``, Docker performs the following steps:
1. Checks the local image cache
   * Docker looks for the specified image locally.
2. Pulls the image from a registry if missing
   * If the image is not found locally, Docker pulls it from a remote registry
   * (Docker Hub by default).
3. Downloads only missing layers
    * Images are composed of layers. Docker downloads only the layers that are not already present.
4. Creates a new container from the image
   * A container is created using the image as a read-only template.
5. Connects the container to a Docker network
   * By default, the container is attached to the ``bridge`` network and receives:
     * an internal IP address
     * DNS-based name resolution
6. Sets up port forwarding (if publishing ports)
   * If the ``--publish (-p)`` flag is specified, Docker creates port-forwarding (NAT) rules that map a port on the host to a port inside the container.
7. Starts the container’s main process
   * Docker runs the image’s default ``CMD``, unless a command is explicitly provided in the ``docker container run`` command (which overrides ``CMD``).

---

## Dockerfile vs Image vs Container

### Dockerfile

A Dockerfile is a text file that defines how to build an image.

It contains instructions for:
* selecting a base image
* installing dependencies
* configuring the runtime behavior

---

### Image

A Docker image is a read-only blueprint used to create containers.

An image contains:

* application binaries and dependencies
* filesystem layers
* metadata describing how the image should run

A single image can be used to create many containers.

---

### Container

A container is a running instance of an image.
* Containers are created from images
* Containers execute processes
* Containers have their own isolated runtime environment

![Images vs containers](./images/imagesVsContainers.png)

![Dockerfile builds an image, which runs a container](./images/dockerfile-vs-image-vs-container.png)

---

## Docker Hub

Docker Hub is a centralized image registry used to store and share Docker images.

A typical Docker workflow:
1. Pull an existing base image (e.g. node, nginx)
2. Build a custom image on top of it

Docker Hub provides:
* Official images (maintained with help from Docker)
* Community images
* Public and private repositories

### Choosing images

* Prefer official images whenever possible
* If using non-official images:
  * check popularity
  * review documentation
  * inspect source code when available

---

## Image tags and versions

Images can be versioned using tags.
* If no tag is specified, Docker uses ``latest``
* ``latest`` is just a tag, not a guarantee of stability or recency
* In production, always pin specific versions

Example references:
```
<user>/<repo>:<tag>
mysql/mysql-server:8.0

<repo>:<tag>        # Official image
nginx:1.25
```

Tags are mutable pointers. For absolute immutability, images can also be referenced by digest.

---

## Image layers

Docker images are built using a union filesystem.
* Each image is composed of multiple layers
* Each layer represents a filesystem change
* Layers are stacked to form a single unified filesystem

You can inspect image layers using:
```bash
docker image history <image>
```

![Docker image history](./images/docker-history.png)

Layers marked as ``<missing>``:
* still exist
* do not have a local image ID
* often come from base images

---

## Dockerfile layers and caching

* Each instruction in a Dockerfile creates a new layer
* Layers are cached
* If a layer’s output changes:
  * that layer and all following layers are rebuilt
* If the output is unchanged:
  * Docker reuses the cached layer

For optimal caching:
* place rarely changing instructions near the top
* place frequently changing instructions (e.g. application code) near the bottom

---

## Container writable layer

Images are read-only.

When a container starts:
* Docker adds a read/write container layer on top of the image
* All filesystem changes occur in this layer:
  * creating files
  * modifying files
  * deleting files

The underlying image layers are never modified.

![Docker container layer](images/container-layer.png)
![Docker container image reuse](images/container-reuse.png)

---

## Dockerfile basics

To create a custom image, you define a Dockerfile.
* Dockerfile is the default filename
* A different filename can be specified using:
  ```bash
    docker build -f <filename>
  ```

---

## Example Dockerfile
```dockerfile
# The FROM is always required.
# It is normally a minimal distribution. It's usually alpine nowadays.
# You'd mainly want a Linux distribution to use their package managers to install things.
FROM debian:bullseye

# You can define environment variables with this.
# It's an optional property.
ENV SOME_VALUE=some-value

# Optional commands that are run in the shell at build time
# If you chain commands in a single RUN (&& ... &&), then all of those will be put into a single layer.
# So if there are things that should be grouped together, make it so that layer caching would work properly.
RUN echo "${SOME_VALUE}"

# You can have multiple RUN commands
RUN echo "Hello"

# Optional. Informative to the consumer on what ports can be used.
EXPOSE 80 443

# Required. It is the final command that will be run every time you launch a new container from the image.
# Or every time you restart a stopped container.
CMD ["nginx", "-g", "daemon off;"]
```

### Instruction overview

* FROM
  * Required. Defines the base image.
* ENV
  * Optional. Sets environment variables.
* RUN
  * Executes commands at build time and creates layers.
* EXPOSE
  * Informational only. Documents which ports the container may use.
* CMD
  * Defines the default command run when a container starts.
  * This can be overridden in ``docker container run``.

---

## Building and running images

* A Dockerfile is a blueprint
* Building a Dockerfile creates an image
* Running an image creates a container

If the container’s main process runs indefinitely (e.g. a server), the container remains running.

---

## Ports and immutability

* EXPOSE does not publish ports, it's only informational
* Ports are published using:
    ```
    -p <host-port>:<container-port>
    ```

Docker images are immutable:
* changing a Dockerfile does not affect existing images
* images must be rebuilt to apply changes

---

## Extending images

When building on top of an existing image:
* FROM is always required
* other instructions (CMD, EXPOSE, etc.) may already be defined
* redefining them is optional and overrides previous values

---

## Dockerfile Instructions: CMD, ENTRYPOINT, and Command Forms

This section covers how Dockerfile instructions behave, when they apply, and how ``CMD`` and ``ENTRYPOINT`` work together, including best practices for ``exec`` vs ``shell`` forms.

---

### Dockerfile instructions: overwrite vs additive

When adding instructions to a Dockerfile, it’s useful to ask:

#### 1️⃣ Does this instruction overwrite previous values or add to them?

Some instructions are additive, while others overwrite previous definitions.

##### Additive instructions

These instructions add behavior or metadata without removing previous uses:

* ``RUN``
  * Each ``RUN`` creates a new layer.
* ``EXPOSE``
  * Multiple ports can be exposed across multiple instructions.
* ``COPY``, ``ADD``
  * Each adds files to the image filesystem.
* ``ENV``
  * Adds or updates environment variables (later values override earlier ones by key).

##### Overwriting instructions

These instructions replace any previous definition of the same type:

* ``CMD``
  * Only one CMD is active — the last one wins.
* ``ENTRYPOINT``
  * Only one ENTRYPOINT is active — the last one wins.
* ``WORKDIR``
  * Each new value replaces the previous working directory.

---

### Dockerfile instructions: build time vs runtime

Another key question:

#### 2️⃣ Does this instruction affect the image at build time or the container at runtime?

##### Build-time instructions

These affect the image and are executed during ``docker build``:
* ``FROM``
* ``RUN``
* ``COPY``
* ``ADD``

They define the image’s filesystem and layers.

##### Runtime instructions

These affect container startup, not the image build:
* ``CMD``
* ``ENTRYPOINT``

They define what happens when a container starts.

##### Both build-time and runtime

Some instructions affect the image and are available at runtime:
* ``ENV``
  * Stored in the image metadata
  * Available to the container process

---

### CMD vs ENTRYPOINT

#### CMD
* Defines the default command or arguments
* Can be overridden at runtime:
  ```bash
  docker run my-image bash
  ```
* Only one CMD is used (last one wins)

#### ENTRYPOINT

* Defines the main executable for the container
* Intended to be harder to override
* Ideal for:
  * CLI tools
  * startup scripts
  * fixed application entrypoints

ENTRYPOINT does not replace CMD — it works with it.

---

### How Docker executes ENTRYPOINT and CMD

When both are defined, Docker combines them:

```text
ENTRYPOINT + CMD → final command
```

Example
```Dockerfile
ENTRYPOINT ["curl"]
CMD ["--help"]
```

Docker executes:
```bash
curl --help
```

If you run:
```bash
docker run my-curl http://google.com
```

Docker executes:
```bash
curl http://google.com
```

CMD becomes default arguments, which the user can override.

---

### When ENTRYPOINT provides value

``ENTRYPOINT`` is most useful when:
* You want to create a CLI-like container
* You want a fixed executable with configurable arguments
* You want a startup script to always run

ENTRYPOINT provides the most value when used together with CMD.

#### Example: CLI-style container

```Dockerfile
FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["curl"]
CMD ["--help"]

```

Result:

* ``docker run my-curl`` → shows help
* ``docker run my-curl http://google.com`` → fetches URL

##### Best practice reminder

When installing packages:
* Combine apt-get update and apt-get install
* Remove /var/lib/apt/lists/*
* This avoids unnecessary image bloat

---

#### ENTRYPOINT for startup scripts

A common pattern is:
* ENTRYPOINT → startup script
* CMD → final process

Example:
```Dockerfile
ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "server.js"]
```

The entrypoint script prepares the environment, then runs the app.

##### Important: exec "$@" in entrypoint scripts

``ENTRYPOINT`` shell scripts must use:

```sh
exec "$@"
```

Why this matters:
* Replaces the shell with the final process
* Ensures the app runs as PID 1
* Allows proper signal handling (SIGTERM, SIGINT)

Without exec, signals may not reach your application correctly.

---

### Exec form vs shell form

Dockerfile commands can be written in two forms.

---

#### Exec form (recommended for ENTRYPOINT and CMD)

```Dockerfile
CMD ["node", "server.js"]
ENTRYPOINT ["nginx", "-g", "daemon off;"]
```

Characteristics:
* No shell involved
* Correct signal handling
* Arguments passed cleanly
* Required for ENTRYPOINT + CMD composition


✅ Always use exec form for ENTRYPOINT

✅ Prefer exec form for CMD

---

#### Shell form

```Dockerfile
CMD node server.js
RUN echo "Hello"
```

Characteristics:
* Executed via ``/bin/sh -c``
* Shell features available (``&&``, ``|``, variables)
* Signals may not propagate correctly

---

#### When to use shell form

##### Recommended use
* RUN instructions (shorter, readable)
* Commands that require shell features

##### Use with caution
* ``CMD`` shell form is acceptable only if shell behavior is required
* Avoid shell form for ENTRYPOINT

---

#### Critical rules of thumb (memorize these)

* RUN → shell form is fine
* ENTRYPOINT → always exec form
* CMD → exec form by default
* ENTRYPOINT + CMD → both must be exec form
* ENTRYPOINT scripts → must end with exec "$@"

---

## Appendix

### Why exec "$@" matters in ENTRYPOINT scripts (PID 1 explained)

#### What is PID 1?

Inside every Linux system (including containers), PID 1 is the first process started.

PID 1 has special responsibilities:
* Receives termination signals (SIGTERM, SIGINT)
* Is responsible for:
  * handling or forwarding signals
  * reaping zombie processes (child processes that have exited)

In a container:
> Whatever command Docker starts becomes PID 1.

---

#### Why PID 1 behavior is special

PID 1 behaves differently from normal processes:

* Default signal handling is different
* If PID 1 ignores a signal, the container does not stop
* If PID 1 does not reap child processes, zombies accumulate

This is why containers can:
* fail to shut down gracefully
* hang on docker stop
* leak zombie processes

---

#### What goes wrong without exec "$@"
Common mistake
```sh
#!/bin/sh
# entrypoint.sh
echo "Setting things up..."
node server.js
```


Docker runs:
```
sh (PID 1)
└── node server.js (PID 2)
```

Problems:
* ``sh`` is PID 1
* ``node`` is not
* Signals go to ``sh``, not to ``node``
* ``sh`` does not forward signals by default

Result:
* ``docker stop`` sends ``SIGTERM``
* ``node`` never receives it
* Container may hang or be force-killed

---

#### What exec "$@" does

Correct pattern

```sh
#!/bin/sh
# entrypoint.sh
echo "Setting things up..."
exec "$@"
```

Now Docker runs:
```
node server.js (PID 1)
```

What ``exec`` does:
* Replaces the shell process with the target command
* No extra process layer
* The final app becomes PID 1

---

#### Why this fixes signal handling

With exec "$@":
* Your application:
  * receives SIGTERM, SIGINT, etc.
  * can shut down gracefully
* Docker can:
  * stop containers cleanly
  * respect timeouts

This is essential for:
* graceful shutdowns
* clean restarts
* production stability

---

#### Why ENTRYPOINT + CMD depends on this

When using:
```Dockerfile
ENTRYPOINT ["/entrypoint.sh"]
CMD ["node", "server.js"]
```

Docker passes ``CMD`` as arguments to the ``ENTRYPOINT``.

Inside ``entrypoint.sh``:

* ``$@`` expands to:
  ```
  node server.js
  ```
* ``exec "$@"`` hands control to the real app

Without ``exec``, ENTRYPOINT becomes a signal black hole.

---

#### Zombie processes (another PID 1 responsibility)

PID 1 must also reap child processes.

If it doesn’t:
* child processes exit
* remain as zombies
* consume process table entries

Shells and some apps:
* do not properly reap children
* especially when PID 1

This is why:
* some containers include ``tini``
* some base images provide init systems

---

#### When you might need an init process

If your container:
* runs multiple processes
* spawns background workers
* uses shell scripts extensively

You may need:

```Dockerfile
ENTRYPOINT ["tini", "--"]
CMD ["node", "server.js"]
```

``tini``:
* becomes PID 1
* forwards signals
* reaps zombies

---

#### Mental model (very important)

> PID 1 is special.
> 
> Shells make terrible PID 1s.
> 
> ``exec "$@"`` fixes that.
