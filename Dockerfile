FROM solita/ubuntu-systemd:18.04

ENV container docker

ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -qq update && \
    apt-get -y upgrade && \
    apt-get -y install sudo

#install rsyslog
RUN apt-get install -y rsyslog
RUN systemctl enable rsyslog.service

#update repository to install MaaS 2.5
#comment or remove thoses lines if you want the version 2.4 to be installed
RUN apt-get install -y software-properties-common && \
    add-apt-repository -yu ppa:maas/stable && \
    apt-get -qq update && \
    apt-get -y upgrade

#install MaaS
RUN systemctl enable rsyslog.service && \
    service rsyslog restart && \
    apt-get install -y maas && \
    maas createadmin --username=admin --password=admin --email=daniel.neto@rnp.br
