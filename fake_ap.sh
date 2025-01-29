#!/bin/bash


echo "Enter your Wireless MM interface"

read int_wlan

echo "Enter the SSID of the AP"

read ssid

directory_name="fap"

if which hostapd > /dev/null; then
        echo "Proceeding"
else 
        echo "hostapd not installed, installing..."
        apt-get install hostapd
fi


if which dnsmasq > /dev/null; then
        echo "Prcoeeding"
else
        echo "dnsmasq not installed, installing..."
        apt-get install dnsmasq 
fi


mkdir $directory_name

if [ $? -eq 0 ]; then
        echo "Directory fake access point (fap) created"
else
        echo "Error creating directory"
fi

cd fap || { echo "Directory not found"; exit 1; }

echo "interface=$int_wlan" > hostapd.conf
echo "driver=nl80211" >> hostapd.conf
echo "ssid=$ssid" >> hostapd.conf
echo "hw_mode=g" >> hostapd.conf
echo "channel=1" >> hostapd.conf
echo "macaddr_acl=0" >> hostapd.conf
echo "ignore_boradcast_ssid=0" >> hostapd.conf


echo "interface=$int_wlan" > dnsmasq.conf
echo "dhcp-range=192.168.1.2, 192.168.1.50, 255.255.255.0, 24h" >> dnsmasq.conf
echo "dhcp-option=3, 192.168.1.1" >> dnsmasq.conf
echo "dhcp-option=6, 192.168.1.1" >> dnsmasq.conf
echo "server=1.1.1.1" >> dnsmasq.conf
echo "log-queries" >> dnsmasq.conf
echo "log-dhcp" >> dnsmasq.conf
echo "listen-address=127.0.0.1"

ifconfig $int_wlan up 192.168.1.1 netmask 255.255.255.0
route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.1

iptables --table nat --append POSTROUTING --out-interface $int_wlan -j MASQUERADE
iptables --append FORWARD --in-interface $int_wlan -j ACCEPT

echo 1 > /proc/sys/net/ipv4/ip_forward



