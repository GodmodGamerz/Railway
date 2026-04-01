FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    sudo \
    dos2unix \
    net-tools \
    iputils-ping \
    unzip \
    zip \
    tmux \
    python3 \
    python3-pip \
    nodejs \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd

RUN useradd -m -s /bin/bash vps && \
    echo "vps ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY start.sh /start.sh

# Fix line endings and permissions
RUN dos2unix /start.sh && chmod +x /start.sh

EXPOSE 22

CMD ["/bin/bash", "/start.sh"]
