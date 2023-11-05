#!/bin/bash

# Exit on error
set -e

db_dir="/home/ubuntu/efs/db"

# INITIALIZE APT
sudo apt update
sudo apt -y upgrade

# EFS
cd /home/ubuntu
if [ ! -d "$db_dir" ]; then
    sudo apt -y install git binutils
    git clone https://github.com/aws/efs-utils
    cd /home/ubuntu/efs-utils
    ./build-deb.sh
    sudo apt-get -y install ./build/amazon-efs-utils*deb
    echo "fs-08489c99cb1a0c33a:/ /home/ubuntu/efs efs _netdev,tls 0 0" | sudo tee -a /etc/fstab
    cd /home/ubuntu
    mkdir /home/ubuntu/efs
    sudo mount -a
    mkdir -p $db_dir
else
    echo "Skipped creating link to EFS because it already exists."
fi

# DB 
if systemctl --all --type=service | grep -q mariadb; then
    echo "MariaDB service is installed."
else
    echo "Installing MariaDB service."
    sudo apt install mariadb-server
    sudo systemctl stop mariadb

    sudo rsync -av /var/lib/mysql $db_dir

    sudo mv /var/lib/mysql /var/lib/mysql.bak

    echo "[mysqld]" | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf
    echo "datadir = $db_dir" | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf

    sudo chown -R mysql:mysql $db_dir

    sudo systemctl start mariadb
    sudo systemctl status mariadb

    sudo mysql_secure_installation
fi
