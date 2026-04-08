#!/bin/bash
# =========================================
# Jenkins Configuration Script (No plugins)
# Sets up admin user and security
# =========================================

set -ex

JENKINS_HOME="/var/lib/jenkins"
INIT_GROOVY="$JENKINS_HOME/init.groovy.d"

echo "Stopping Jenkins..."
sudo systemctl stop jenkins || true

echo "Preparing init scripts directory..."
sudo mkdir -p "$INIT_GROOVY"

# Disable setup wizard
echo "2.0" | sudo tee "$JENKINS_HOME/jenkins.install.UpgradeWizard.state"

# -----------------------------
# Admin User and Security Setup
# -----------------------------
sudo tee "$INIT_GROOVY/basic-setup.groovy" > /dev/null <<'EOF'
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.get()

// Create admin user
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("vijay","42557")
instance.setSecurityRealm(hudsonRealm)

// Set authorization strategy
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)

instance.save()
EOF

# Fix ownership of init scripts
sudo chown -R jenkins:jenkins "$INIT_GROOVY"
sudo chmod -R 755 "$INIT_GROOVY"

# -----------------------------
# Restart Jenkins
# -----------------------------
echo "Starting Jenkins..."
sudo systemctl start jenkins

echo "Waiting for Jenkins to be ready..."
for i in {1..30}; do
  curl -s http://localhost:8080/login && break
  echo "Waiting for Jenkins... ($i/30)"
  sleep 10
done

echo "✅ Jenkins is fully configured with admin user and security!"