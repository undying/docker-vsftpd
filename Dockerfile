
FROM ubuntu:14.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
    supervisor \
    vsftpd=3.0.2-1ubuntu2.14.04.1 \
    libpam-pwdfile=1.0-1 \
    db-util=1:5.3.21~exp1ubuntu1 \
    libnss-ldap libpam-ldap \
    nscd \
    vim zsh

COPY etc/ /etc/
COPY usr/ /usr/

RUN mkdir -p /home/ftp /etc/vsftpd && \
    install -m 755 -o root -g root -d /var/run/vsftpd && \
    install -m 755 -o root -g root -d /var/run/vsftpd/empty

EXPOSE 20 21 22

VOLUME [ "/home/ftp/", "/etc/vsftpd/" ]

CMD [ "/usr/local/sbin/init.sh" ]

