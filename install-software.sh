#!/bin/bash

# Exit on error
set -e

# INITIALIZE APT
sudo apt update
sudo apt -y upgrade

# EFS
cd /home/ubuntu
sudo apt -y install git binutils
git clone https://github.com/aws/efs-utils
cd /home/ubuntu/efs-utils
./build-deb.sh
sudo apt-get -y install ./build/amazon-efs-utils*deb
echo "fs-020ae87de07d938d0:/ /home/ubuntu/efs efs _netdev,tls 0 0" | sudo tee -a /etc/fstab
cd /home/ubuntu
mkdir /home/ubuntu/efs
sudo mount -a

cd /home/ubuntu
rm -rf .ssh
ln -s /home/ubuntu/efs/.ssh /home/ubuntu/.ssh
ls -s /home/ubuntu/efs/.emacs.d /home/ubuntu/.emacs.d

# SOFTWARE
sudo apt -y install emacs
