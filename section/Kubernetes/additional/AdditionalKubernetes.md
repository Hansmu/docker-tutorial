# Additional Kubernetes Things

This section covers some other things that are worth knowing in Kubernetes.

Kubernetes is ever evolving, so you can't really go over everything — it'd be an endless effort. So this section has some nice-to-knows.

---

## Storage

Kubernetes has a few layers of storage abstraction worth understanding.

### Volumes

The simplest form of storage is a **Volume**, defined directly in a pod's spec. A volume's lifecycle is tied to the pod — when the pod dies, the volume goes with it. All containers within the same pod can mount and share the same volume, which is useful for things like sharing config files or logs between a sidecar and a main container.

```yaml
spec:
  containers:
    - name: app
      volumeMounts:
        - name: shared-data
          mountPath: /data
  volumes:
    - name: shared-data
      emptyDir: {}
```

`emptyDir` is the simplest type — it starts empty and lives as long as the pod does. Good for scratch space or inter-container communication.

### PersistentVolumes and PersistentVolumeClaims

When you need storage that outlives a pod, you use a **PersistentVolume (PV)** and a **PersistentVolumeClaim (PVC)**.

- A **PersistentVolume** is a piece of storage provisioned at the cluster level by an admin (or dynamically by a StorageClass). It has no ties to any specific pod.
- A **PersistentVolumeClaim** is a request for storage made by a workload. Kubernetes matches the claim to an appropriate PV.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

You then reference the PVC in your pod spec:

```yaml
volumes:
  - name: my-storage
    persistentVolumeClaim:
      claimName: my-pvc
```

Multiple pods can share a PV depending on the access mode (`ReadWriteMany` allows this; `ReadWriteOnce` restricts it to a single node).

### StorageClasses and Dynamic Provisioning

Manually pre-provisioning PVs doesn't scale. **StorageClasses** allow dynamic provisioning — when a PVC is created, Kubernetes automatically provisions a matching PV using the storage backend defined in the class (e.g. AWS EBS, GCP Persistent Disk, NFS).

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
```

### CSI (Container Storage Interface)

CSI plugins are the modern, standard way to connect Kubernetes to external storage systems. They replaced the older in-tree volume plugins (like `awsElasticBlockStore`, `gcePersistentDisk`), which are now deprecated and being removed. If you're using cloud storage today, you should be using the CSI driver for that provider rather than the old in-tree types.

### StatefulSets

**StatefulSets** are designed for workloads that require stable, persistent identity — things like databases, message queues, and clustered systems.

Unlike a Deployment where pods are interchangeable, a StatefulSet gives each pod a stable, ordered name (e.g. `postgres-0`, `postgres-1`, `postgres-2`) and a dedicated PersistentVolumeClaim that follows the pod even if it's rescheduled. The pods are also started and stopped in order, which matters for distributed systems that have leader/follower relationships.

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:16
          volumeMounts:
            - name: data
              mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 10Gi
```

That `volumeClaimTemplates` section is the key difference — each replica gets its own PVC automatically.

### Running Databases on Kubernetes

It's worth flagging: running a stateful database on Kubernetes is complex. You're taking on responsibility for backups, failover, replication, and upgrades — things that managed cloud database services (RDS, Cloud SQL, PlanetScale, etc.) handle for you.

The general advice is: **unless you have a strong reason to self-host, use a managed DB**. That said, the ecosystem has matured significantly. Operators like the CloudNativePG operator for Postgres or the Percona Operator for MySQL make it far more viable than it used to be.

---

## Ingress

A **Service** exposes your pods inside the cluster (or via a raw LoadBalancer). An **Ingress** sits in front of your services and handles HTTP/HTTPS routing from outside the cluster — routing `/api` to one service and `/` to another, handling TLS termination, etc.

Ingress requires an **Ingress Controller** to be installed — it doesn't work out of the box. Popular choices:

- **Nginx Ingress Controller** — the most widely used, battle-tested, highly configurable
- **Traefik** — auto-discovers services via labels/annotations, has a nice built-in dashboard, handles Let's Encrypt automatically. Worth considering especially in smaller or more dynamic setups.
- **HAProxy, Contour, Envoy-based options** — also worth knowing exist

Example Ingress:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 80
```

Note: The **Gateway API** (`gateway.networking.k8s.io`) is the newer, more expressive successor to Ingress — it's now GA and worth learning as it's increasingly the preferred approach in modern clusters.

---

## CRDs and the Operator Pattern

Kubernetes is designed to be extended. **CustomResourceDefinitions (CRDs)** let you define entirely new resource types in the Kubernetes API, as if they were built-in.

For example, after installing the Prometheus Operator, you can write:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app-monitor
spec:
  selector:
    matchLabels:
      app: my-app
  endpoints:
    - port: metrics
```

Kubernetes doesn't know what a `ServiceMonitor` is natively — the CRD teaches it. The Prometheus Operator's controller then watches for these resources and configures Prometheus accordingly.

This is the **Operator Pattern**: a CRD paired with a custom controller that encodes operational knowledge about a specific piece of software. Good operators handle provisioning, scaling, backups, upgrades, and failover automatically. The [OperatorHub](https://operatorhub.io/) has a large catalogue of operators for databases, monitoring tools, message queues, and more.

CRDs also extend `kubectl` — you can `kubectl get servicemonitors` just like any built-in resource.

---

## Higher Deployment Abstractions

Writing raw YAML for every resource gets repetitive fast. Several tools exist to manage this.

### Helm

Helm is the most widely adopted package manager for Kubernetes. It uses **charts** — templated collections of Kubernetes manifests with configurable values.

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-redis bitnami/redis --set auth.password=secret
```

The same chart can deploy to dev, staging, and prod with different `values.yaml` files. Helm also handles upgrades and rollbacks:

```bash
helm upgrade my-redis bitnami/redis --set replicaCount=3
helm rollback my-redis 1
```

Helm is practically ubiquitous — most popular software has an official or community chart on [ArtifactHub](https://artifacthub.io/).

### Kustomize

Kustomize is built directly into `kubectl` (via `kubectl apply -k`) and takes a different approach. Instead of templating, it uses **overlays** — you have a base set of manifests and then patch them per environment without modifying the originals.

```
base/
  deployment.yaml
  service.yaml
  kustomization.yaml
overlays/
  production/
    kustomization.yaml   # patches replicas, image tag, resource limits
  staging/
    kustomization.yaml
```

Kustomize avoids the complexity of Helm's templating language and keeps your YAML valid at every stage. It's a good fit when you have relatively straightforward config differences between environments.

### Helm vs Kustomize

They're often used together — Helm to install third-party software, Kustomize to manage your own app configs. Neither is strictly better; it depends on the use case.

### Kompose

If you're coming from Docker Compose and want to migrate to Kubernetes, **Kompose** can convert your `docker-compose.yml` into Kubernetes manifests automatically:

```bash
kompose convert -f docker-compose.yml
```

It generates Deployments, Services, and PVCs from your Compose definitions. The output isn't always production-ready, but it's a solid starting point and saves a lot of manual work. Kompose is an official Kubernetes project and is actively maintained.

### CNAB

**Cloud Native Application Bundle (CNAB)** is an open spec for packaging and deploying distributed applications that span multiple runtimes (Kubernetes, cloud services, Helm charts, etc.) in a single, portable bundle. It's co-authored by Microsoft, Docker, and others.

In practice, CNAB has seen limited adoption — most teams reach for Helm or Kustomize instead. It's worth knowing the term exists, but it's unlikely to be something you'll use day-to-day.

---

## Kubernetes Dashboard

The official **Kubernetes Dashboard** has been **archived and is no longer maintained**. The project repository was moved to `kubernetes-retired/dashboard`. The Kubernetes docs now officially recommend **Headlamp** as the replacement.

**Headlamp** (`https://headlamp.dev`) is an extensible, plugin-based Kubernetes UI that is now a CNCF Sandbox project. It's actively developed and is the current recommended option for a general-purpose cluster UI.

That said, many production teams don't use a general dashboard at all — they use purpose-built observability tools like Lens, k9s (terminal UI), Grafana, or their cloud provider's console instead.

**A strong security note:** any web UI that has access to your Kubernetes API should be treated with care. Make sure RBAC is properly configured, don't expose the dashboard publicly, and prefer access via `kubectl port-forward` rather than a public LoadBalancer or Ingress.

---

## Namespaces and Context

### Namespaces

Namespaces are virtual clusters within a physical cluster. They provide a scope for names — two teams can both have a `Deployment` named `api` as long as they're in different namespaces.

Common uses:
- Separating environments (`dev`, `staging`, `prod`) on the same cluster
- Separating teams or applications
- Applying resource quotas and RBAC policies per team

```bash
kubectl get pods -n my-namespace
kubectl apply -f deployment.yaml -n my-namespace
```

Some resources are **namespace-scoped** (Pods, Deployments, Services, ConfigMaps), while others are **cluster-scoped** (Nodes, PersistentVolumes, ClusterRoles) — you can see which is which in the `NAMESPACED` column of `kubectl api-resources`.

Namespaces are not a strong security boundary — they're primarily an organisational and access control tool. For true isolation between untrusted workloads, you'd need separate clusters or additional tools.

### Context

A **context** in kubeconfig ties together a cluster, a user, and a namespace. Switching context changes which cluster and namespace `kubectl` commands are sent to.

```bash
# See all contexts
kubectl config get-contexts

# Switch context
kubectl config use-context my-prod-cluster

# See current context
kubectl config current-context
```

You can also set a default namespace on a context so you don't have to type `-n my-namespace` constantly:

```bash
kubectl config set-context --current --namespace=my-namespace
```

**kubectx** and **kubens** are popular third-party tools that make switching contexts and namespaces faster and less error-prone than the raw kubectl commands.