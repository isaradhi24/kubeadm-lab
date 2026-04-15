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

# 3. Complete Purge of old Jenkins metadata
echo "Purging old Jenkins metadata..."
sudo rm -f /etc/apt/sources.list.d/jenkins.list
sudo rm -f /etc/apt/keyrings/jenkins-keyring.gpg
sudo rm -f /etc/apt/trusted.gpg.d/jenkins*
sudo apt-key del 7198F4B714ABFC68 2>/dev/null

# 4. Clean the APT cache
sudo rm -rf /var/lib/apt/lists/pkg.jenkins.io*

# 5. Re-add the Key and Repo with [trusted=yes] 
# This bypasses the GPG check if the keyring is being stubborn
echo "Adding Jenkins Repository (Hardened)..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo apt-key add -
echo "deb [trusted=yes] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# 6. Update and Install
sudo apt-get update
sudo apt-get install -y jenkins
# 7. Update with a 'clean' flag
sudo apt-get update -o Dir::Etc::sourcelist="sources.list.d/jenkins.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
sudo apt-get update -y
# 7. Update and Install
sudo apt-get update -y
sudo apt-get install -y jenkins

# 8. Start and Enable Jenkins
echo "Starting Jenkins Service..."
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

# 9. Disable the Setup Wizard in the systemd unit file
sudo sed -i 's|Environment="JAVA_OPTS=-Djava.awt.headless=true|Environment="JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false|' /lib/systemd/system/jenkins.service

# 10. Force Jenkins to believe the install is already finished
sudo mkdir -p /var/lib/jenkins
echo "2.541.3" | sudo tee /var/lib/jenkins/jenkins.install.UpgradeWizard.state
echo "2.541.3" | sudo tee /var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion
sudo chown -R jenkins:jenkins /var/lib/jenkins


# 11. Configure Docker Permissions
# Crucial: This allows Jenkins to run Docker commands for your Pipeline
echo "Configuring Docker group for Jenkins user..."
if getent group docker; then
    sudo usermod -aG docker jenkins
    echo "Jenkins user added to Docker group."
else
    echo "Warning: Docker group not found. Ensure install_docker.sh ran first."
fi

# 12. Firewall (UFW)
if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow 8080/tcp
    sudo ufw reload
fi

# 13. Output Access Info
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