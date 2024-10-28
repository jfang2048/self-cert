#!/bin/bash

read_input() {
    while true; do
        read -p "Enter the name of the root certificate (e.g., MyCorp_CA): " cert_name
        [[ -n "$cert_name" ]] && break || echo "Certificate name cannot be empty, please try again!"
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
        read -p "Enter the common name (e.g., MyCorp_CA): " common_name
        [[ -n "$common_name" ]] && break || echo "Common name cannot be empty, please try again!"
    done
}

# Construct the DN string
create_dn_string() {
    dn="/C=${country}/ST=${state}/L=${location}/O=${organization}/CN=${common_name}"
    echo "$dn"
}

# Generate the root certificate private key
generate_private_key() {
	
    openssl genrsa -out "${cert_name}.key" 4096
    if [ $? -ne 0 ]; then
        echo "Failed to generate the private key."
        exit 1
    else
        echo "Private key generated: ${cert_name}.key"
    fi
}

# Create the root certificate CSR
generate_csr() {
  local dn=$(create_dn_string)
    openssl req -new -key "${cert_name}.key" -subj "$dn" -out "${cert_name}.csr"
    if [ $? -ne 0 ]; then
        echo "Failed to create the CSR."
        exit 1
    else
        echo "CSR generated: ${cert_name}.csr"
    fi
}

# Self-sign the root certificate
self_sign_certificate() {
    openssl x509 -req -days 730 -in "${cert_name}.csr" -signkey "${cert_name}.key" -out "${cert_name}.crt"
    if [ $? -ne 0 ]; then
        echo "Failed to self-sign the certificate."
        exit 1
    else
        echo "Self-signed certificate generated: ${cert_name}.crt"
    fi
}

# Show the generated files
show_generated_files() {
    echo "Root certificate generated:"
    ls -l "${cert_name}".*
}


main() {
    read_input
    generate_private_key
    generate_csr
    self_sign_certificate
    show_generated_files
}

main
