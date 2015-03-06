#! /bin/bash

set -x

LDAP_CONF=${LDAP_CONF:-/etc/ldap.conf}
LDAP_CONF_TMP=${LDAP_CONF_TMP:-/tmp/ldap.conf}
LDAP_TLS_CACERTFILE=${LDAP_TLS_CACERTFILE:-/etc/ldap/ssl/CA.crt}

VSFTPD_CONF=${VSFTPD_CONF:-/etc/vsftpd.conf}

### creating some directories
install -m 755 -o root -g root -d /ftp
install -m 700 -o root -g root -d /etc/vsftpd
install -m 755 -o root -g root -d /var/run/vsftpd
install -m 755 -o root -g root -d /var/run/vsftpd/empty
install -m 744 -o root -g root -d /var/run/nscd

### dynamic ldap.conf configuration
for o in $(env|grep LDAP_);do
  option=$(echo ${o}|awk -F '=' '{ print $1 }'|sed -e 's:LDAP_::'|tr 'A-Z' 'a-z')
  value=$(echo ${o}|sed -e 's:LDAP_[^=]\+=\(.*\):\1:')

  echo -e "${option}\t${value}" >> ${LDAP_CONF_TMP}
done
[ -f "/tmp/ldap.conf" ] && mv -b ${LDAP_CONF_TMP} ${LDAP_CONF}

### dynamic vsftpd.conf configuration
for o in $(env|grep VSFTPD_);do
  option=$(echo ${o}|awk -F '=' '{ print $1 }'|sed -e 's:VSFTPD_::'|tr 'A-Z' 'a-z')
  value=$(echo ${o}|sed -e 's:VSFTPD_[^=]\+=\(.*\):\1:')

  if grep "^${option}" ${VSFTPD_CONF} > /dev/null;then
    sed -i "s:^${option}=.*:${option}=${value}:" ${VSFTPD_CONF}
  else
    echo -e "${option}=${value}" >> ${VSFTPD_CONF}
  fi
done

### and starting supervisord with all configured daemons
exec /usr/bin/supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf

