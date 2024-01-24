# Persistent Data

Built Docker images are immutable.

Docker containers are usually immutable (unchanging) and ephemeral (temporary).

Only re-deploy containers, never change.

However, if you need to persist data, Docker provides two ways of doing that.

## Volumes

Managed by Docker itself.
When you use a volume, a new directory is created within Docker’s storage directory on the host machine, and Docker manages that directory’s contents.

A Volume can be created via the Dockerfile, using the `VOLUME` statement.

For example, in the MySQL image, you have:
```
VOLUME /var/lib/mysql
```

A volume, by default has a hash as its name.
To name it, when running the container, you can add a `-v` flag and prepend the name to the volume path.
```
-v mysql-db:/var/lib/mysql
```

Use case: Volumes are the preferred way to persist data in Docker containers and services. They’re especially useful for when you want to store your container’s data on a remote host or a cloud provider, rather than locally.

## Bind Mounts

Link path from the host to the container.
The downside of this is that it relies on knowledge of the host file system.
Something that can change.

These can't be inside a Dockerfile. Must be set with a `container run` command.
* container run -v /Users/path/in/host:/path/container (Mac/Linux)
* container run -v //c/Users/path/in/host:/path/container (Windows)

Use Case: Ideal for development environments where you need to quickly and easily access files from the host system in the container, or for situations where specific files or directories on the host system need to be exposed to the container.