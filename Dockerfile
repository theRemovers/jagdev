# syntax=docker/dockerfile:experimental
# Apropos
ARG VERSION=latest
FROM archlinux:${VERSION}

RUN \
  pacman -Syu --noconfirm \
    bash \
    bash-completion \
    curl \
    diffutils \
    dkms \
    emacs \
    fakeroot \
    gcc \
    git \
    linux-headers \
    make \
    nano \
    ocaml \
    openssh \
    rsync \
    sudo \
    unzip \
    wget \
    zip

RUN \
    sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g'  /etc/sudoers

ARG USERNAME
ARG USERID
ARG GROUPNAME
ARG GROUPID

RUN \
  groupadd --gid ${GROUPID} ${GROUPNAME} || \
  groupmod --gid ${GROUPID} ${GROUPNAME}

RUN \
  useradd \
    --create-home \
    --gid ${GROUPID} \
    --uid ${USERID} \
    --shell /bin/bash \
    --groups wheel \
    --password "$(openssl passwd -1 archlinux)" \
    ${USERNAME}

WORKDIR /home/${USERNAME}

USER ${USERNAME}

RUN \
  git clone https://aur.archlinux.org/ia32_aout-dkms.git && \
  cd ia32_aout-dkms && \
  makepkg -f

USER root

RUN \
  pacman -U --noconfirm ia32_aout-dkms/ia32_aout-dkms*.tar.xz

USER ${USERNAME}

RUN \
  git clone https://aur.archlinux.org/m68k-atari-mint-binutils.git && \
  cd m68k-atari-mint-binutils && \
  makepkg -f

USER root

RUN \
  pacman -U --noconfirm m68k-atari-mint-binutils/m68k-atari-mint-binutils*.tar.xz

USER ${USERNAME}

RUN \
  git clone https://aur.archlinux.org/m68k-atari-mint-gcc.git && \
  cd m68k-atari-mint-gcc && \
  makepkg -f

USER root

RUN \
  pacman -U --noconfirm m68k-atari-mint-gcc/m68k-atari-mint-gcc*.tar.xz

COPY binfmt.conf /etc/modprobe.d/binfmt.conf
COPY 90-local.rules /etc/udev/rules.d/90-local.rules
COPY 98-buspirate.rules /etc/udev/rules.d/98-buspirate.rules

RUN \
  gpasswd -a ${USERNAME} uucp

USER ${USERNAME}

RUN mkdir -p -m 0700 .ssh && \
  ssh-keyscan github.com > .ssh/known_hosts

