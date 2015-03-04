
NAME=$(shell basename `pwd`)
RUN=docker run --name $(NAME) -d --env=LDAP_URI=ldaps://ldap.ostrovok.ru --env=LDAP_BINDDN=cn=ProxyUser,ou=ServiceAccounts,dc=ostrovok,dc=ru --env=LDAP_BINDPW=123456 --env=LDAP_BASE=dc=ostrovok,dc=ru --env=LDAP_TLS_CACERTFILE=/etc/ldap/ssl/CA.crt -P $(NAME)

.PHONY: build run stop clean

build: clean
	docker build -t $(NAME) .

run:
	$(eval ID := $(shell $(RUN)))
	docker logs -ft $(ID)

stop:
	docker stop $(NAME) || true

clean: stop
	docker rm $(NAME) || true

all: clean build run

