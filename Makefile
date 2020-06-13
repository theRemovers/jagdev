ifeq ($(SUDO), 1)
DOCKER=sudo docker
else
DOCKER=docker
endif

VERSION?=latest
NAME?=jagdev-$(VERSION)

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

VOLUMES=
VOLUMES+=-v $(HOME)/.emacs:/home/$(USERNAME)/.emacs:Z
VOLUMES+=-v /tmp/.X11-unix:/tmp/.X11-unix:Z

HOSTS=
#HOSTS+=--add-host xx:yy

.PHONY: help build run

all: help

run: build
	xhost +local:
	$(DOCKER) run --rm -t -i -v $(SSH_AUTH_SOCK):/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent -e DISPLAY=$(DISPLAY) $(VOLUMES) $(HOSTS) $(NAME) /bin/bash
	xhost -local:

build: Dockerfile
	DOCKER_BUILDKIT=1 $(DOCKER) build -t $(NAME) $(BUILDARGS) --ssh default .

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