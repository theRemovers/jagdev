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
    doxygen \
    dkms \
    emacs \
    fakeroot \
    gcc \
    git \
    libusb-compat \
    linux-headers \
    make \
    nano \
    ocaml \
    openssh \
    python3 \
    python-numpy \
    python-pillow \
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

COPY binfmt.conf /etc/modprobe.d/binfmt.conf
COPY 90-local.rules /etc/udev/rules.d/90-local.rules
COPY 98-buspirate.rules /etc/udev/rules.d/98-buspirate.rules

RUN gpasswd -a ${USERNAME} uucp

WORKDIR /home/${USERNAME}

USER ${USERNAME}

RUN mkdir pkg

WORKDIR /home/${USERNAME}/pkg

RUN \
  git clone https://aur.archlinux.org/ia32_aout-dkms.git && \
  cd ia32_aout-dkms && \
  makepkg -f

USER root

RUN \
  pacman -U --noconfirm ia32_aout-dkms/ia32_aout-dkms*.tar.zst

USER ${USERNAME}

RUN \
  git clone https://aur.archlinux.org/m68k-atari-mint-binutils.git && \
  cd m68k-atari-mint-binutils && \
  makepkg -f

USER root

RUN \
  pacman -U --noconfirm m68k-atari-mint-binutils/m68k-atari-mint-binutils*.tar.zst

USER ${USERNAME}

RUN \
  git clone https://aur.archlinux.org/m68k-atari-mint-gcc.git && \
  cd m68k-atari-mint-gcc && \
  makepkg -f

USER root

RUN \
  pacman -U --noconfirm m68k-atari-mint-gcc/m68k-atari-mint-gcc*.tar.zst

WORKDIR /home/${USERNAME}

USER ${USERNAME}
RUN mkdir -p bin
COPY mac bin/mac
USER root
RUN chown root:${GROUPNAME} bin/mac && chmod u+s bin/mac
USER ${USERNAME}

RUN mkdir -p -m 0700 .ssh && \
  ssh-keyscan github.com > .ssh/known_hosts

COPY .bash.alias .
USER root
RUN chown ${USERNAME}:${GROUPNAME} .bash.alias
USER ${USERNAME}

RUN echo "if [ -f ${HOME}/.bash.alias ]; then . ${HOME}/.bash.alias; fi" >> .bashrc

RUN echo "export JAGPATH=${HOME}" >> .bashrc

RUN \
  git clone https://github.com/theRemovers/jlinker.git && \
  cd jlinker && \
  make && \
  ln -s /home/${USERNAME}/jlinker/jlinker.native /home/${USERNAME}/bin/aln

RUN \
  git clone https://github.com/theRemovers/skunk_jcp && \
  cd skunk_jcp/jcp && \
  make && \
  ln -s /home/${USERNAME}/skunk_jcp/jcp/jcp /home/${USERNAME}/bin/jcp

RUN \
  git clone https://github.com/theRemovers/jconverter && \
  ln -s /home/${USERNAME}/jconverter/converter.py /home/${USERNAME}/bin/converter

RUN \
  mkdir -p lib

RUN \
  git clone https://github.com/theRemovers/jlibc && \
  git clone https://github.com/theRemovers/rmvlib

COPY setup.sh setup.sh
USER root
RUN chown ${USERNAME}:${GROUPNAME} setup.sh
USER ${USERNAME}
RUN echo "./setup.sh" >> .bashrc
