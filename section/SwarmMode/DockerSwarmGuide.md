# Docker Swarm Guide

## 1) Pick one machine to become the first manager

On the machine you choose as the manager:

```bash
docker swarm init
```
![alt text](image-2.png)

This creates the swarm and makes that node a manager.

Then get join commands for the other machines:

```bash
docker swarm join-token worker
docker swarm join-token manager
```

---

## 2) Join the other machines to the swarm

On each other machine, run the join command you got (worker is fine to start with):

```bash
docker swarm join --token <token> <manager-ip>:2377
```

![alt text](image-3.png)

![alt text](image-5.png)

Now you have a cluster.

On the manager, confirm:

```bash
docker node ls
```

![alt text](image-4.png)

---

## 2.1) Create a service on your machine

```bash

```

---

## 3) Create an overlay network for your app

Swarm needs an overlay network so services can talk across machines.

docker network create -d overlay app-net


This will be the “private network” that backend, db, and redis use.