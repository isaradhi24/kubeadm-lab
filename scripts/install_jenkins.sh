#!/bin/bash
set -e  

###############################################################
# Jenkins Installation Script
# Supports: Ubuntu,    
# Installs Java 17 and Jenkins, starts the service, and config
#################################################################
# It automatically:
#
# Installs Java (required)
# Adds Jenkins repository
# Installs Jenkins
# Starts & enables service
# Opens firewall (if applicable)
#################################################################

echo "=== Starting Jenkins Installation (Ubuntu) ==="

# 1. Update and install prerequisites
apt-get update -y
apt-get install -y ca-certificates curl gnupg fontconfig

# 2. Install Java (Using OpenJDK 17 as it's the stable standard for Jenkins 2.4xx+)
echo "Installing Java 17..."
apt-get install -y openjdk-17-jre
java -version

# 3. Setup Jenkins Keyring (Headless Fix)
echo "Cleaning old Jenkins keys and lists..."
sudo rm -f /etc/apt/keyrings/jenkins-keyring.gpg
sudo rm -f /etc/apt/sources.list.d/jenkins.list

echo "Adding Jenkins Repository..."
sudo mkdir -p /etc/apt/keyrings
# Using gpg --dearmor to convert the key to the format Ubuntu 22.04+ expects
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/jenkins-keyring.gpg

# 4. Add Jenkins Repository
# We ensure the [signed-by] path matches the -o path above exactly
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# 5. Update and Install
sudo apt-get update -y
sudo apt-get install -y jenkins

# 6. Start and Enable Jenkins
echo "Starting Jenkins Service..."
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

# 7. Configure Docker Permissions
# Crucial: This allows Jenkins to run Docker commands for your Pipeline
echo "Configuring Docker group for Jenkins user..."
if getent group docker; then
    sudo usermod -aG docker jenkins
    echo "Jenkins user added to Docker group."
else
    echo "Warning: Docker group not found. Ensure install_docker.sh ran first."
fi

# 8. Firewall (UFW)
if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow 8080/tcp
    sudo ufw reload
fi

# 9. Output Access Info
# We use eth1 because Vagrant usually assigns the private static IP there
IP_ADDR=$(ip -4 addr show eth1 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || hostname -I | awk '{print $2}')

echo "------------------------------------------------------------"
echo "Jenkins Installation Completed!"
echo "Access URL: http://${IP_ADDR}:8080"
echo "Waiting for initial admin password to be generated..."
sleep 10
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    echo "Initial Admin Password:"
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
else
    echo "Password file not found yet. Check /var/lib/jenkins/secrets/ manually."
fi
echo "------------------------------------------------------------"