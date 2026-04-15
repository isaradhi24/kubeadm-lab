#!/bin/bash

set -e

#----------- Update System -----------#
sudo apt update && sudo apt upgrade -y

#----------- Install dependencies -----------#
sudo apt install -y openjdk-21-jdk unzip

java -version

#----------- Create SonarQube user -----------#
sudo useradd -r -d /opt/sonarqube -s /bin/false sonarqube || true

sudo mkdir -p /opt/sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube

#---------- Copy and Extract SonarQube -----------#
cd /tmp
cp /vagrant/installers/sonarqube-26.3.0.120487.zip .

unzip -o sonarqube-26.3.0.120487.zip

# Clean existing installation safely
echo "🧹 Cleaning old SonarQube installation..."

sudo systemctl stop sonarqube || true

sudo rm -rf /opt/sonarqube
sudo mkdir -p /opt/sonarqube

# Move fresh installation
echo "📦 Installing SonarQube..."

sudo mv sonarqube-26.3.0.120487/* /opt/sonarqube/

sudo chown -R sonarqube:sonarqube /opt/sonarqube

#----------- Kernel parameters -----------#
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=65536
sudo sysctl -w net.core.somaxconn=65536

# Persist only if not already present
grep -qxF "vm.max_map_count=262144" /etc/sysctl.conf || echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
grep -qxF "fs.file-max=65536" /etc/sysctl.conf || echo "fs.file-max=65536" | sudo tee -a /etc/sysctl.conf
grep -qxF "net.core.somaxconn=65536" /etc/sysctl.conf || echo "net.core.somaxconn=65536" | sudo tee -a /etc/sysctl.conf

#----------- Systemd Service -----------#
sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOF
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=simple
User=sonarqube
Group=sonarqube
ExecStart=/bin/bash /opt/sonarqube/bin/linux-x86-64/sonar.sh console
ExecStop=/bin/bash /opt/sonarqube/bin/linux-x86-64/sonar.sh stop
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

#----------- Start SonarQube -----------#
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl restart sonarqube

sudo systemctl status sonarqube --no-pager

#----------- Access Info -----------#
ip=$(ip -4 addr show eth1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
echo "SonarQube should be accessible at: http://${ip}:9000"