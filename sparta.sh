#!/bin/bash

# Current folder
curdir=`pwd`

case "$1" in
  requirement)
    yum -y install epel-release nano firewalld
    systemctl start firewalld
    systemctl enable firewalld
    systemctl status firewalld
    echo "Please enter your hostname:"
    read -p "(Something like: ns.domain.tld):" hn
    hostname ${hn}
  ;;
  secure-ssh)
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
  ;;
  softether-install)
    yum -y groupinstall "Development Tools"
    cd /opt
    echo "Please go to softether-download.com and paste the latest release here:"
    read -p "(Default Version: Ver 4.29, Build 9680, rtm ):" seurl
    [ -z "${seurl}" ] && seurl="https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.29-9680-rtm/softether-vpnserver-v4.29-9680-rtm-2019.02.28-linux-x64-64bit.tar.gz"
    wget -c ${seurl}
    tar -xvf softether-vpnserver-*
    cd vpnserver
    make
    ./vpnserver start
    firewall-cmd --zone=public --add-port=443/tcp --permanent
    firewall-cmd --zone=public --add-port=8888/tcp --permanent
    firewall-cmd --zone=public --add-port=992/tcp --permanent
    firewall-cmd --zone=public --add-port=5555/tcp --permanent
    firewall-cmd --zone=public --add-port=1194/tcp --permanent
    firewall-cmd --reload
  ;;
  shadowsocks-install)
    cd ${curdir}/ss
    chmod +x shadowsocks.sh
    ./shadowsocks.sh
    /etc/init.d/shadowsocks start
  ;;
  wireguard-install)
    curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
    yum -y install epel-release nano firewalld
    yum -y install wireguard-dkms wireguard-tools
    read -n 1 -s -r -p "Press any key to reboot:"
    reboot
  ;;
  wireguard-config)
    mkdir /etc/wireguard && cd /etc/wireguard
    umask 077
    wg genkey | tee privatekey | wg pubkey > publickey
    touch wg0.conf
    ip link add dev wg0 type wireguard
    echo "Please enter the port which you want to connect to wireguard with:"
    read -p "(Default Port: 34777 ):" wgport
    [ -z "${wgport}" ] && wgport="34777"
    read -p "(Please enter your client Public Key: ):" cPK
    echo "Please enter wireguard server IP address:"
    read -p "(eg: 192.168.89.1/24 ):" wgip
    echo "Please enter your allowed IP address range:"
    read -p "(eg: 192.168.89.0/24 ):" aipr
    ip address add dev wg0 ${wgip}
    wg set wg0 listen-port ${wgport} private-key privatekey peer ${cPK} allowed-ips ${aipr}
    ip link set up dev wg0
    wg setconf wg0 wg0.conf
    wg-quick save wg0
    cat <<EOF > /etc/firewalld/services/wireguard.xml
    <?xml version="1.0" encoding="utf-8"?>
    <service>
        <short>wireguard</short>
        <description>WireGuard (wg) custom installation</description>
        <port protocol="udp" port="${wgport}"/>
        <port protocol="tcp" port="${wgport}"/>
     </service>
    EOF
    firewall-cmd --add-service=wireguard --permanent
    firewall-cmd --zone=public --add-masquerade --permanent
    firewall-cmd --reload
    firewall-cmd --list-all
    sysctl -w net.ipv4.ip_forward=1
    sysctl -w net.ipv6.conf.all.forwarding=1
    tee -a /etc/sysctl.d/99-sysctl.conf
    sysctl -w net.ipv4.ip_forward=1
    sysctl -w net.ipv6.conf.all.forwarding=1
  ;;
  *)
    echo "This is not how it works!"
    echo "Use one the following command (refer to readme.md for more info):"
    echo "./sparta requirement"
    echo "./sparta secure-ssh"
    echo "./sparta softether-install"
    echo "./sparta shadowsocks-install"
    echo "./sparta wireguard-install"
    echo "./sparta wireguard-config"
  ;;
esac
