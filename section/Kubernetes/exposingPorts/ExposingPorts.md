# Exposing ports

## Why Services exist

Pods are ephemeral:
* they can be recreated at any time
* their IPs change when recreated
* replicas come and go as you scale

So instead of connecting to a specific Pod IP, Kubernetes encourages:
> Connect to a Service, not directly to Pods.

A Service is a Kubernetes resource that provides a stable network identity (DNS name + virtual IP) for a set of Pods.

A Service selects Pods using labels (same concept you saw with Deployments and ReplicaSets).

---

## Service discovery and DNS (CoreDNS)

Kubernetes runs CoreDNS (usually in the kube-system namespace).
Its job is to provide DNS records for Kubernetes Services.

When you create a Service called `my-apache` in the default namespace, CoreDNS makes it resolvable as:
* `my-apache` (when querying within the same namespace, depending on client)
* `my-apache.default.svc.cluster.local` (fully-qualified)

So inside the cluster, other pods can do:
* `curl http://my-apache`
* `curl http://my-apache:80`

…and traffic will be routed to one of the matching pods.

---

## What a Service actually does (mental model)

A Service gives you:
* a stable DNS name
* (usually) a stable virtual IP (ClusterIP)
* load-balancing across matching Pods

Traffic flow (simplified):
```text
client → Service (stable name/IP) → kube-proxy rules → Pod IP
```

Important point:
* The Service does not “run” anything.
* It is configuration + stable identity.
* The routing is implemented by node networking (often via kube-proxy).

---

## Service Types overview

There are four main Service types you’ll see:
1. ClusterIP (default)
2. NodePort
3. LoadBalancer
4. ExternalName

These differ mainly in who can reach the service and how traffic enters the cluster.

---

### 1) ClusterIP

#### What it is
* Default service type
* Provides a stable internal IP and DNS name
* Only reachable from inside the cluster

#### When to use it
* Pod-to-pod communication (backend services, internal APIs, databases)
* Most services in a microservice system are ClusterIP

#### Key properties
* A single internal virtual IP is assigned (clusterIP)
* Reachable from pods (and often from nodes)
* Not reachable directly from outside the cluster (without extra mechanisms)

#### Example creation (for your apache pods)

First ensure your Deployment has a label (it does: `app=my-apache`).

Expose it internally:
```bash
kubectl expose deployment my-apache --port=80 --target-port=80 --name=my-apache-svc
```

Check:
```bash
kubectl get svc
kubectl describe svc my-apache-svc
```

What’s happening:
* Service selects pods with `app=my-apache`
* Requests to the Service are load-balanced to those pods

> `--port` = the service port clients use
> 
> `--target-port` = the container port on the pods

(If you don’t set target-port, Kubernetes may assume it, but it’s better to be explicit while learning.)

---

### 2) NodePort

#### What it is
* Exposes a service on a port of every node
* Accessible from outside the cluster via:

```text
<NodeIP>:<NodePort>
```

#### When to use it
* Learning and quick testing
* Simple “get traffic in from outside” without a cloud load balancer
* Sometimes used as a building block behind an Ingress or external LB

#### Key properties
* Allocates a port in a configured range (commonly 30000–32767)
* Every node listens on that port and forwards to the Service
* Not as flexible/production-friendly as LoadBalancer/Ingress

#### Example
```bash
kubectl expose deployment my-apache \
--type=NodePort \
--port=80 \
--target-port=80 \
--name=my-apache-nodeport
```

Then:
```bash
kubectl get svc my-apache-nodeport
```

Look for PORT(S) like:

```text
80:31234/TCP
```

That means:
* Service port 80
* NodePort 31234

Then you can reach it from your machine (depending on your k3s setup/network):
```text
http://<node-ip>:31234
```
---

### 3) LoadBalancer

#### What it is
* Exposes the Service externally using a cloud/provider load balancer
* On managed Kubernetes (AWS/GCP/Azure), this creates a real external LB.

#### When to use it
* Production clusters on cloud providers
* When you want an external IP and provider-managed balancing

#### Key properties
* Often uses NodePort under the hood, plus an external LB in front
* On a local cluster (like plain k3s), this may not “just work” unless you install something like MetalLB (bare metal) or use k3s’s built-in ServiceLB depending on configuration

#### Example
````bash
kubectl expose deployment my-apache \
--type=LoadBalancer \
--port=80 \
--target-port=80 \
--name=my-apache-lb
````

Then:
```bash
kubectl get svc my-apache-lb
```

You’ll see an `EXTERNAL-IP` field:
* In cloud clusters: a real IP/hostname appears
* In local clusters: may stay <pending> unless you’ve set up a load balancer implementation

---

### 4) ExternalName

#### What it is
* A Service that maps to an external DNS name
* It does not create pods, endpoints, or load balancing
* It essentially creates a DNS alias inside the cluster

#### When to use it
* You want in-cluster apps to refer to an external dependency using a consistent service name
* Example: map payments service name to payments.example.com

#### Example
```yaml
apiVersion: v1
kind: Service
metadata:
name: external-google
spec:
type: ExternalName
externalName: google.com
```

Now a pod can resolve:
```text
external-google.default.svc.cluster.local → google.com
```
---

### Note about additive Services

The Service types build on top of each other, but they are not separate objects — they are different exposure layers applied to the same Service.

Think of them as networking layers:

```text
ClusterIP  → internal virtual IP
NodePort   → exposes that ClusterIP on every node
LoadBalancer → exposes that NodePort externally via a provider LB
```

---

#### What actually happens

When you create:

##### ClusterIP
```text
Pod ↔ ClusterIP
```
* Internal communication only
* kube-proxy routes traffic from the Service IP to Pods

---

##### NodePort
````text
Client → NodeIP:NodePort → ClusterIP → Pod
````

Kubernetes still creates a ClusterIP internally.

NodePort simply opens a port on every node that forwards to that ClusterIP.

So NodePort = ClusterIP + external node port access

---

##### LoadBalancer
```text
Internet → External LB → NodePort → ClusterIP → Pod
```

LoadBalancer builds on NodePort:
* Kubernetes requests an external load balancer (cloud provider or local implementation)
* That load balancer forwards traffic to the NodePort
* The NodePort forwards to the ClusterIP
* The ClusterIP routes to Pods

So LoadBalancer = NodePort + external load balancer

---

#### Important takeaway

You do not manually create three services.

You create one Service and choose its exposure level:

| Type          | Exposure level               |
|---------------|------------------------------|
| ClusterIP     | inside cluster only          |
| NodePort      | reachable via node IP        |
| LoadBalancer  | reachable from the internet  |

---

### Quick decision guide
| You want…                                       | Use           |
|-------------------------------------------------|---------------|
| internal-only networking between pods           | ClusterIP     |
| quick access from outside for learning/testing  | NodePort      |
| a real external IP in cloud environments        | LoadBalancer  |
| DNS alias to an external hostname               | ExternalName  |

---

### Kubernetes Services DNS

Kubernetes provides built-in service discovery using CoreDNS (running inside the cluster).

Instead of connecting to Pod IPs (which change), applications connect to service names.

---

#### Basic behavior

A Service automatically gets a DNS record:
```text
<service-name>
```


Within the same namespace, that’s usually enough:
```bash
curl http://my-apache
```

Kubernetes resolves it to the Service IP.

---

#### Fully Qualified Domain Name (FQDN)

Services also have a full DNS name:
```text
<service-name>.<namespace>.svc.cluster.local
```

Example:
```bash
curl my-apache.default.svc.cluster.local
```

This works from any namespace.

---

#### Namespace scoping (important concept)

DNS resolution is namespace-aware.

From inside namespace `default`:
```text
my-apache → resolves
```

From another namespace:
```text
my-apache → NOT found
my-apache.default → works
my-apache.default.svc.cluster.local → always works
```

---

#### Namespaces

List namespaces:
```bash
kubectl get namespaces
```

Example:
```text
NAME              STATUS   AGE
default           Active   26d
kube-node-lease   Active   26d
kube-public       Active   26d
kube-system       Active   26d
```

##### What they are

Namespaces are logical cluster partitions:
* separate resource names
* separate DNS scopes
* separate access control boundaries

##### Common ones
| Namespace        | Purpose                                                             |
|------------------|---------------------------------------------------------------------|
| default          | where user workloads go unless specified                            |
| kube-system      | Kubernetes internal components (CoreDNS, controller-manager, etc.)  |
| kube-public      | publicly readable cluster info                                      |
| kube-node-lease  | node heartbeat coordination                                         |


So far you've been working in `default`, which is why `my-apache` resolves without specifying a namespace.

---

#### Why namespaces matter for Services

Service names are not globally unique — only unique within a namespace.

You can have:
```text
frontend.default
frontend.staging
frontend.prod
```

Each is a completely different service.
