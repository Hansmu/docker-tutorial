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
