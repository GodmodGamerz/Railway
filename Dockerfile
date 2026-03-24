FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install SSH server and essential tools
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    sudo \
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
    
    # Create SSH run directory
RUN mkdir /var/run/sshd

# Create a non-root user 'vps' with sudo access
RUN useradd -m -s /bin/bash vps && \
    echo "vps ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# Configure SSH:
# - Allow password authentication
# - Allow root login (optional, uses 'vps' user instead)
# - Keep alive settings
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config && \
    echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config && \
    echo "ClientAliveCountMax 10" >> /etc/ssh/sshd_config
# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Railway uses dynamic ports via $PORT env var
# SSH will run on $PORT (default 22 locally)
EXPOSE 22

CMD ["/start.sh"]
