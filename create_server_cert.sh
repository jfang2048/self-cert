#!/bin/bash

# Read user input and validate
read_input() {
    while true; do
        read -p "Enter the name of the server certificate (e.g., mytest.mycrop.mymain): " server_cert_name
        [[ -n "$server_cert_name" ]] && break || echo "Server certificate name cannot be empty, please try again!"
    done

    while true; do
        read -p "Enter the country code (e.g., CN): " country
        [[ -n "$country" ]] && break || echo "Country code cannot be empty, please try again!"
    done

    while true; do
        read -p "Enter the state or province (e.g., Shanghai): " state
        [[ -n "$state" ]] && break || echo "State or province cannot be empty, please try again!"
    done

    while true; do
        read -p "Enter the city or location (e.g., Shanghai): " location
        [[ -n "$location" ]] && break || echo "City or location cannot be empty, please try again!"
    done

    while true; do
        read -p "Enter the organization name (e.g., MyCorp): " organization
        [[ -n "$organization" ]] && break || echo "Organization name cannot be empty, please try again!"
    done

    while true; do
        read -p "Enter the common name, recommend server_cert_name and common_name be the same (e.g., mytest.mycrop.mymain): " common_name
        [[ -n "$common_name" ]] && break || echo "Common name cannot be empty, please try again!"
    done

    while true; do
        read -p "Enter the IP address (e.g., 192.168.9.52): " ip_address
        [[ -n "$ip_address" ]] && break || echo "IP address cannot be empty, please try again!"
    done

    while true; do
        read -p "Enter the DNS name (e.g., mytest.mycrop.mymain): " dns_name
        [[ -n "$dns_name" ]] && break || echo "DNS name cannot be empty, please try again!"
    done

    while true; do
        read -p "Enter the name of the CA certificate (e.g., MyCorp_CA): " ca_cert_name
        [[ -n "$ca_cert_name" ]] && break || echo "CA certificate name cannot be empty, please try again!"
    done
}

# Create .ext configuration file
create_ext_file() {
    local ext_file="${server_cert_name}.ext"
    cat > "$ext_file" <<EOF
[ req ]
default_bits        = 4096
distinguished_name  = req_distinguished_name
req_extensions      = req_ext

[ req_distinguished_name ]
C  = $country
ST = $state
L  = $location
O  = $organization

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
IP.1 = $ip_address
DNS.1 = $dns_name

[ v3_ca ]
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment

[ SAN ]
subjectAltName = @alt_names
EOF
}

# Generate private key
generate_private_key() {
    openssl genrsa -out "${server_cert_name}.key" 4096
    if [ $? -ne 0 ]; then
        echo "Failed to generate the private key."
        exit 1
    else
        echo "Private key generated: ${server_cert_name}.key"
    fi
}

# Generate CSR
generate_csr() {
    local dn="/C=${country}/ST=${state}/L=${location}/O=${organization}/CN=${common_name}"
    openssl req -new -key "${server_cert_name}.key" -subj "$dn" -sha256 -out "${server_cert_name}.csr"
    if [ $? -ne 0 ]; then
        echo "Failed to create the CSR."
        exit 1
    else
        echo "CSR generated: ${server_cert_name}.csr"
    fi
}

# Sign the server certificate using the CA
sign_certificate() {
    local ca_cert="${ca_cert_name}.crt"
    local ca_key="${ca_cert_name}.key"

    if [ ! -f "$ca_cert" ] || [ ! -f "$ca_key" ]; then
        echo "Error: CA certificate or private key file not found ($ca_cert or $ca_key)"
        exit 1
    fi

    openssl x509 -req -days 730 -in "${server_cert_name}.csr" -CA "$ca_cert" -CAkey "$ca_key" -CAcreateserial -sha256 -out "${server_cert_name}.crt" -extfile "${server_cert_name}.ext" -extensions SAN
    if [ $? -ne 0 ]; then
        echo "Failed to sign the server certificate."
        exit 1
    else
        echo "Server certificate signed: ${server_cert_name}.crt"
    fi
}

# Verify that the certificate and private key match
verify_cert_and_key() {
    local cert_modulus=$(openssl x509 -noout -modulus -in "${server_cert_name}.crt" | openssl md5)
    local key_modulus=$(openssl rsa -noout -modulus -in "${server_cert_name}.key" | openssl md5)

    if [ "$cert_modulus" == "$key_modulus" ]; then
        echo "The certificate and private key match successfully!"
        echo "MD5(Certificate) = $cert_modulus"
        echo "MD5(Private Key) = $key_modulus"
    else
        echo "Error: The certificate and private key do not match!"
        echo "MD5(Certificate) = $cert_modulus"
        echo "MD5(Private Key) = $key_modulus"
        exit 1
    fi
}

# Main function
main() {
    read_input
    create_ext_file
    generate_private_key
    generate_csr
    sign_certificate
    verify_cert_and_key
}

# Execute the main function
main
