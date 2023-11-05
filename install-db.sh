#!/bin/bash

# Exit on error
set -e

db_dir="/home/ubuntu/efs/mysql"
efs_id="fs-08489c99cb1a0c33a"
efs_entry="$efs_id:/ /home/ubuntu/efs efs _netdev,tls 0 0" 

# INITIALIZE APT
sudo apt update
sudo apt -y upgrade

# EFS
cd /home/ubuntu
if grep -Fxq "$efs_entry" /etc/fstab; then
    echo "Skipped creating link to EFS because it already exists."
else
    echo "Creating EFS link now."
    sudo apt -y install git binutils
    git clone https://github.com/aws/efs-utils
    cd /home/ubuntu/efs-utils
    ./build-deb.sh
    sudo apt-get -y install ./build/amazon-efs-utils*deb
    echo "$efs_id:/ /home/ubuntu/efs efs _netdev,tls 0 0" | sudo tee -a /etc/fstab
    cd /home/ubuntu
    mkdir /home/ubuntu/efs
    sudo mount -a
fi

# DB 
if systemctl --all --type=service | grep -q mariadb; then
    echo "MariaDB service is installed."
else
    echo "Installing MariaDB service."
    sudo apt install mariadb-server
    sudo systemctl stop mariadb

    sudo cp -R /var/lib/mysql /home/ubuntu/efs/mysql
    sudo mv /var/lib/mysql /var/lib/mysql.bak
    sudo ln -s /home/ubuntu/efs/mysql /var/lib/mysql
    sudo chown -R mysql:mysql /home/ubuntu/efs/mysql

    sudo systemctl start mariadb
    sudo systemctl status mariadb

    sudo mysql_secure_installation
fi
