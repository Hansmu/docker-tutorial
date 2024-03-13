# Docker Compose

Docker Compose is a tool for defining and running multi-container Docker applications.
With Compose, you use a YAML file to configure your application's services.
Then, with a single command, you create and start all the services from your configuration.
To tear it down, you can use a single command as well.

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

Compose isn't only for external dependencies.
You can also make it build your custom image, then run it.
It'll look in the cache, and if the image isn't there, it'll build them.

If you need to rebuild it, and it's sitting in the cache, then you need to explicitly state that it's being rebuilt.

If you need to add a bind mount to a service, then you can do so in the compose file.
Use the `volumes` key. An example is in the [docker-compose-custom-build.yml](./composeBuildExample/docker-compose-custom-build.yml) file.