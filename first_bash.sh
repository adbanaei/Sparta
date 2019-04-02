#!/bin/bash
# My first script

yum -y update
yum -y install epel-release nano git firewalld
yum -y groupinstall "Development Tools"
systemctl start firewalld
systemctl enable firewalld
systemctl status firewalld
mkdir -p ~/.ssh
echo "Please enter your public key for your secure SSH connection:"
read -p "(Enter it without ssh-rsa):" sshauthkey
echo ssh-rsa $sshauthkey >> ~/.ssh/authorized_keys
chmod -R go= ~/.ssh
chown -R root:root ~/.ssh
echo "Please enter the port that you want to connect to SSH with:"
read -p "(Default Port: 22511 ):" cussshport
[ -z "${cussshport}" ] && cussshport="22511"
sed -i 's/.*Port 22.*/Port $cussshport/g' /etc/ssh/sshd_config
firewall-cmd --zone=public --add-port=$cussshport/tcp --permanent
firewall-cmd --reload
systemctl restart sshd
echo "Please enter your hostname:"
read -p "(Something like: ns.domain.tld):" hn
hostname $hn
hostname
