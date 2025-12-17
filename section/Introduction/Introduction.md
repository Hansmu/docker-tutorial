# Docker Introduction

Docker ≠ containers.
Docker is a tooling platform for creating, running, and managing containers.

Containers existed before Docker, but Docker made them easy and widely usable.

---

## What is Docker?

Docker is a container technology that provides tools and services for:

* building container images
* running containers 
* managing container lifecycles

Docker simplifies working with containers by abstracting away low-level OS features.

---

## What is a container?

A container is a standardized unit of software that packages:
* application code
* all required dependencies (runtime, libraries, system tools)

Example:
> Node.js application code + Node.js runtime bundled together.

Because everything needed to run the application is included, a containerized application behaves consistently across different environments (development, testing, production).

> The same container image aims to produce the same behavior wherever it is executed, assuming compatible host systems.

--- 

## Container support in operating systems

Container technology is based on features built into the Linux kernel, such as:
* namespaces (process isolation)
* cgroups (resource limiting)

On Linux, containers run natively on the host OS.

On macOS and Windows, Docker runs containers inside a lightweight Linux virtual machine, because those operating systems do not provide native Linux container support.

---

## Why containers?

Applications often behave differently across environments due to:
* different OS configurations
* different runtime versions
* missing or incompatible dependencies

Containers solve this by allowing developers to:
* build and test applications in the exact same environment
* run that identical environment in production

Example:

> An application uses a newer Node.js feature that works locally but fails on a server running an older Node version.
Packaging the correct Node version inside a container avoids this problem entirely.

---

## Virtual machines vs containers

### Virtual Machines
* Each virtual machine runs a full guest operating system
* Includes its own OS kernel and system libraries
* Heavier resource usage (CPU, memory, disk)
* Slower startup times

### Containers
* Share the host OS kernel
* Isolate applications using kernel features
* Lightweight and fast to start
* Focus on packaging applications and environments, not entire machines

| Containers                           | Virtual Machines                     |
| ------------------------------------ | ------------------------------------ |
| Share host OS kernel                 | Each VM has its own OS kernel        |
| Lightweight and fast                 | Heavier and slower                   |
| Minimal disk space usage             | Larger disk space usage              |
| Easy to build, share, and distribute | More complex to share and distribute |
| Encapsulate apps and environments    | Encapsulate entire machines          |

--- 

## Docker tools and building blocks
### Docker Engine

The core runtime of Docker.
* A background service (daemon) that builds images and runs containers
* Manages networking, storage, and container lifecycles

On Linux, Docker Engine runs directly on the host OS.

On macOS and Windows, it runs inside a lightweight Linux virtual machine.

---

### Docker Desktop

A desktop application for macOS and Windows that bundles:
* Docker Engine
* Docker CLI
* a lightweight Linux VM
* additional developer tooling (UI, Kubernetes integration)

Docker Desktop simplifies installation and usage on non-Linux systems.

---

### Docker CLI

A command-line interface used to interact with Docker:
* build images
* run containers
* inspect and manage Docker resources

---

### Docker Hub
A cloud-based container registry that allows you to:
* store Docker images
* share images publicly or privately
* pull images created by others

---

### Docker Compose

A tool for defining and running multi-container applications.
* Uses a YAML file to describe services, networks, and volumes 
* Allows multiple containers to be started and managed together

---

## Appendix

### Guest Operating System (Guest OS)
#### Plain explanation

A guest operating system is an operating system that runs inside another system, rather than directly on physical hardware.
* Your real computer OS (e.g. Linux, macOS, Windows) is the host OS
* A guest OS runs on top of the host, usually inside a virtual machine

Think of it like:
> A computer running inside another computer

#### Example
If you run Ubuntu inside VirtualBox on Windows:
* Windows → host OS
* Ubuntu → guest OS

#### Relation to Docker
* Virtual machines have a guest OS
* Containers do NOT have a guest OS
* Containers share the host OS kernel

This is why containers are lightweight.

---

### Kernel
#### Plain explanation

The kernel is the core of an operating system.

It:
* talks directly to the hardware (CPU, memory, disks)
* manages processes
* controls memory and resource usage
* enforces security and isolation

Applications never talk to hardware directly — they talk to the kernel.

#### Analogy

The kernel is like:

> The operating system’s “engine and traffic controller”

#### Relation to Docker
* Containers share the host kernel
* Virtual machines each have their own kernel
* This is the biggest technical difference between containers and VMs

---

### Processes
#### Plain explanation

A process is a running instance of a program.
* A program = a file on disk
* A process = that program currently executing

Examples:
* Running node server.js → one process
* Running it twice → two processes

Your operating system is constantly managing thousands of processes.

#### Relation to Docker
* Containers run processes, not machines
* Each container usually runs one main process
* From the OS’s perspective, container processes are just normal processes

Containers don’t “contain an OS” — they contain isolated processes.

---

### Namespaces
#### Plain explanation

Namespaces are a Linux kernel feature that provide isolation.

They make processes believe:
* they are the only ones running
* they have their own files, network, users, etc.

Each namespace limits what a process can see.

#### Types of isolation

Namespaces can isolate:

* process IDs (PID namespace)
* file system (mount namespace)
* network (network namespace)
* users (user namespace)
* hostnames (UTS namespace)

#### Relation to Docker

Docker uses namespaces so that:

* a container sees only its own processes
* it has its own network stack
* it has its own filesystem view

This is what makes containers feel like separate systems.

---

### cgroups (Control Groups)
#### Plain explanation

cgroups are a Linux kernel feature for resource control.

They limit and monitor how much:
* CPU 
* memory
* disk I/O 
* network bandwidth

a group of processes can use.

#### Analogy

cgroups are like:
> A resource budget for processes

#### Relation to Docker

Docker uses cgroups to:
* prevent a container from using all system memory
* limit CPU usage per container
* keep one container from crashing the whole system

Namespaces = isolation
cgroups = resource limits

---

### Daemon
#### Plain explanation

A daemon is a program that:
* runs in the background
* starts when the system starts
* waits for requests and handles them

It does not have a user interface.

#### Examples
* Web server
* Database server
* Docker Engine

#### Relation to Docker
* Docker Engine (dockerd) is a daemon 
* It runs in the background 
* The Docker CLI sends commands to the daemon 
* The daemon does the actual work (builds images, runs containers)

---

### Putting it all together (Docker mental model)

When you run a Docker container:
1. The Docker CLI sends a request 
2. The Docker daemon receives it 
3. The daemon creates isolated processes 
4. Isolation is enforced using namespaces 
5. Resource limits are enforced using cgroups 
6. All processes run on the host kernel 
7. No guest OS is involved