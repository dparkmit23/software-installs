#!/bin/bash

# Exit on error
set -e

# INITIALIZE APT
sudo apt update
sudo apt -y upgrade

# DB 
if systemctl --all --type=service | grep -q mariadb; then
    echo "MariaDB service is installed."
else
    echo "Installing MariaDB service."
    sudo apt install mariadb-server
    sudo systemctl enable mariadb
    sudo mysql_secure_installation
fi
