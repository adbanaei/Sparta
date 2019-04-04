# Sparta
It's a VPN and Proxy server base on CentOS7

# What's it for
This script will configurate your freshly installed CentOS7. 
Here the thing it does:
1. Secure SSH
* Activate key authentication
* Disable the password authentication
* Change its default port
2. Set hostname
3. Install SoftEtherVPN
4. Install and configurate Shadowsocks-Python

# How to use
First, update your system:
```
yum -y update
yum -y upgrade
reboot
```
Then you can use it:
```
cd /opt
git clone https://github.com/adbanaei/Sparta.git
cd Sparta/
chmod +x install.sh
./install.sh
```

#Customize SoftEtherVPN
You can download SoftEtherVPN server manager GUI for windows and mac from [here](https://www.softether-download.com/)

#Customize Shadowsocks
You can configure the Shadowsocks by change the its conf file:
```
nano /etc/shadowsocks.json
```
Like this:
```
{
    "server":"0.0.0.0",
    "local_address":"127.0.0.1",
    "local_port":1080,
    "port_password": {
        "9381": "28c9y298rcyc289",
        "9382": "qc9euq29cn92veu",
        "9383": "wmvi3mrhwiwcoim",
        "9384": "c2i9c3m9u2c39cu"
    },
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open":false
}
```
And do this to apply them:
```
/etc/init.d/shadowsocks restart
firewall-cmd --zone=public --add-port=9381/tcp --permanent
firewall-cmd --zone=public --add-port=9382/tcp --permanent
firewall-cmd --zone=public --add-port=9383/tcp --permanent
firewall-cmd --zone=public --add-port=9384/tcp --permanent
firewall-cmd --reload
```
> Feel free to share your thoughts!

Copyright (C) 2019 adbanaei
