# Docker Swarm Mode

Docker Swarm mode is Docker’s native container orchestration system.
  
It allows you to run Docker containers across multiple machines (nodes) as a single logical cluster.

Swarm mode is built directly into Docker Engine — no extra software is required.

---

## What problem does Swarm solve?

Running containers on a single machine is easy.

Running containers across multiple machines introduces new problems:
- How do containers find each other?
- What happens if a machine goes down?
- How do you scale services?
- How do you deploy updates without downtime?

Docker Swarm solves these problems by providing:
- clustering
- scheduling
- service discovery
- load balancing
- rolling updates
- fault tolerance

---

## Swarm vs standalone Docker

| Standalone Docker | Docker Swarm |
|------------------|-------------|
| Single host | Multiple hosts |
| `docker run` | `docker service` |
| Manual scaling | Declarative scaling |
| No built-in HA | Built-in high availability |
| Containers | Services & tasks |

Swarm operates at the service level, not the container level.

---

## Swarm architecture

A Swarm cluster consists of nodes.

### Node types

#### Manager nodes
- Maintain cluster state
- Schedule services
- Handle orchestration decisions
- Participate in Raft consensus

#### Worker nodes
- Run containers (tasks)
- Do not make scheduling decisions
- Execute work assigned by managers

A single-node Swarm is possible, but production Swarms use multiple managers.

![Managers give orders to workers](image.png)

---

## Desired state model

Swarm uses a declarative desired-state model.

You declare:
> “I want 5 replicas of this service.”

Swarm continuously works to make reality match that declaration.

If:
- a container crashes
- a node goes offline

Swarm automatically replaces missing tasks.

---

## Services and tasks

### Service
A service defines:
- which image to run
- how many replicas to run
- how the service is exposed
- update strategy
- resource limits

### Task
A task is a single running container created to satisfy a service.

- One service → many tasks
- Tasks are immutable
- Failed tasks are replaced, not restarted

![Services running multiple nodes](image-1.png)

---

## Creating a Swarm

```bash
docker swarm init
```

This:
* enables Swarm mode
* makes the node a manager
* creates a cluster

Other nodes join using a join token:

```bash
docker swarm join --token <token> <manager-ip>:2377
```

---

## Services vs containers

In Swarm mode, you normally do not use ``docker run``.

Instead, you use:

```bash
docker service create
```

Example:
```bash
docker service create --name web --replicas 3 -p 80:80 nginx
```

Swarm:
* schedules replicas across nodes
* load-balances traffic
* restarts failed tasks

---

## Scaling services

Scaling is declarative:

```bash
docker service scale web=5
```

Swarm adds or removes tasks automatically.

---

## Built-in load balancing

Swarm provides two layers of load balancing:

1. Routing mesh (ingress)
   * Every node listens on the published port
   * Traffic is routed to any healthy task
   * Even if the task is on another node
2. Internal service discovery
   * Services get a virtual IP (VIP)
   * DNS-based discovery
   * Internal load balancing across tasks

---

## Networking in Swarm

Swarm uses overlay networks:
* Span multiple hosts
* Encrypted (optional)
* Built-in DNS

Example:

```bash
docker network create --driver overlay app-net
```

Services attached to the same overlay network can:
* communicate by service name
* be load-balanced automatically

---

## Volumes and data in Swarm

Persistent data is harder in Swarm.

Important points:
* Containers may run on any node
* Local volumes are node-specific
* Swarm does not automatically move data

Common solutions:
* network-attached storage
* volume plugins
* external databases

Best practice:

> Avoid stateful workloads in Swarm unless you understand the storage implications.

---

## Rolling updates

Swarm supports rolling updates out of the box.

Example:

```bash
docker service update --image my-app:v2 web
```

You can control:
* update parallelism
* delay between updates
* failure behavior

This enables zero-downtime deployments.

---

## Health checks

If a container becomes unhealthy:
* Swarm marks the task as failed
* A new task is scheduled automatically

Health checks are defined in the image:

```bash
HEALTHCHECK CMD curl -f http://localhost || exit 1
```

---

## Secrets and configs

Swarm has built-in secrets management.

Secrets:
* stored encrypted
* mounted into containers at runtime
* never baked into images

Example:

```bash
docker secret create db_password password.txt
```

---

## High availability

For production:
* use odd numbers of manager nodes
* typically 3 or 5
* ensures Raft quorum

If quorum is lost:
* cluster becomes read-only
* existing services keep running
* no new scheduling decisions

---

## Swarm vs Docker Compose

| Docker Compose      | Docker Swarm          |
| ------------------- | --------------------- |
| Single host         | Multi-host            |
| Development-focused | Production-capable    |
| No HA               | Built-in HA           |
| No scheduler        | Distributed scheduler |

Swarm uses Compose-style files, but behavior differs.

---

## When to use Docker Swarm

Good use cases:
* Small to medium clusters
* Teams already familiar with Docker
* Simple production orchestration
* Learning orchestration concepts

Not ideal when:
* You need advanced scheduling
* You need complex networking policies
* You already use Kubernetes
* You need a large ecosystem

---

## Swarm vs Kubernetes (high-level)

* Swarm is simpler and easier to learn
* Kubernetes is more powerful and extensible
* Swarm has minimal ecosystem growth
* Kubernetes dominates industry adoption
* Swarm is still useful as a learning bridge.

---

## Key takeaways

* Swarm is Docker’s built-in orchestrator
* Operates on services, not containers
* Uses desired-state reconciliation
* Provides networking, load balancing, scaling
* Simpler than Kubernetes, less powerful
* Still valuable for understanding orchestration