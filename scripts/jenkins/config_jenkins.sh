#!/bin/bash
# =========================================
# Jenkins Configuration Script (No plugins)
# Sets up admin user and security
# =========================================

#!/bin/bash
set -ex

JENKINS_HOME="/var/lib/jenkins"
INIT_GROOVY="$JENKINS_HOME/init.groovy.d"

sudo systemctl stop jenkins || true
sudo mkdir -p "$INIT_GROOVY"

sudo tee "$INIT_GROOVY/basic-setup.groovy" > /dev/null <<'EOF'
import jenkins.model.*
import hudson.security.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition

def instance = Jenkins.get()

// 1. Setup Security
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
// Setting password to 'password' as you expected
hudsonRealm.createAccount("vijay", "42557")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)

// 2. Helper function to create jobs safely
def createPipelineJob = { jobName, filePath ->
    if (instance.getItem(jobName)) {
        println "--> Job ${jobName} already exists, skipping."
        return
    }
    
    def scriptFile = new File(filePath)
    if (scriptFile.exists()) {
        def flowDefinition = new CpsFlowDefinition(scriptFile.text, true)
        def job = instance.createProject(WorkflowJob, jobName)
        job.setDefinition(flowDefinition)
        job.save()
        println "--> Created job ${jobName}"
    } else {
        println "--> ERROR: Config file not found at ${filePath}"
    }
}

// 3. Create Jobs
createPipelineJob("k8s-bootstrap", "/var/lib/jenkins_home/pipelines/infra/k8s-bootstrap.Jenkinsfile")
createPipelineJob("my-nginx-app", "/var/lib/jenkins_home/pipelines/apps/my-nginx-app.Jenkinsfile")

instance.save()
EOF

# Crucial: Jenkins must own everything
sudo chown -R jenkins:jenkins "$JENKINS_HOME"
sudo systemctl start jenkins