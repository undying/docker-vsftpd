
Vsftpd Docker Container
-----------------------

vsftpd: https://security.appspot.com/vsftpd.html

docker: https://www.docker.com/


If you need an secure FTP server that supports multiple auth types such as htpasswd, BerkeleyDB or LDAP, you can use this repository to build container for your needs.

Usage:
------

### build container

```docker build -t vsftpd .```

### now run it with options you need

###### start with ldap support and pass option "guest_enable=YES" to /etc/vsftpd.conf

```
docker run -d \
  --env=LDAP_URI=ldaps://ldap.company.org \
  --env=VSFTPD_GUEST_ENABLE=YES \
  -p 10100:10100 \
  -p 10101:10101 \
  vsftpd
```

Auth Types:
----------

### htpasswd

With this method you need a file with login:password information. This file should be mounted into /etc/vsftpd/passwd.

You can create this file using htpasswd tool (from apache2 package) or there is an tool inside current image named crypt. The tool usage is:

```crypt /etc/vsftpd/passwd <username> <password>```

About file format you cad read here: https://en.wikipedia.org/wiki/.htpasswd

### BerkeleyDB

Here you have to generate berkeley db and place this db file here: /etc/vsftpd/userdb.

It can be generated from simple file with such format:

user1
password1
user2
password2

After creating such file you can generate db file:

```db_load -T -t hash -f logins.txt /etc/vsftpd/users.db```

### LDAP

The most difficult part.

When using this method, you need already configured LDAP server and authorization information for LDAP search queries.

To configure /etc/ldap.conf, you can mount already configured file to the container, or pass all neaded variables to docker before start:

```
docker run -d --env=LDAP_URI=ldaps://ldap.company.org vsftpd
```

Usually, you need this minimum for LDAP to work:

###### LDAP configuration:
```
uri ldaps://ldap.company.org 
binddn cn=SearchUser,ou=ServiceAccounts,dc=company,dc=org 
bindpw 123456
base dc=company,dc=org 
tls_cacertfile /etc/ldap/ssl/CA.crt # you need a certificate if you are using ldaps://
```

you can pass all of this settings as environment to docker run:

```
docker run -d \
  --env=LDAP_URI=ldaps://ldap.ostrovok.ru \
  --env=LDAP_BINDDN=cn=ProxyUser,ou=ServiceAccounts,dc=ostrovok,dc=ru \
  --env=LDAP_BINDPW=123456 \
  --env=LDAP_BASE=dc=ostrovok,dc=ru \
  --env=LDAP_TLS_CACERTFILE=/etc/ldap/ssl/CA.crt \
  vsftpd
```

###### Vsftpd configuration:

```
# for all non anonymous logins to work
local_enable=YES
guest_enable=YES
```

and off course you can send this options as environment varialbes:

```
docker run -d \
  --env=VSFTPD_LOCAL_ENABLE=YES \
  --env=VSFTPD_GUEST_ENABLE=YES \
  vsftpd
```

### Hints:

You can configure any /etc/ldap.conf or /etc/vsftpd.conf parameter with environment variables. All you need is

to give a needed prefix to parameter you want to set (VSFTPD_ for /etc/vsftpd.conf and LDAP_ for /etc/ldap.conf:

```
--env=VSFTPD_LOCAL_ROOT=YES
```

will become:

```
local_root=yes
```

in /etc/vsftpd.conf

In this way

```
--env=LDAP_URI=ldaps://ldap.company.org
```

will be transformed to:

```
uri ldaps://ldap.company.org
```

in /etc/ldap.conf

### Troubleshooting:

###### problem with connectivity

FTP server inside docker container must be used in passive mode with hardcoded ports:

/etc/vsftpd.conf

```
pasv_enable=Yes
pasv_min_port=10100
pasv_max_port=10101
```

Then you have to run docker image and publish ports that set in /etc/vsftpd.conf:

```
docker run -d \
  -p 10100:10100 \
  -p 10101:10101 \
  vsftpd
```

###### 530 when using BerkeleyDB

Be sure to place db file with users clearly to the /etc/vsftpd/users.db


