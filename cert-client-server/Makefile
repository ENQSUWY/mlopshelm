NAMESPACE ?= default
PREFIX ?= test-mlops
DOMAIN ?= $(PREFIX)-storage

COUNTRY := US
STATE := CA
COMPANY := H2O.ai

# credits to: https://gist.github.com/fntlnz/cf14feb5a46b2eda428e000157447309

# usage:
# make rootCA.crt # (rootCA.key implicitly created)
# make DOMAIN=somedomain.dev somedomain.dev.csr somedomain.dev.crt   or   make DOMAIN=somedomain.dev
# make DOMAIN=somedomain.dev verify-csr
# make DOMAIN=somedomain.dev verify-crt

# import rootCA.crt to the client (chrome)
# upload somedomain.dev.crt   and   somedomain.dev.key   to the host

all: $(DOMAIN).client.csr $(DOMAIN).client.crt $(DOMAIN).server.csr $(DOMAIN).server.crt

rootCA.key:
	openssl genrsa -out rootCA.key 4096

# create and self sign root certificate
rootCA.crt: rootCA.key
	echo "$(COUNTRY)\n$(STATE)\n\n$(COMPANY)\n\n$(PREFIX) CA\n\n" | \
 	openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 7300 -reqexts v3_req -extensions v3_ca \
	-config myopenssl.cnf \
	-out $@


$(DOMAIN).client.conf:
	sh mkconf-client.sh $(DOMAIN) $(NAMESPACE) >$@

$(DOMAIN).server.conf:
	sh mkconf-server.sh $(DOMAIN) $(NAMESPACE) >$@

$(DOMAIN).client.key:
	openssl genrsa -out $@ 4096

$(DOMAIN).server.key:
	openssl genrsa -out $@ 4096

$(DOMAIN).client.csr: $(DOMAIN).client.key $(DOMAIN).client.conf
	openssl req -new -sha256 -key $(DOMAIN).client.key -subj "/C=$(COUNTRY)/ST=$(STATE)/O=$(COMPANY)/CN=$(DOMAIN)" \
		-reqexts v3_req -reqexts SAN \
		-config $(DOMAIN).client.conf \
		-out $@

$(DOMAIN).server.csr: $(DOMAIN).server.key $(DOMAIN).server.conf
	openssl req -new -sha256 -key $(DOMAIN).server.key -subj "/C=$(COUNTRY)/ST=$(STATE)/O=$(COMPANY)/CN=$(DOMAIN)" \
		-reqexts v3_req -reqexts SAN \
		-config $(DOMAIN).server.conf \
		-out $@

# verify .csr content
.PHONY: verify-client-csr
verify-client-csr:
	openssl req  -in $(DOMAIN).client.csr -noout -text

.PHONY: verify-server-csr
verify-server-csr:
	openssl req  -in $(DOMAIN).server.csr -noout -text

$(DOMAIN).san.client.conf:
	sh mksan-client.sh $(DOMAIN) $(COUNTRY) $(STATE) "$(COMPANY)" $(NAMESPACE) >$@

$(DOMAIN).client.crt: rootCA.key rootCA.crt $(DOMAIN).client.csr $(DOMAIN).san.client.conf
	openssl x509 -req -in $(DOMAIN).client.csr -CA ./rootCA.crt -CAkey ./rootCA.key \
		-CAcreateserial -out $@ -days 7300 -sha256 \
		-extfile $(DOMAIN).san.client.conf \
		-extensions req_ext

$(DOMAIN).san.server.conf:
	sh mksan-server.sh $(DOMAIN) $(COUNTRY) $(STATE) "$(COMPANY)" $(NAMESPACE) >$@

$(DOMAIN).server.crt: rootCA.key rootCA.crt $(DOMAIN).server.csr $(DOMAIN).san.server.conf
	openssl x509 -req -in $(DOMAIN).server.csr -CA ./rootCA.crt -CAkey ./rootCA.key \
		-CAcreateserial -out $@ -days 7300 -sha256 \
		-extfile $(DOMAIN).san.server.conf \
		-extensions req_ext

# verify the certificate
.PHONY: verify-client-crt
verify-client-crt:
	openssl x509 -in $(DOMAIN).client.crt -text -noout

# verify the certificate
.PHONY: verify-server-crt
verify-server-crt:
	openssl x509 -in $(DOMAIN).server.crt -text -noout

.PHONY: clean
clean:
	-rm -f $(DOMAIN).client.key $(DOMAIN).client.csr $(DOMAIN).client.conf $(DOMAIN).san.client.conf $(DOMAIN).client.crt $(DOMAIN).server.key $(DOMAIN).server.csr $(DOMAIN).server.conf $(DOMAIN).san.server.conf $(DOMAIN).server.crt


build_in_docker:
	(docker build --build-arg HOST_USERNAME=`id -n -u` --build-arg HOST_UID=`id -u` --build-arg HOST_GID=`id -g` -f Dockerfile-build -t cert-build .)
	docker run --init --rm -v `pwd`:`pwd` --workdir `pwd` --entrypoint bash cert-build -c "make rootCA.crt"

build2_in_docker:
	docker run --init --rm -v `pwd`:`pwd` --workdir `pwd` --entrypoint bash cert-build -c "make"
