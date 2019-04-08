#!/bin/bash
# My first script
# Current folder
curdir=`pwd`
##################################requirement
yum -y install epel-release nano git firewalld
yum -y groupinstall "Development Tools"
##################################firewall
systemctl start firewalld
systemctl enable firewalld
systemctl status firewalld
######################################ssh
mkdir -p ~/.ssh
echo "Please enter your public key for your secure SSH connection:"
read -p "(Enter it completely):" sshauthkey
echo ${sshauthkey} >> ~/.ssh/authorized_keys
chmod -R go= ~/.ssh
chown -R root:root ~/.ssh
echo "Please enter the port that you want to connect to SSH with:"
read -p "(Default Port: 22511 ):" cussshport
[ -z "${cussshport}" ] && cussshport="22511"
sed -i 's/.*Port 22.*/Port '"$cussshport"'/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
firewall-cmd --zone=public --add-port=${cussshport}/tcp --permanent
firewall-cmd --reload
systemctl restart sshd
##################################hostname
echo "Please enter your hostname:"
read -p "(Something like: ns.domain.tld):" hn
hostname ${hn}
###################################vpnserver
cd /opt
git clone https://github.com/SoftEtherVPN/SoftEtherVPN_Stable.git
cd SoftEtherVPN
make
make install
./vpnserver start
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --zone=public --add-port=8888/tcp --permanent
firewall-cmd --zone=public --add-port=992/tcp --permanent
firewall-cmd --zone=public --add-port=5555/tcp --permanent
firewall-cmd --zone=public --add-port=1194/tcp --permanent
firewall-cmd --reload
####################################proxyserver
cd ${curdir}/ss
chmod +x shadowsocks.sh
./shadowsocks.sh
/etc/init.d/shadowsocks start
read -p "(Enter shadowsocks port for firewall):" ssport
firewall-cmd --zone=public --add-port=${ssport}/tcp --permanent
firewall-cmd --reload
###################################reboot
echo "If there was no error, your vpn server is ready to use"
read -n 1 -s -r -p "Press any key to reboot:"
reboot
