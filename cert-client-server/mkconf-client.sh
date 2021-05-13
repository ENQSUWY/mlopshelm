#!/bin/sh

cat <<EOF
$(cat /etc/ssl/openssl.cnf)
[SAN]
subjectAltName=DNS:localhost,DNS:$1,DNS:$1.$2,IP:127.0.0.1
basicConstraints = critical,CA:FALSE
keyUsage = critical,digitalSignature,keyEncipherment
extendedKeyUsage = clientAuth
EOF
