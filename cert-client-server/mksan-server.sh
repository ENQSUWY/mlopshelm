#!/bin/sh

cat <<EOF
[req]
default_bits       = 4096
distinguished_name = req_distinguished_name
req_extensions     = req_ext
x509_extensions    = usr_cert
[req_distinguished_name]
countryName                = $2
stateOrProvinceName        = $3
organizationName           = $4
commonName                 = $1
[req_ext]
keyUsage = critical,digitalSignature,keyEncipherment
extendedKeyUsage = serverAuth
basicConstraints = critical,CA:FALSE
authorityKeyIdentifier=keyid,issuer
subjectAltName = @alt_names
[alt_names]
DNS.1   = localhost
DNS.2   = $1
DNS.3   = $1.$5
IP.1    = 127.0.0.1
EOF
