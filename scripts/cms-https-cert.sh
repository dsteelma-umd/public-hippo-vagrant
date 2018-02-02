#!/bin/bash

CACHED_SSL_CONF=/apps/dist/ssl

if [ -e "$CACHED_SSL_CONF" ]; then
    echo "Using HTTPS SSL configuration cached in dist/ssl"
    cp -rp /apps/dist/ssl /apps
else
    # SSL Certificate (self-signed)
    sudo mkdir -p /apps/ssl/{key,csr,cert,cnf}

    KEY=/apps/ssl/key/cmslocal.key
    CSR=/apps/ssl/csr/cmslocal.csr
    CRT=/apps/ssl/cert/cmslocal.crt
    CNF=/apps/ssl/cnf/cmslocal.cnf

    cat > "$CNF" <<END
[ req ]
prompt                  = no
distinguished_name      = cmslocal_dn
req_extensions = v3_req
[ cmslocal_dn ]
commonName              = cmslocal
stateOrProvinceName     = MD
countryName             = US
organizationName        = UMD
organizationalUnitName  = Libraries
[ v3_req ]
subjectAltName = @alt_names
[alt_names]
DNS.1 = cmslocal
DNS.2 = localhost
IP.1 = 192.168.40.10
IP.2 = 127.0.0.1
END

    # Generate private key 
    sudo openssl genrsa -out "$KEY" 2048

    # Generate CSR 
    sudo openssl req -new -key "$KEY" -out "$CSR" -config "$CNF"

    # Generate self-signed cert
    sudo openssl x509 -req -days 365 -in "$CSR" -signkey "$KEY" -out "$CRT" \
        -extensions v3_req -extfile "$CNF"

    # cache the SSL cert info for the next run of Vagrant
    sudo mkdir -p "$CACHED_SSL_CONF"
    sudo cp -rp /apps/ssl /apps/dist
fi