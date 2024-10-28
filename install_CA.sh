#!/bin/bash

copy_cert() {
    sudo cp "$1" /usr/share/ca-certificates/
}

update_certs() {
    sudo update-ca-certificates
}

check_cert() {
    tail -1 /etc/ca-certificates.conf | grep -q "$1"
}

configure_trust() {
    sudo dpkg-reconfigure ca-certificates
}

add_cert_manually() {
    sudo bash -c "cp /etc/ca-certificates.conf /etc/ca-certificates.conf.backup && echo \"$1\" >> /etc/ca-certificates.conf"
}

main() {
    local cert_path="MyCorp_CA.crt"
    copy_cert "$cert_path"
    update_certs

    if check_cert "$cert_path"; then
        echo "add successfully"
    elif check_cert "!$cert_path"; then
        configure_trust
    else
        add_cert_manually "$cert_path"
        update_certs
    fi
}

main
