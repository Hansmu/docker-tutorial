# Persistent Data

Docker images are immutable — once built, they never change.

Docker containers are ephemeral (temporary) by design.

They can change while running, but those changes are not meant to be permanent. Containers are expected to be stopped, removed, and re-created.

> Best practice: Rebuild images and redeploy containers instead of relying on container filesystem changes.

If an application needs to persist data beyond the lifetime of a container, Docker provides mechanisms to store data outside the container’s writable layer.

The two most common persistence mechanisms are:
* Volumes
* Bind mounts

---

## Volumes

Volumes are managed by Docker itself.

When you use a volume:
* Docker creates and manages a directory on the host system
* The container reads and writes data through a mount point
* The actual storage location is abstracted away from you

This makes volumes portable, safe, and production-friendly.

---

### Volume declaration vs creation

Docker uses the term volume in two related but distinct ways, which can be confusing at first:

1. Declaring that a path inside the container should be backed by a volume
2. Creating an actual volume that stores data on the host

Understanding the difference is critical to knowing where your data lives.

#### Volume declaration (Dockerfile)

A volume can be declared in a Dockerfile using the VOLUME instruction:

```dockerfile
VOLUME /var/lib/mysql
```

This does not create a volume or store any data by itself.

Instead, it tells Docker:

> “The directory /var/lib/mysql inside the container should not use the container’s writable layer.
> It should be backed by external storage.”

This path is now considered a mount point.

A mount point is simply a directory inside the container where external storage (a volume or bind mount) is attached.

At this stage:
* No storage is created yet
* No volume name is assigned
* The instruction only defines where persistent data should live


#### Volume creation (runtime)

A volume is actually created at runtime, not at build time.

This happens in one of three ways:

##### Docker auto-creates an anonymous volume

If an image declares a volume and no volume is specified when the container starts:

```bash
docker container run mysql
```

Docker will:
* create an anonymous volume
* mount it at the declared mount point (``/var/lib/mysql``)
* persist data even if the container is removed

This behavior is why database images work out of the box.

##### You explicitly create or reference a named volume

```bash
docker container run -v mysql-db:/var/lib/mysql mysql
```

Docker will:
* create the volume ``mysql-db`` if it doesn’t exist
* mount it at ``/var/lib/mysql``
* reuse the same data across containers

Named volumes are easier to manage and are usually preferred.

##### A volume is created ahead of time
```bash
docker volume create mysql-db
```

This creates storage without attaching it to a container yet.

---

### Named vs anonymous volumes

* Anonymous volumes
  * Created automatically
  * Have randomly generated names
  * Harder to manage
* Named volumes
  * Explicitly created by the user
  * Easy to reference and reuse
  * Recommended in most cases

Example of a named volume:
```bash
-v mysql-db:/var/lib/mysql
```

---

### Volume lifecycle

* Volumes exist independently of containers
* Removing a container does not remove its volumes
* Multiple containers can share the same volume

--- 

### When to use volumes

Volumes are the preferred solution for persistent data in Docker, especially for:
* databases
* application state
* production workloads
* orchestration environments (Docker Compose, Kubernetes)

Volumes are host-attached but decoupled from specific host paths, making them more portable than bind mounts.

---

## Bind Mounts

Bind mounts directly link a specific directory on the host to a directory inside the container.

```bash
-v /path/on/host:/path/in/container   # macOS / Linux
-v //c/path/on/host:/path/in/container # Windows
```

The container reads and writes files directly on the host filesystem.

---

### Characteristics of bind mounts

* Depend on exact host paths
* Require knowledge of the host filesystem
* Not managed by Docker
* Highly flexible, but less portable

Bind mounts cannot be fully defined in a Dockerfile because the host path is environment-specific. They must be configured at runtime (or via Compose).

---

### When to use bind mounts

Bind mounts are ideal for:
* development environments
* live code reloading
* debugging
* situations where host files must be directly accessible

They are not recommended for production due to tight coupling to the host filesystem.

---

## What happens to data when a container is removed?

* No volume or bind mount → data is lost
* Volume → data persists
* Bind mount → data persists on the host

---

## Appendix

### Mount points

A mount point is a directory inside the container where external storage is attached.

Examples of mount points:

* ``/var/lib/mysql``
* ``/data``
* ``/app/logs``

From inside the container:
* the directory looks like a normal folder
* but its contents live outside the container filesystem

Key behaviors:
* Writing to a mount point does not modify the image or container layer
* Removing the container does not delete the volume
* The same mount point can be reused by multiple containers

#### Mental model

The container provides the path (mount point).

The volume provides the storage.

Docker connects them at runtime.

#### Why Docker separates declaration from creation

This separation allows:

* images to declare what needs to persist without knowing where it will be stored
* users to decide how and where data is stored (named volume, bind mount, cloud-backed volume)
* the same image to be used in many environments without changes

#### Common pitfall

If you rely only on VOLUME declarations:
* Docker will create anonymous volumes
* These can accumulate over time
* leanup becomes harder

For this reason:
> Prefer explicitly named volumes in production and long-running setups.