#!/bin/bash
# My first script

yum update -y
df -h
yum install nano
mkdir -p ~/.ssh
echo "Please enter your public key for your secure SSH connection:"
read -p "(Enter it without ssh-rsa):" sshauthkey
echo ssh-rsa $sshauthkey >> ~/.ssh/authorized_keys
chmod -R go= ~/.ssh
chown -R root:root ~/.ssh
nano /etc/ssh/sshd_config
systemctl restart sshd
hostname sparta.mlsrp.ir
hostname
