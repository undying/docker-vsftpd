#! /bin/bash

set -x

LDAP_CONF=${LDAP_CONF:-/etc/ldap.conf}
LDAP_CONF_TMP=${LDAP_CONF_TMP:-/tmp/ldap.conf}

LDAP_URI=${LDAP_URI:-}
LDAP_BASE=${LDAP_BASE:-}
LDAP_BINDDN=${LDAP_BINDDN:-}
LDAP_BINDPW=${LDAP_BINDPW:-}
LDAP_TLS_CACERTFILE=${LDAP_TLS_CACERTFILE:-/etc/ldap/ssl/CA.crt}

LDAP_OPTIONS=${LDAP_CONF_OPTIONS:-}

### minimal configuration of ldap.conf
[ -n "${LDAP_URI}" ] && echo -e "uri\t${LDAP_URI}" > ${LDAP_CONF} || true
[ -n "${LDAP_BASE}" ] && echo -e "base\t${LDAP_BASE}" >> ${LDAP_CONF} || true
[ -n "${LDAP_BINDDN}" ] && echo -e "binddn\t${LDAP_BINDDN}" >> ${LDAP_CONF} || true
[ -n "${LDAP_BINDPW}" ] && echo -e "bindpw\t${LDAP_BINDPW}" >> ${LDAP_CONF} || true
[ -n "${LDAP_TLS_CACERTFILE}" -a -f "${LDAP_TLS_CACERTFILE}" ] && echo -e "tls_cacertfile\t${LDAP_TLS_CACERTFILE}" >> ${LDAP_CONF} || true

### creating some directories
mkdir -p /var/run/nscd

for o in $(env|grep LDAP_);do
  option=$(echo ${o}|awk -F '=' '{ print $1 }'|sed -e 's:LDAP_::'|tr 'A-Z' 'a-z')
  value=$(echo ${o}|sed -e 's:LDAP_[^=]\+=\(.*\):\1:')
  echo "${option}\t${value}" >> ${LDAP_CONF_TMP}
done
[ -f "/tmp/ldap.conf" ] && mv -b ${LDAP_CONF_TMP} ${LDAP_CONF}

### and starting supervisord with all configured daemons
exec /usr/bin/supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf

