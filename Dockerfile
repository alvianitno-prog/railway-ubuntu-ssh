FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install OpenSSH Server dan utilitas sistem untuk membaca statistik info sistem
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    wget \
    sudo \
    net-tools \
    iproute2 \
    procps \
    bc \
    lsb-release \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/sshd

# Konfigurasi SSH Daemon agarizinkan Root Login & Password Auth
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config \
    && sed -i 's/#PrintMotd yes/PrintMotd yes/' /etc/ssh/sshd_config

# Buka Port 22
EXPOSE 22

# Copy script entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
