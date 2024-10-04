# Update the system
yum update -y

# Install required packages
yum install squid curl -y

# Remove the default Squid configuration file
rm -f /etc/squid/squid.conf

# Download the new Squid configuration file
wget --no-check-certificate -O /etc/squid/squid.conf https://raw.githubusercontent.com/annaqitty/squid/main/squid_ubuntu.conf

# Append the additional http_port configurations
echo "http_port 9999" >> /etc/squid/squid.conf
echo "http_port 6666" >> /etc/squid/squid.conf

# Check if firewalld is installed and running
if ! command -v firewall-cmd &> /dev/null; then
    echo "firewalld is not installed. Installing..."
    yum install firewalld -y
    systemctl start firewalld
    systemctl enable firewalld
fi

# Start and enable the Squid service
systemctl start squid
systemctl enable squid

# Restart the Squid service
systemctl restart squid

# Check and allow traffic on the Squid ports (9999 and 6666)
for port in 9999 6666; do
    if ! firewall-cmd --list-ports | grep -q "$port/tcp"; then
        firewall-cmd --zone=public --add-port=$port/tcp --permanent
        echo "Port $port opened in the firewall."
    else
        echo "Port $port is already open."
    fi
done

# Check and configure SELinux
if [ "$(sestatus | grep 'SELinux status' | awk '{print $3}')" == "enabled" ]; then
    setsebool -P squid_use_tty 1
    echo "SELinux configured for Squid."
else
    echo "SELinux is not enabled."
fi

# Get public IP address
PUBLIC_IP=$(curl -s http://ipinfo.io/ip)

# Display completion message
echo "DONE >> You can run Squid Proxy on ${PUBLIC_IP}:9999 and ${PUBLIC_IP}:6666"
