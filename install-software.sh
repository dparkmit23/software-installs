#!/bin/bash

# Exit on error
set -e

# INITIALIZE APT
sudo apt update
sudo apt -y upgrade


# SOFTWARE
cd /home/ubuntu
sudo apt -y install emacs gcc make python3-pip


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
rm -rf /home/ubuntu/.ssh
ln -s /home/ubuntu/efs/.ssh /home/ubuntu/.ssh
ln -s /home/ubuntu/efs/.emacs.d /home/ubuntu/.emacs.d


# TA LIB
cd /home/ubuntu
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar -xvf ta-lib-0.4.0-src.tar.gz --no-same-owner
rm ta-lib-0.4.0-src.tar.gz
cd ta-lib/

sudo ./configure
sudo make
sudo make install


# TPQOA
cd /home/ubuntu
git clone https://github.com/yhilpisch/tpqoa
cd tpqoa
python setup.py install


# PYTHON LIBRARIES
cd /home/ubuntu
pip install jupyter imageio
pip install ccxt ta-lib
pip install numpy pandas matplotlib seaborn
pip install scikit-learn xgboost tensorflow


