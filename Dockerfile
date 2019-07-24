FROM ubuntu:18.04

ENV container docker

# Don't start any optional services except for the few we need.
RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -exec rm \{} \;

# installing required packages
RUN apt-get -qq update && \
    apt-get install -y systemd software-properties-common jq sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN systemctl set-default multi-user.target
RUN systemctl mask dev-hugepages.mount sys-fs-fuse-connections.mount

# Systemd defines that it expects SIGRTMIN+3 for graceful shutdown
# https://www.commandlinux.com/man-page/man1/systemd.1.html#lbAH
STOPSIGNAL SIGRTMIN+3

ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# ugrade repository to install MaaS 2.6
# comment or remove thoses lines if you want the version 2.4 to be installed
RUN apt-get -y upgrade && \
    add-apt-repository -yu ppa:maas/stable

# install MaaS
RUN apt-get install -y maas

# removing sshd
RUN systemctl disable sshd && \
    apt-get remove -y openssh-server

# Exposing ports needed by MAAS
# 53 (DNS)
# 67 (DHCP server)
# 69 (TFTP)
# 123 (NTP)
# 623 (IPMI)
# 4011 (PXE)
# 5240 (MAAS UI)
EXPOSE 53 67 69 123 623 4011 5240

# initialize systemd
# Workaround for docker/docker#27202, technique based on comments from docker/docker#9212
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]

## References
## https://github.com/att-comdev/dockerfiles/blob/master/maas/maas-region-controller/Dockerfile
## https://github.com/att-comdev/dockerfiles/blob/master/maas/maas-rack-controller/Dockerfile
## https://hub.docker.com/r/solita/ubuntu-systemd/dockerfile
