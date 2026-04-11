#!/bin/bash
# =========================================
# Jenkins Plugins Installation Script
# Uses local Plugin Manager JAR from synced jenkins_home
# =========================================

set -ex

# 1. Standard Jenkins location
JENKINS_HOME="/var/lib/jenkins"
PLUGINS_FILE="/tmp/plugins.txt"
PLUGIN_MANAGER_JAR="/var/lib/jenkins_home/jenkins-plugin-manager.jar"

# 2. Point this to your SYNCED folder path from the Vagrantfile
# If your Vagrantfile says: node.vm.synced_folder "./jenkins_home", "/var/jenkins_home"
PLUGIN_MANAGER_JAR="/var/lib/jenkins_home/jenkins-plugin-manager.jar"

echo "Stopping Jenkins..."
sudo systemctl stop jenkins || true

# -----------------------------
# Plugin list
# -----------------------------
cat <<EOF | sudo tee $PLUGINS_FILE
workflow-aggregator
git
ws-cleanup

EOF

# -----------------------------
# Validate Plugin Manager JAR
# -----------------------------
# 3. Ensure the JAR exists (Download it if missing)
if [ ! -f "$PLUGIN_MANAGER_JAR" ]; then
    echo "❌ ERROR: I still can't find the JAR at $PLUGIN_MANAGER_JAR"
    exit 1
fi

if [ ! -f "$PLUGIN_MANAGER_JAR" ]; then
  echo "⚠️ Plugin Manager JAR not found in synced folder. Downloading to $PLUGIN_MANAGER_JAR..."
  sudo wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/latest/download/jenkins-plugin-manager-jar-with-dependencies.jar -O "$PLUGIN_MANAGER_JAR"
  sudo chown vagrant:vagrant "$PLUGIN_MANAGER_JAR"
fi

if ! file "$PLUGIN_MANAGER_JAR" | grep -E "Zip archive|Java archive"; then
  echo "❌ Invalid JAR file!"
  file "$PLUGIN_MANAGER_JAR"
  exit 1
fi

echo "========= JAR Details ========="
ls -lh "$PLUGIN_MANAGER_JAR"
file "$PLUGIN_MANAGER_JAR"

echo "Cleaning old/incomplete plugins..."
sudo rm -rf $JENKINS_HOME/plugins/*

# -----------------------------
# Install plugins with dependencies
# -----------------------------
# We use --jenkins-update-center to ensure it knows where to get the files
echo "Installing plugins using local JAR..."
sudo java -jar "$PLUGIN_MANAGER_JAR" \
  --plugin-file "$PLUGINS_FILE" \
  --plugin-download-directory "$JENKINS_HOME/plugins" \
  --war /usr/share/java/jenkins.war

# Fix ownership
sudo chown -R jenkins:jenkins $JENKINS_HOME
sudo chmod -R 755 $JENKINS_HOME/plugins

# -----------------------------
# Start Jenkins
# -----------------------------
echo "Restarting Jenkins after plugin installation..."
sudo systemctl start jenkins
sleep 20

# -----------------------------
# Wait for Jenkins to be ready
# -----------------------------
echo "Waiting for Jenkins to be fully ready on port 8080..."
for i in {1..30}; do
  if curl -s http://localhost:8080/login >/dev/null; then
    echo "✅ Jenkins is up!"
    break
  fi
  echo "Waiting for Jenkins... ($i/30)"
  sleep 10
done

echo "Restarting Jenkins after plugin installation..."
sudo systemctl restart jenkins
sleep 15
echo "✅ Plugins installed successfully!"