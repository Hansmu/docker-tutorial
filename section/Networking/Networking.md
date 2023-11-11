# Networking

## Virtual networks

Each container that you start is connected to a private virtual network.
The default is the "bridge" network.

Each virtual network routes out through the NAT firewall on the host IP.

All containers on a virtual network can talk to each other without `-p`.

Best practice is to create a new virtual network for each app:
* one network for mysql and php/apache containers
* one network for mongo and nodejs containers

Docker is "batteries included, but removable".
The defaults work well, but they're all changeable.

You can:
* Make new virtual networks
* Attach containers to multiple virtual networks
* Skip virtual networks and connect directly to the host
* And much, much more

If you have multiple virtual networks, then they route through the host.

## DNS

The IPs are dynamic.
As containers get changed/removed, then the IPs change.
Docker uses the container names as the equivalent of host names for containers when talking to each other.
This, however, does not work on the default `bridge` network.
You need to create a new network.

This can be tested with:
```
docker container exec -it <source-container-name> ping <target-container-name>
```

Docker defaults to the container name, but you can also add aliases.

You can create links in the default network as well, but it's just easier to create a new one.

You can have multiple containers behind the same DNS address. 
What you'll find is that you can't have multiple containers with the same name.
However, you can specify the `-network-alias <name>` flag to add DNS aliases to the containers, which can be duplicated.