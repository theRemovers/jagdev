ifeq ($(SUDO), 1)
DOCKER=sudo docker
else
DOCKER=docker
endif

VERSION?=latest
IMGNAME?=jagdev-$(VERSION)

USERNAME=$(shell id -un)
USERID=$(shell id -u)
GROUPNAME=$(shell id -gn)
GROUPID=$(shell id -g)

GITNAME=$(shell git config user.name)
GITEMAIL=$(shell git config user.email)

BUILDARGS=
BUILDARGS+=--build-arg USERNAME=$(USERNAME)
BUILDARGS+=--build-arg USERID=$(USERID)
BUILDARGS+=--build-arg GROUPNAME=$(GROUPNAME)
BUILDARGS+=--build-arg GROUPID=$(GROUPID)
BUILDARGS+=--build-arg VERSION=$(VERSION)

ENV=

VOLUMES=
VOLUMES+=-v $(PWD)/src:/home/$(USERNAME)/src:Z
ifeq ($(shell if test -e $(HOME)/.emacs; then echo "true"; else echo "false"; fi),true)
VOLUMES+=-v $(HOME)/.emacs:/home/$(USERNAME)/.emacs:Z
endif
ifneq ($(DISPLAY),)
VOLUMES+=-v /tmp/.X11-unix:/tmp/.X11-unix:Z
ENV+=-e DISPLAY=$(DISPLAY)
endif
ifneq ($(SSH_AUTH_SOCK),)
VOLUMES+=-v $(SSH_AUTH_SOCK):/ssh-agent:Z
ENV+=-e SSH_AUTH_SOCK=/ssh-agent
BUILDARGS+=--ssh default
endif

HOSTS=
#HOSTS+=--add-host xx:yy

.PHONY: help build run

all: help

run: build
	xhost +local: || true
	$(DOCKER) run --rm --privileged -t -i $(VOLUMES) $(ENV) $(HOSTS) $(IMGNAME) /bin/bash
	xhost -local: || true

build: Dockerfile
	DOCKER_BUILDKIT=1 $(DOCKER) build -t $(IMGNAME) $(BUILDARGS) .

help:
	@echo "Provide an archlinux development environment using Docker"
	@echo
	@echo "To build docker image:"
	@echo "  'make build'"
	@echo
	@echo "To run docker container:"
	@echo "  'make run'"
	@echo
	@echo "If you need to be root to run docker, then add SUDO=1 in front of the above commands"
	@echo "  e.g. 'SUDO=1 make run'"
	@echo
	@echo "The user is sudoer in the docker container. "
	@echo "The password is set to be equal to 'archlinux'"
