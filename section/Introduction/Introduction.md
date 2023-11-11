# Docker introduction

Docker != containers. Docker is a **tool** for creating and managing containers.

## What is Docker?
Docker is a container technology: A tool for creating and managing container.

Then the next question is - what is a container? A container is a standardized unit of software.
A package of code and dependencies to run that code. E.g. NodeJS code + the NodeJS runtime.

So you have the runtime and the code packaged together. This is a container.
The same container always yields the exact some application and execution behavior.
Regardless of where or by whom it may be executed.

Support for Containers is built into modern operating systems.

Docker simplifies the creation and management of such containers.

## Why containers?
We often have different development & production environments.
These differences can cause an application to work differently. Or not at all.

We want to build and test in **exactly** the same environment as we later run our app in.

For example, we have an older version of Node on a server than we do locally. 
What can happen here is that we use a feature that is not supported on the server, but works locally.

## Virtual machines vs containers
Each virtual machine has its own operating system.
It is a complete copy of an operating system.
It's like a machine running on top of our machine.
The OS is not shared between the virtual machines.
This wastes a lot of space and tends to be slow.
Also, whereas the virtual machine is shareable, it is not that easy.

Containers are a lot more lightweight. They share more information.

| Containers                                                | Virtual machines                                               |
|-----------------------------------------------------------|----------------------------------------------------------------|
| Low impact on OS, very fast, minimal disk space usage     | Bigger impact on OS, slower, higher disk space usage           |
| Sharing, re-building and distribution is easy             | Sharing, re-building and distribution can be challenging       |
| Encapsulate apps/environments instead of "whole machines" | Encapsulate "whole machines" instead of just apps/environments |

## Docker tools & building blocks

Docker consist of a few tools and building blocks.
* Docker Engine - The core of Docker. The server that runs on the host machine.
The Docker engine is a virtual machine that runs on the host machine. 
It's only needed because the OS does not support Docker natively.
* Docker Desktop - It includes a daemon and a CLI. 
The daemon is a process which keeps on running and ensures that Docker works.
It is basically the heart of Docker. The CLI is a tool for interacting with the daemon.
* Docker Hub - A registry of Docker images. A place to store and share Docker images.
* Docker Compose - A tool for defining and running multi-container Docker applications.