# Docker Compose

Docker Compose is a tool for defining and running multi-container Docker applications.

With Docker Compose, you:
* describe your application using a YAML file
* define services, networks, and volumes declaratively
* start and stop the entire application with a single command

Compose is most commonly used for local development, testing, and simple deployments.

An example of the file for compose is:

```yaml
# version isn't needed as of 2020 for docker compose CLI. 
# All 2.x and 3.x features supported
# Docker Swarm still needs a 3.x version
# version: '3.9'

services:  # containers. same as docker run
  servicename: # a friendly name. this is also DNS name inside network
    image: # Optional if you use build:
    command: # Optional, replace the default CMD specified by the image
    environment: # Optional, same as -e in docker run
    volumes: # Optional, same as -v in docker run
      - some-name-for-a-volume-for-easier-referencing:/var/lib/mysql # Bind the volume to specific data here
  someOtherServiceNameThatIsRandomAndICanNameWhatever:

volumes: # Optional, same as docker volume create

networks: # Optional, same as docker network create
  some-name-for-a-volume-for-easier-referencing: # Create a name for the volume here
```

An actual example file is [compose-example-1.yml](./compose-example-1.yml) file.

---

## Compose file overview

A Compose file defines the desired state of your application.
Docker Compose creates and manages containers to match that state.

A minimal Compose file looks like this:
```yaml
services:
  app:
    image: nginx
```

Compose automatically:
* creates a project-scoped network
* connects all services to that network
* enables DNS-based service discovery

---

## Compose file structure

### Version field

When using docker compose (v2 CLI plugin), the version field is optional.

Legacy `docker-compose` required a version field.

---

### Services

```yaml
services:
  servicename:
    image:
    build:
    command:
    environment:
    volumes:

```

Each service defines how a container should be created and run.

Service definitions are conceptually similar to docker run, but also include:
* networking
* volume mounting
* dependency management
* scaling

---

### Service names and DNS

```yaml
services:
  db:
  api:
```

* Service names must be unique
* Each service name becomes a DNS hostname
* Containers can communicate using service names:

No manual networking setup is required.

---

### Image and build

```yaml
image:nginx
```
* Pulls an existing image from a registry

```yaml
build: .
```
* Builds a custom image from a Dockerfile

You can use both together:
```yaml
build: .
image: my-app:latest
```

An example is in the [docker-compose-custom-build.yml](./composeBuildExample/docker-compose-custom-build.yml) file.

Compose:

* builds the image if needed
* uses the build cache when possible
* rebuilds only when explicitly requested or when inputs change

To force a rebuild:
```bash
docker compose up --build
```

---

### Command

```yaml
command: ["npm", "start"]
```

* Overrides the image’s default ``CMD``
* Does not replace ``ENTRYPOINT``

---

### Environment variables

```yaml
environment:
  NODE_ENV: development
```

Equivalent to:

```bash
docker run -e NODE_ENV=development
```

Compose also supports:
* .env files
* variable substitution

---

### Volumes (inside services)

```bash
volumes:
  - app-data:/var/lib/app
```

This mounts a named volume at the specified container path.

Bind mounts use host paths:
```bash
volumes:
  - ./src:/app
```

An example is in the [docker-compose-custom-build.yml](./composeBuildExample/docker-compose-custom-build.yml) file.

Both use the same ``volumes`` key but behave differently.

---

### Top-level volumes

```bash
volumes:
  app-data:
```

* Declares named volumes used by services
* Docker creates them automatically if they do not exist
* Volumes persist even when containers are removed

---

### Networks

```bash
networks:
  custom-network:
```

* Compose creates a default network automatically
* Custom networks are optional
* All services on the same network can communicate via DNS

---

### Container naming

Compose generates container names using the pattern:

```
<project>_<service>_<index>
```

Example:
```
myapp_api_1
```

This explains why Compose container names differ from ``docker run``.

---

## Compose lifecycle

Common commands:

```
docker compose up
docker compose up -d
docker compose down
```

* ``up`` → create and start containers
* ``down`` → stop and remove containers and networks
* Volumes are preserved unless explicitly removed

Compose manages the full lifecycle of your application.

---

## Build and run together

Compose is not only for external dependencies.

It is commonly used to:
* build application images
* run supporting services (databases, caches, message brokers)
* orchestrate everything together

Compose uses Docker’s build cache and only rebuilds when necessary.

---

## Bind mounts in Compose

Bind mounts can be defined directly in the Compose file:

```yaml
volumes:
  - ./src:/app
```

This is especially useful for:
* development
* live code reloading
* debugging
