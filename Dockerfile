FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN set -x \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
    ca-certificates \
    gnupg \
    tzdata \
    && apt-get install --no-install-recommends -y \
    bear \
    bsdmainutils  \
    build-essential \
    clang \
    clang-format \
    clang-tidy \
    curl \
    gdb \
    git \
    less \
    libssl-dev \
    lldb \
    lsof \
    netcat \
    pkg-config \
    python3-pip \
    unzip \
    vim \
    wget \
    zip \
    && apt-get install --no-install-recommends -y \
    sudo \
    openssh-server \
    rsyslog \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Set timezone
RUN set -x \
    && pip3 --no-cache-dir install \
    cmake \
    cmake-format

# Set timezone
RUN set -x \
    && ln -fs /usr/share/zoneinfo/Asia/Singapore /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata

# Add user
RUN set -x \
    && groupadd --gid 1000 ubuntu \
    && useradd --create-home --uid 1000 --gid 1000 --shell /bin/zsh ubuntu \
    && echo "ubuntu ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

# Prepare sshd
RUN set -x \
    && ssh-keygen -A \
    && echo "" >> /etc/ssh/sshd_config \
    && echo "X11UseLocalhost yes" >> /etc/ssh/sshd_config \
    && mkdir /run/sshd

# Prepare optee prerequisites
RUN set -x \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
    android-tools-adb \
    android-tools-fastboot \
    autoconf \
    automake \
    bc \
    bison \
    build-essential \
    ccache \
    codespell \
    cpio \
    cscope \
    curl \
    device-tree-compiler \
    expect \
    flex \
    ftp-upload \
    gdisk \
    iasl \
    libattr1-dev \
    libcap-dev \
    libcap-ng-dev \
    libfdt-dev \
    libftdi-dev \
    libglib2.0-dev \
    libgmp-dev \
    libhidapi-dev \
    libmpc-dev \
    libncurses5-dev \
    libpixman-1-dev \
    libssl-dev \
    libtool \
    make \
    mtools \
    netcat \
    ninja-build \
    python-crypto \
    python-pyelftools \
    # python-serial \
    python3-crypto \
    python3-pycryptodome \
    python3-pyelftools \
    python3-serial \
    rsync \
    unzip \
    uuid-dev \
    xdg-utils \
    xterm \
    xz-utils \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pip --no-cache-dir install cryptography

# Get REPO
RUN set -x \
    && export REPO=$(mktemp /tmp/repo.XXXXXXXXX) \
    && curl -o ${REPO} https://storage.googleapis.com/git-repo-downloads/repo \
    && gpg --recv-key 8BB9AD793E8E6153AF0F9A4416530D5E920F5C65 \
    && curl -s https://storage.googleapis.com/git-repo-downloads/repo.asc | gpg --verify - ${REPO} \
    && install -m 755 ${REPO} /usr/local/bin/repo

USER root

# Start sshd
CMD set -x \
    && service rsyslog start \
    && /usr/sbin/sshd -D