# Networking

Docker provides virtual networks that allow containers to communicate with each other and with the outside world in a predictable and isolated way.

---

## Virtual networks

Every container that starts is connected to a Docker network.
* If no network is specified, Docker connects the container to the default bridge network
* Docker networks are virtual, implemented by Docker on the host

---

## Default behavior

* Containers on the same Docker network can communicate with each other without publishing ports
* Port publishing (``-p``) is only required for host ↔ container traffic
* Container ↔ container traffic works through the virtual network directly

---

## NAT and external access

Docker networks use NAT (Network Address Translation):
* Containers have private IP addresses
* Outbound traffic is routed through the host’s network stack
* Containers can access the internet by default
* External systems cannot access containers unless ports are published

---

## Network isolation

Docker networks are isolated by default:
* Containers on different networks cannot communicate
* Traffic does not automatically route between networks
* A container must be explicitly attached to multiple networks to bridge traffic

This isolation is a key security feature.

---

## Best practice

Create one user-defined network per application stack:
* Improves security
* Simplifies reasoning about traffic
* Matches how Docker Compose works by default

Example:
* ``mysql`` + ``api`` → one network
* ``redis`` + ``worker`` → another network

---

## Network types (high-level)

* bridge (default and user-defined)
  * Most common
  * Supports container-to-container communication
* host
  * Container shares the host network
  * Linux-only behavior
* none
  * No network access

---

## DNS and service discovery

### Dynamic IPs
* Container IP addresses are dynamic
* Containers can be recreated at any time
* IPs must never be hardcoded

---

## DNS on Docker networks

Docker provides built-in DNS on user-defined bridge networks.

On these networks:
* Each container is reachable by its container name
* DNS resolution is automatic
* No manual configuration required

This does not work on the default bridge network.

--- 

### Correct DNS behavior

| Network type        | DNS by container name |
| ------------------- | --------------------- |
| default `bridge`    | ❌ No                  |
| user-defined bridge | ✅ Yes                 |

This is why creating a custom network is recommended.

---

## Testing DNS resolution

You can test container-to-container DNS like this:

```bash
docker container exec -it source ping target
```

This works only if:
* both containers are on the same user-defined network
* target is the container name or alias

---

## Network aliases

Docker allows network-scoped DNS aliases.
* Aliases are added per network
* Multiple containers can share the same alias
* Useful for load-balancing patterns

Example:
```bash
docker container run --network mynet --network-alias app myimage
```

Docker performs DNS round-robin across containers sharing the alias.

---

## Deprecated behavior

* ``--link`` (could be used so that containers could find each other) is legacy and deprecated
* Modern Docker networking replaces it entirely
* Avoid using ``--link`` in new setups

---

## Host networking

Using ``--network`` host:
* Container shares the host’s network stack
* No isolation
* No port publishing needed

Important notes:
* Works as expected only on Linux
* On macOS/Windows (Docker Desktop), behavior differs due to the VM

Use sparingly.

---

## Key takeaways

* Containers communicate freely within the same network
* Networks are isolated by default
* User-defined bridge networks provide DNS
* Port publishing is only for host access
* Hardcoding IPs is always a mistake

---

## Hands-on Examples (Validate the Theory)

Below are simple, practical examples you can run locally.

---

### Example 1: Container communication without -p

#### Step 1: Create a network

```bash
docker network create mynet
```

#### Step 2: Run two containers

```bash
docker container run -d --name web --network mynet nginx
docker container run -it --rm --network mynet busybox ping web
```

* ✅ ping web works
* ✅ No ports published
* ✅ DNS resolution by container name

---

### Example 2: Default bridge DNS failure

```bash
docker container run -d --name web nginx
docker container run -it --rm busybox ping web
```

* ❌ DNS resolution fails
* This demonstrates why the default bridge network is discouraged.

---

### Example 3: Isolated networks

```bash
docker network create net1
docker network create net2

docker run -d --name first --network net1 nginx
docker run -d --name second --network net2 busybox
```

```bash
docker exec -it second ping first
```

* ❌ Containers cannot communicate
* Networks are isolated by default.

---

### Example 4: Network aliases (DNS round-robin)

```bash
docker network create appnet

docker run -d --network appnet --network-alias api nginx
docker run -d --network appnet --network-alias api nginx

docker run -it --rm --network appnet busybox nslookup api
```

* ✅ DNS resolves to multiple IPs
* This is Docker’s built-in DNS round-robin.

---

### Example 5: Host ↔ container access

```bash
docker run -d -p 8080:80 nginx
```

* Visit http://localhost:8080
* Publishing ports is required for host access
