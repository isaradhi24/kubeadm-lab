#!/bin/bash
# =========================================
# Jenkins Configuration Script (No plugins)
# Sets up admin user and security
# =========================================

set -ex

# Define paths
SYNCED_DIR="/var/lib/jenkins_home"
JENKINS_HOME="/var/lib/jenkins"
INIT_GROOVY="$JENKINS_HOME/init.groovy.d"

echo "Stopping Jenkins..."
sudo systemctl stop jenkins || true

echo "Preparing init scripts directory..."
sudo mkdir -p "$INIT_GROOVY"

# Disable setup wizard
# echo "2.0" | sudo tee "$JENKINS_HOME/jenkins.install.UpgradeWizard.state"
echo "2.0" | sudo tee "$JENKINS_HOME/jenkins.install.InstallUtil.lastExecVersion"
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

// --- Create Infra Pipeline Job ---
def infraJobName = "k8s-bootstrap"
def infraPipelineScript = new File("/var/lib/jenkins_home/pipelines/infra/k8s-bootstrap.Jenkinsfile").text
def flowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition(infraPipelineScript, true)
def job = instance.createProject(org.jenkinsci.plugins.workflow.job.WorkflowJob, infraJobName)
job.setDefinition(flowDefinition)

// --- Create Apps Pipeline Job ---
def appJobName = "my-nginx-app"
def appPipelineScript = new File("/var/lib/jenkins_home/pipelines/apps/my-nginx-app.Jenkinsfile").text
def appFlowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition(appPipelineScript, true)
def appJob = instance.createProject(org.jenkinsci.plugins.workflow.job.WorkflowJob, appJobName)
appJob.setDefinition(appFlowDefinition)


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