# Docker Swarm Guide

This section looks at how to enable Docker Swarm and what do the steps do.

![alt text](image.png)

![alt text](image-6.png)

## Environment

The example below uses 3 machines.

Environment used:  
https://labs.play-with-docker.com/

This environment is useful because:
- machines are already provisioned
- Docker is preinstalled
- networking between nodes is set up

---

## High-level overview

At a high level, the steps are:

1. Initialize a Swarm (first manager)
2. Join other machines as workers or managers
3. Create an overlay network
4. Create a service and observe scheduling
5. Verify networking and container placement

## 1) Pick one machine to become the first manager

Choose one machine to act as the initial manager.

On that machine, run:
```bash
docker swarm init
```
![Docker Swarm init output](docker-swarm-init-output.png)

### What this does internally
- Enables Swarm mode on the node 
- Makes this node a manager 
- Initializes the Swarm’s Raft database 
- Generates join tokens for other nodes 
- Starts listening on port 2377 for cluster management traffic

At this point:
- The cluster exists 
- It has exactly one node 
- That node is both manager and worker

### Retrieve join tokens

To allow other machines to join, retrieve the join commands:

```bash
docker swarm join-token worker
docker swarm join-token manager
```

These commands output:
- a secure token 
- the manager’s IP and port

Tokens:
- authenticate new nodes
- determine their role (worker or manager)

---

## 2) Join the other machines to the swarm

On each additional machine, run the worker join command:
```bash
docker swarm join --token <token> <manager-ip>:2377
```

![alt text](image-3.png)

![alt text](image-5.png)

What happens when a node joins
- The node authenticates using the token 
- Mutual TLS certificates are issued 
- The node connects to the manager 
- The manager adds the node to cluster state

At this point:
- The node becomes part of the cluster 
- It does not make decisions 
- It waits for tasks to be assigned

On the manager, confirm:

```bash
docker node ls
```

This shows:
- all nodes in the cluster
- their roles (manager / worker)
- availability and status

![alt text](image-4.png)

If you want to promote a node that joined as a worker, then you could run:

```bash
docker node update --role manager <node hostname>
```

This:
- adds the node to the Raft consensus group
- allows it to participate in scheduling and cluster decisions

In production:
- managers are usually promoted intentionally
- odd numbers of managers are preferred (3 or 5)

---


## 3) Create an overlay network

Swarm services communicate across machines using overlay networks.

```bash
docker network create -d overlay my-overlay
```

Why this is required
- The default bridge network is local to a single node 
- Containers on different machines cannot communicate without an overlay network 
- Overlay networks provide:
  - multi-host connectivity 
  - built-in DNS 
  - optional encryption

Without an overlay network:
- containers in the service would start 
- but they would not be able to reach each other

---

## 4) Create a service on a manager machine

Create a service attached to the overlay network:
```bash
docker service create \
  --replicas 3 \ 
  --name test-services \ 
  --network my-overlay \
  busybox ping 8.8.8.8
```

### What happens internally
1. The manager records the service definition 
2. Desired state: 3 replicas 
3. Scheduler selects nodes 
4. Tasks are assigned to nodes 
5. Workers create containers 
6. Containers begin executing ping

![alt text](image-8.png)

---

### Verify that the service exists:

```bash
docker service ls
```

This shows:
- service name
- desired vs running replicas
- overall service state

![alt text](image-9.png)

---

### Inspect service tasks:

```bash
docker service ps <service reference>
```

![Docker service ps output showing services](docker-service-ps-output.png)

Important observations:
- Each task runs on a different node
- This demonstrates Swarm’s scheduler in action
- Placement is automatic — you didn’t choose nodes manually

---

### Inspect containers on a node:

On any node:
```bash
docker container ls
```

You’ll see:
- only the containers scheduled on that node
- a one-to-one relationship with tasks listed earlier

![Docker container ls on node showing container running on it](docker-container-ls-on-node.png)

Go into a container to verify connectivity:

```bash
docker exec -it <ref> sh
```
Observations:
- Container names follow the pattern:
    ```
    <service>.<replica-number>.<task-id>
    ```
- This naming reflects:
  - service ownership 
  - task identity 
  - immutability of tasks

![alt text](image-12.png)

---

### Networking validation 

The container can reach:
- other containers 
- external IPs (like 8.8.8.8)

This works because of the overlay network.

If the overlay network did not exist:
- containers would start
- but communication would fail

---

### Notes on managers running containers

In this example:
- manager nodes are also running containers

This is fine for:
- demos 
- learning environments 
- very small clusters

In production:
- managers should ideally only manage 
- workloads should run on workers

You can enforce this using constraints:

````bash
docker service create \
--name web \
--constraint 'node.role==worker' \
nginx
````

---

### Core mental model

> Managers decide.
>
> Workers execute.

Managers:
- maintain cluster state
- schedule tasks

Workers:
- run containers
- report status

Once this clicks, Swarm behavior becomes predictable.
