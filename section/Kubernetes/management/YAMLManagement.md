# Managing Kubernetes Declaratively with YAML
## What “Declarative” Really Means

Declarative management means:

> You describe what the cluster should look like, not how to change it.

You don’t tell Kubernetes:
- “Scale this” 
- “Delete that pod” 
- “Restart this container”

You describe:
- “There should be 3 replicas” 
- “The image should be nginx:1.27” 
- “This service should expose port 80”

Kubernetes then reconciles reality to match your description.

---

## The Core Command

Declarative management revolves around one command:

```bash
kubectl apply -f <file-or-directory>
```

That’s it.

You run the same command repeatedly.

Kubernetes:
- Creates objects if they don’t exist 
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

Let’s define a simple Deployment.

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

## Applying the YAML

Save it as:
```bash
deployment.yaml
```

Apply it:

```bash
kubectl apply -f deployment.yaml
```

Check:

```bash
kubectl get deploy
kubectl get pods
```

---

## Updating Declaratively

Now change:
```bash
replicas: 3
```

to:

```bash
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

You can define multiple resources in one file:

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

Notice that there are dashes (`---`) being used to separate the resources.

Or use a directory:
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

Important:

Deletion is still explicit.

Kubernetes will not delete something just because it disappeared from your file (unless using GitOps controllers).

---

## Inspecting Differences Before Applying

You can preview changes:

```bash
kubectl diff -f deployment.yaml
```

This shows what will change before applying.

Very useful in production.

---

## Declarative vs Imperative Difference (Very Important)

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

Imperative changes the live object.

Declarative changes the desired state source of truth.

---

## Source of Truth Principle

In declarative workflows:

> The YAML files in Git are the source of truth.

The cluster is a reflection of Git.

If someone edits the cluster manually (`kubectl edit`), that change should be reverted by reapplying YAML.

---

## Field Ownership and apply

`kubectl apply` tracks which fields it manages.

This prevents overwriting fields owned by other managers.

You can see managed fields:

```bash
kubectl get deploy my-nginx -o yaml
```

Look for:

```yaml
managedFields:
```

This is part of Kubernetes’ server-side apply mechanism.

---

## Recommended Production Pattern
1. Store YAML in Git
2. Review changes via Pull Request
3. Apply via CI/CD
4. Never manually edit production objects
5. Use kubectl apply consistently

This prevents configuration drift.

---

## Common Beginner Mistakes

### Editing live objects with `kubectl edit`

You create divergence from your YAML.

---

### Mixing imperative and declarative

Example:
- Scale manually
- YAML still says 3 replicas
- Next apply reverts scaling

---

### Forgetting labels/selectors consistency

Deployment selector must match pod template labels.

---

## Mental Model

Declarative Kubernetes is not:

> “Run this command to do something.”

It is:

> “Make the system look like this.”

Kubernetes is a continuous reconciliation engine.

---

## Minimal Declarative Workflow
1. Write YAML
2. `kubectl apply -f`
3. `kubectl get`
4. Adjust YAML
5. Apply again

Repeat forever.