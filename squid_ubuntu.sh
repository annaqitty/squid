apt update -y
apt upgrade -y
apt install squid -y
rm -f /etc/squid/squid.conf
wget --no-check-certificate -O /etc/squid/squid.conf https://raw.githubusercontent.com/annaqitty/squid/main/squid_ubuntu.conf
systemctl start squid
systemctl enable squid
systemctl restart squid
