#!/bin/bash
# My first script
# Current folder
curdir=`pwd`
##################################requirement
curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
yum -y install epel-release nano firewalld
yum -y install wireguard-dkms wireguard-tools
##################################firewall
systemctl start firewalld
systemctl enable firewalld
systemctl status firewalld
###################################reboot
read -n 1 -s -r -p "Press any key to reboot:"
reboot

