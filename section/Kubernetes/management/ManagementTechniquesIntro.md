# Management Techniques Intro

When you run `kubectl` commands, you are not directly “controlling containers”.

You are creating or modifying Kubernetes API objects.

Kubernetes then works in the background to make reality match those objects.

---

## What kubectl actually does

Many `kubectl` commands are shortcuts.

They use built-in generators (templates) to construct a Kubernetes resource specification (`spec`) based on command-line flags.

Example:
```bash
kubectl create deployment my-nginx --image=nginx
```

This does NOT immediately start containers.

Instead it:
1. Builds a Deployment YAML spec
2. Sends it to the API server
3. Stores it in etcd
4. Controllers reconcile the cluster to match the spec

So:
> kubectl = API client
>
> Kubernetes = reconciliation engine

---

## Viewing the generated configuration

Kubernetes has many defaults.

To see what Kubernetes would create:
```bash
kubectl create deployment my-nginx --image=nginx --dry-run=client -o yaml
```

This prints the full YAML without creating anything.

You can then save it and modify it:
```bash
kubectl create deployment my-nginx --image=nginx --dry-run=client -o yaml > deployment.yaml
```

This is a common way to bootstrap configuration files.

---

## Every resource has a spec

All Kubernetes objects follow the same pattern:
```text
metadata → identity
spec → desired state
status → current state
```

Kubernetes constantly works to make:
```text
status == spec
```

This process is called reconciliation.

---

## Imperative vs Declarative

Before management approaches, understand these two programming mindsets.

---

### Imperative

Focus: How to do something

Step-by-step instructions.

#### Coffee example
* Boil water
* Grind beans
* Pour water
* Wait 3 minutes

You control each step.

---

### Declarative

Focus: What the final result should be

You describe the goal, not the steps.

#### Coffee example

> “Barista, one coffee please.”

You don’t manage the process — someone else ensures the result.

---

### Kubernetes Interpretation

#### Imperative Kubernetes

You manually tell the cluster what action to perform next.

Examples:
```bash
kubectl run
kubectl scale
kubectl expose
kubectl delete
kubectl edit
```

You know the current state and push it to the next state.

---

#### Declarative Kubernetes

You declare the desired state and Kubernetes figures out how to achieve it.

Example:
```bash
kubectl apply -f resources.yaml
```

You don't care about current state — only final state.

You run the same command repeatedly.

---

## The Three Management Approaches

Kubernetes supports three styles of managing objects.

They are often confused — especially the difference between the last two.

---

### 1) Imperative Command Management

You directly run commands that modify live objects.

#### Examples:
```bash
kubectl run nginx
kubectl expose deployment nginx
kubectl scale deployment nginx --replicas=3
kubectl edit deployment nginx
```

#### Characteristics
* Fastest to learn 
* Good for experiments and debugging 
* Hard to reproduce 
* No reliable history 
* Easy to drift from intended configuration

#### Typical usage

Learning, testing, personal clusters.

---

### 2) Imperative Object Management

You use YAML files, but commands decide the action.

#### Examples:
```bash
kubectl create -f file.yaml
kubectl replace -f file.yaml
kubectl delete -f file.yaml
```

Here you still control the operation explicitly.

You are saying:

> “Perform THIS action with THIS file”

##### Characteristics
* YAML stored in Git
* Predictable single operations
* Still manual decision making
* Automation is difficult

#### Typical usage

Small production setups or scripted deployments.

---

### 3) Declarative Object Management

You declare the desired state and continuously reapply it.

#### Example:
```bash
kubectl apply -f directory/
```

Kubernetes calculates differences and reconciles automatically.

You are saying:

> “Make the cluster look like this.”

#### Characteristics
* Same command every time
* Idempotent (safe to repeat)
* Easy automation (CI/CD, GitOps)
* Enables self-healing workflows
* Requires understanding of reconciliation

#### Typical usage

Real production environments

---

### Important difference (very common confusion)
| Approach             | Who decides the action  |
|----------------------|-------------------------|
| Imperative commands  | You                     |
| Imperative objects   | You                     |
| Declarative objects  | Kubernetes              |

---

### Important Rule

Do not mix management styles for the same resources.

Mixing causes configuration drift and unexpected behavior.

Choose one model per project.

---

### Recommended progression

| Stage           | Recommended approach  |
|-----------------|-----------------------|
| Learning        | Imperative commands   |
| Small projects  | Imperative objects    |
| Production      | Declarative objects   |

---

### Best Practice

Always store YAML in Git.

Why:
* audit history
* rollback capability
* reproducibility
* automation compatibility
* team collaboration

This is the foundation of GitOps workflows.

---

### Key takeaway

Kubernetes is not a container runner.

It is a desired state engine.

You are not telling it what to do next.

You are telling it what reality should look like.





























The kubectl commands that you use from the command line have automation behind them.

They use helper templates called generators.

They create a spec to apply to Kubernetes based on your command line options.

Every resource in Kubernetes has a specification or "spec".

Kubernetes has a ton of defaults that it sets behind the scenes.

You can use `--dry-run=client` to see what would happen if a command were run.

If you output it as YAML with `-o yaml` then you could use that as your starting point for writing a config. 

Kubernetes itself is unopinionated in how you should manage it.

There are basically three different ways to do it.

## Background terms

Before going into the three ways, let's look at defining a couple of terms.

### Imperative

Focus on how a program operates.

Accomplish one step after another.

### Declarative

Focus on what a program should accomplish.

We don't care how it gets there, just that it gets there.

### Example

Let's say that you want a cup of coffee.

Imperative would mean:
* Boil water
* Scoop out 42 grams of medium-fine grounds
* Pour over 700 grams of water
* Etc

Declarative would mean:
* Barista, I'd like a cup of coffee.

### Kubernetes Imperative

Examples: `kubectl run`, `kubectl create deployment`, `kubectl update`

Imperative is easier when you know the state.

Imperative is easier to get started.

Not easy to automate.

### Kubernetes Declarative

Example: `kubectl apply -f my-resources.yaml`

Don't know the current state.

Only know what we want the end result to be.

Same command each time.

Can all be in one file or many files (apply a whole directory).

## Three Management Approaches

As mentioned previously, there are three management approaches.

### Imperative Management

This means running CLI commands.

You know the state of the system and you run commands to bring it to the next state.

Imperative commands: `run`, `expose`, `scale` ,`edit`, `create deployment`.

It's best for learning and personal projects.

Easy to learn, but hardest to manage over time.

### Imperative Objects

This means combining YAML files with commands.

Commands: `create -f file.yml`, `replace -f file.yml`, `delete...`

Good for prod of small environments, single file per command.

Store your changes in git-based YAML files.

Hard to automate.

Since you're running the command, you're fully aware of what will happen - either create, replace, or delete.

### Declarative Objects

This is the fully YAML approach.

It's best for prod, easier to automate.

Harder to understand and predict changes.

### Important rule

Don't mix the three approaches.
Choose one that you'll be using for your project.

When you're running Kubernetes in production, then try to stick with the Declarative model as early as possible.

Always keep the YAML in Git for easier management.