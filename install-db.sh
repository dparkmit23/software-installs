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
    # Install MariaDB
    echo "Installing MariaDB service."
    sudo apt install mariadb-server
    sudo systemctl enable mariadb

    # Log into MariaDB as the root user
    sudo mysql --defaults-extra-file=/etc/mysql/debian.cnf -e "
        # Change the root password
        SET PASSWORD FOR 'root'@'localhost' = PASSWORD('ZACEciU2fU');

        # Remove root accounts that are accessible from outside the localhost
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

        # Remove anonymous-user accounts
        DELETE FROM mysql.user WHERE User='';

        # Remove the test database
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

        # Create a new user for localhost
        CREATE USER 'alphatrade'@'localhost' IDENTIFIED BY 'HtHCQ8bJKFEwUfw';

        # Create a new user for any host
        CREATE USER 'alphatrade'@'%' IDENTIFIED BY 'HtHCQ8bJKFEwUfw';

        # Grant the users all privileges on all databases
        GRANT ALL PRIVILEGES ON *.* TO 'alphatrade'@'localhost';
        GRANT ALL PRIVILEGES ON *.* TO 'alphatrade'@'%';

        # Create a database called alphatrade
        CREATE DATABASE alphatrade;

        # Reload all the privileges
        FLUSH PRIVILEGES;
    "

    # Modify the MariaDB configuration file
    sudo sed -i 's|^#datadir\s*=.*|datadir = /db/mysql|' /etc/mysql/mariadb.conf.d/50-server.cnf
    sudo sed -i 's/^#max_connections\s*= 100/max_connections = 600/' /etc/mysql/mariadb.conf.d/50-server.cnf
    sudo sed -i 's/^bind-address\s*= 127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

    # Restart the MariaDB
    sudo systemctl restart mariadb

    # Stop MariaDB
    sudo systemctl stop mariadb

    # Create the /db directory
    sudo mkdir -p /db

    # Add the line to /etc/fstab
    echo "UUID=26e0ffbb-3a06-46d8-968a-2ca9b2aba341  /db  xfs  defaults,nofail  0  2" | sudo tee -a /etc/fstab

    # Mount all filesystems mentioned in fstab
    sudo mount -a

    # Get the current date
    date=$(date +%Y-%m-%d)

    # Initialize the counter
    counter=0

    # Generate the backup directory name
    backup_dir="/db/mysql.bak.$date.$counter"

    # Increment the counter until we find a backup directory that doesn't exist
    while [ -d "$backup_dir" ]; do
        counter=$((counter+1))
        backup_dir="/db/mysql.bak.$date.$counter"
    done

    # Check if the mysql directory exists
    if [ -d "/db/mysql" ]; then

        # Move the directory
        sudo mv /db/mysql "$backup_dir"
        echo "Moved /db/mysql to $backup_dir"
    else
        echo "Didn't move /db/mysql because it was not found."
    fi

    # Move /var/lib/mysql to /db/mysql
    sudo mv /var/lib/mysql /db/mysql

    # Start MariaDB
    sudo systemctl start mariadb

fi
