# Managing Kubernetes Declaratively with YAML

## What "Declarative" Really Means

Declarative management means:

> You describe what the cluster should look like, not how to change it.

You don't tell Kubernetes:
- "Scale this"
- "Delete that pod"
- "Restart this container"

You describe:
- "There should be 3 replicas"
- "The image should be nginx:1.27"
- "This service should expose port 80"

Kubernetes then reconciles reality to match your description.

---

## The Core Command

Declarative management revolves around one command:

```bash
kubectl apply -f <file-or-directory-or-url>
```

That's it.

You run the same command repeatedly.

Kubernetes:
- Creates objects if they don't exist
- Updates them if they differ
- Leaves them alone if nothing changed

This is called idempotency.

---

## Why YAML?

Kubernetes objects are defined as structured API objects.

YAML is simply a human-readable representation of those API objects.

Every Kubernetes resource has:
```yaml
apiVersion:
kind:
metadata:
spec:
```

---

## Anatomy of a Declarative YAML File

Let's define a simple Deployment.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: my-nginx
    labels:
      app: my-nginx
spec:
    replicas: 3
    selector:
        matchLabels:
          app: my-nginx
    template:
        metadata:
            labels:
              app: my-nginx
        spec:
            containers:
                - name: nginx
                  image: nginx:1.27
                  ports:
                    - containerPort: 80
```

---

## Understanding the Structure

### apiVersion

Defines which API group and version this resource belongs to.

Note that `apiVersion` is not unique per resource kind — it reflects the *API group and version*, and multiple kinds can share the same value. For example, `Deployment`, `ReplicaSet`, `StatefulSet`, and `DaemonSet` are all `apps/v1`. Think of it as telling Kubernetes which API endpoint to route the request to; `kind` then specifies the resource type within that group.

### kind

Defines what type of resource it is (Deployment, Service, Pod, etc.)

### metadata

Identity information:
- name
- namespace
- labels
- annotations

### spec

The desired state.

This is what Kubernetes tries to enforce.

---

## Building the Structure

First thing to know: there are a ton of different resources you can use.

Based on different distributions, you can get additional resources.

You can run:
```bash
kubectl api-resources
```

To get all available resources.

```text
NAME                                SHORTNAMES   APIVERSION                          NAMESPACED   KIND
bindings                                         v1                                  true         Binding
componentstatuses                   cs           v1                                  false        ComponentStatus
configmaps                          cm           v1                                  true         ConfigMap
endpoints                           ep           v1                                  true         Endpoints
events                              ev           v1                                  true         Event
limitranges                         limits       v1                                  true         LimitRange
namespaces                          ns           v1                                  false        Namespace
nodes                               no           v1                                  false        Node
persistentvolumeclaims              pvc          v1                                  true         PersistentVolumeClaim
persistentvolumes                   pv           v1                                  false        PersistentVolume
pods                                po           v1                                  true         Pod
podtemplates                                     v1                                  true         PodTemplate
replicationcontrollers              rc           v1                                  true         ReplicationController
resourcequotas                      quota        v1                                  true         ResourceQuota
secrets                                          v1                                  true         Secret
serviceaccounts                     sa           v1                                  true         ServiceAccount
services                            svc          v1                                  true         Service
...
daemonsets                          ds           apps/v1                             true         DaemonSet
deployments                         deploy       apps/v1                             true         Deployment
replicasets                         rs           apps/v1                             true         ReplicaSet
statefulsets                        sts          apps/v1                             true         StatefulSet
...
```

The two columns that matter when defining your YAML are `KIND` and `APIVERSION`.

For example with Deployment:

| NAME            | SHORTNAMES | APIVERSION  | NAMESPACED | KIND           |
|-----------------|------------|-------------|------------|----------------|
| **deployments** | deploy     | **apps/v1** | true       | **Deployment** |
| replicasets     | rs         | apps/v1     | true       | ReplicaSet     |

Now let's say we've decided on a Deployment. It has a whole list of options it can be created with.

To see all available keys, run:
```bash
# kubectl explain <resourceName> --recursive
kubectl explain deployments --recursive
```

Note: use the plural resource name (e.g. `deployments`, not `Deployment`). The shortname also works (`kubectl explain deploy`), but the plural form is canonical.

There is an overwhelming amount of properties. It's mainly useful for finding the exact name of a property when you already know what you want.

<details>

<summary>Output of running explain recursive</summary>

```text
FIELDS:
  apiVersion	<string>
  kind	<string>
  metadata	<ObjectMeta>
    annotations	<map[string]string>
    creationTimestamp	<string>
    deletionGracePeriodSeconds	<integer>
    deletionTimestamp	<string>
    finalizers	<[]string>
    generateName	<string>
    generation	<integer>
    labels	<map[string]string>
    managedFields	<[]ManagedFieldsEntry>
      apiVersion	<string>
      fieldsType	<string>
      fieldsV1	<FieldsV1>
      manager	<string>
      operation	<string>
      subresource	<string>
      time	<string>
    name	<string>
    namespace	<string>
    ownerReferences	<[]OwnerReference>
      apiVersion	<string> -required-
      blockOwnerDeletion	<boolean>
      controller	<boolean>
      kind	<string> -required-
      name	<string> -required-
      uid	<string> -required-
    resourceVersion	<string>
    selfLink	<string>
    uid	<string>
  spec	<DeploymentSpec>
    minReadySeconds	<integer>
    paused	<boolean>
    progressDeadlineSeconds	<integer>
    replicas	<integer>
    revisionHistoryLimit	<integer>
    selector	<LabelSelector> -required-
      matchExpressions	<[]LabelSelectorRequirement>
        key	<string> -required-
        operator	<string> -required-
        values	<[]string>
      matchLabels	<map[string]string>
    strategy	<DeploymentStrategy>
      rollingUpdate	<RollingUpdateDeployment>
        maxSurge	<IntOrString>
        maxUnavailable	<IntOrString>
      type	<string>
      enum: Recreate, RollingUpdate
    template	<PodTemplateSpec> -required-
      metadata	<ObjectMeta>
        ...
      spec	<PodSpec>
        containers	<[]Container> -required-
          ...
```
</details>

If you want to know what a field actually does, drill into it:

```bash
kubectl explain deployments.spec
```

This produces something far more manageable:

```text
GROUP:      apps
KIND:       Deployment
VERSION:    v1

FIELD: spec <DeploymentSpec>

DESCRIPTION:
    Specification of the desired behavior of the Deployment.
    
FIELDS:
  minReadySeconds	<integer>
    Minimum number of seconds for which a newly created pod should be ready
    without any of its container crashing, for it to be considered available.
    Defaults to 0 (pod will be considered available as soon as it is ready)

  replicas	<integer>
    Number of desired pods. Defaults to 1.

  selector	<LabelSelector> -required-
    Label selector for pods. It must match the pod template's labels.

  strategy	<DeploymentStrategy>
    The deployment strategy to use to replace existing pods with new ones.

  template	<PodTemplateSpec> -required-
    Template describes the pods that will be created.
```

You can continue drilling down:

```bash
kubectl explain deployments.spec.strategy
```

```text
FIELDS:
  rollingUpdate	<RollingUpdateDeployment>
    Rolling update config params. Present only if DeploymentStrategyType = RollingUpdate.

  type	<string>
  enum: Recreate, RollingUpdate
    Type of deployment. Default is RollingUpdate.
    
    - "Recreate": Kill all existing pods before creating new ones.
    - "RollingUpdate": Gradually scale down the old ReplicaSets and scale up the new one.
```

All of this is also available in the official docs:
https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/

### apiVersion

Refers to the versions shown when listing all resources. When you see multiple versions for the same resource (e.g. `v1` vs `v1beta1`), prefer the most stable one — GA (`v1`) > beta (`v1beta1`) > alpha (`v1alpha1`). The `kubectl api-resources` output shows the current preferred version. You can also run `kubectl api-versions` to list all versions available in your cluster.

### kind

Referring to the above table, we'd want `Deployment`.

### metadata

Add what you need to identify it.

### spec

This means looking into the docs a bit deeper, because it often differs between resources.

---

## Dry Runs and Diffs

Two separate tools are useful here: `--dry-run` and `kubectl diff`.

**Dry run** — validates that your manifest is accepted by the API server without actually applying it:

```bash
# Client-side (basic validation only)
kubectl apply -f deployments-example.yml --dry-run=client

# Server-side (more accurate — runs through admission controllers)
kubectl apply -f deployments-example.yml --dry-run=server
```

**Diff** — shows exactly what would change if you applied the file. This is the better tool for checking what Kubernetes will actually do:

```bash
kubectl diff -f deployments-example.yml
```

When nothing has been created yet, the diff shows everything as an addition:

```text
--- /tmp/LIVE-3817713164/apps.v1.Deployment.default.my-nginx
+++ /tmp/MERGED-2552125940/apps.v1.Deployment.default.my-nginx
@@ -0,0 +1,43 @@
+apiVersion: apps/v1
+kind: Deployment
+metadata:
+  creationTimestamp: "2026-02-27T07:03:10Z"
+  generation: 1
+  labels:
+    app: my-nginx
+  name: my-nginx
+  namespace: default
...
```

If the deployment already exists and you change a label, the diff only shows the delta:

```text
--- /tmp/LIVE-1475523243/apps.v1.Deployment.default.my-nginx
+++ /tmp/MERGED-1603368948/apps.v1.Deployment.default.my-nginx
@@ -8,7 +8,7 @@
   labels:
-    app: my-nginx
+    app: other-nginx
```

---

## Labels and Label Selectors

Labels go under `metadata` in the YAML.

Simple list of `key: value` pairs for identifying your resource later.

Common example:
```yaml
tier: frontend
app: api
env: prod
customer: acme.co
```

You can filter with them, even scoping an apply to only matching resources:
```bash
kubectl apply -f myfile.yaml -l app=nginx
```

But filtering isn't the only use case. Labels are also the glue between resources — they tell Services and Deployments which pods belong to them. Many resources use label selectors to "link" their dependencies.

You can also use labels and selectors to control which pods get scheduled onto which nodes.

Labels aren't meant to hold complex, large, or non-identifying info. That's what **annotations** are for.

Annotations are arbitrary key-value metadata attached to a resource. Unlike labels, they can't be used for selection. They're commonly read by external tools and controllers (like ingress controllers, Helm, Prometheus, cert-manager, etc.) to drive behaviour — but core Kubernetes components don't act on them the way they do with label selectors.

In short: **labels are for identification and selection; annotations are for attaching metadata that tools can act on.**

---

## Applying the YAML

Apply it:
```bash
kubectl apply -f deployments-example.yml
```

Check:
```bash
kubectl get deploy
kubectl get pods
```

---

## Updating Declaratively

Now change:
```yaml
replicas: 3
```

to:

```yaml
replicas: 5
```

Reapply:
```bash
kubectl apply -f deployment.yaml
```

You did not run `kubectl scale`.

You changed the desired state.

Kubernetes notices the difference and reconciles.

---

## Managing Multiple Resources

You can define multiple resources in one file, separated by `---`:

```yaml
---
apiVersion: apps/v1
kind: Deployment
...

---
apiVersion: v1
kind: Service
...
```

Or apply an entire directory:
```bash
kubectl apply -f ./manifests/
```

This is very common in real projects.

---

## Deleting Declaratively

To remove resources defined in a file:
```bash
kubectl delete -f deployment.yaml
```

Important: deletion is still explicit.

Kubernetes will not delete something just because it disappeared from your file (unless you're using a GitOps controller like Argo CD or Flux).

---

## Inspecting Differences Before Applying

```bash
kubectl diff -f deployment.yaml
```

This shows what will change before you apply. Very useful in production.

---

## Declarative vs Imperative (Very Important)

Imperative:
```bash
kubectl scale deployment my-nginx --replicas=5
```

Declarative:
```yaml
replicas: 5
```
```bash
kubectl apply -f deployment.yaml
```

Imperative changes the live object directly.

Declarative changes the desired state — your source of truth.

---

## Source of Truth Principle

In declarative workflows:

> The YAML files in Git are the source of truth.

The cluster is a reflection of Git.

If someone edits the cluster manually (`kubectl edit`), that change will be overwritten the next time the YAML is applied.

---

## Field Ownership and apply

`kubectl apply` tracks which fields it manages, which prevents overwriting fields owned by other managers (e.g. autoscalers, controllers).

You can inspect this:

```bash
kubectl get deploy my-nginx -o yaml
```

Look for:

```yaml
managedFields:
```

**A note on client-side vs server-side apply:** Historically, `kubectl apply` used *client-side* apply, which tracked managed fields by storing the last applied config in an annotation (`kubectl.kubernetes.io/last-applied-configuration`). A newer mechanism called *server-side apply* (SSA) moves this tracking to the server and is more robust for multi-manager scenarios. The `managedFields` block in the object is populated by SSA. You can opt into it with:

```bash
kubectl apply -f deployment.yaml --server-side
```

---

## Recommended Production Pattern

1. Store YAML in Git
2. Review changes via Pull Request
3. Apply via CI/CD
4. Never manually edit production objects
5. Use `kubectl apply` consistently

This prevents configuration drift.

---

## Common Beginner Mistakes

### Editing live objects with `kubectl edit`

You create divergence from your YAML. Next apply will overwrite your changes.

---

### Mixing imperative and declarative

Example:
- Scale manually with `kubectl scale`
- YAML still says 3 replicas
- Next `kubectl apply` reverts back to 3

---

### Forgetting labels/selectors consistency

The Deployment's `selector` must match the pod template labels. If they don't match, Kubernetes will reject the manifest.

---

## Mental Model

Declarative Kubernetes is not:

> "Run this command to do something."

It is:

> "Make the system look like this."

Kubernetes is a continuous reconciliation engine.

---

## Minimal Declarative Workflow

1. Write YAML
2. `kubectl apply -f`
3. `kubectl get`
4. Adjust YAML
5. Apply again

Repeat forever.