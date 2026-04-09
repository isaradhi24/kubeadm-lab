
The "Morning Routine" Automation:
Instead of manually fixing it, let's ensure the service is enabled to start on boot. Run this on the Jenkins VM:

Bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
The Vagrant "Pause":
When you finish for the day, DO NOT use vagrant destroy. Use:

Bash
vagrant suspend  # Saves the exact RAM state to disk
# OR
vagrant halt     # Graceful shutdown
Next morning: vagrant up will bring it back exactly where you left it.

The Fix: Make it Permanent
Check the Persistence: Since we installed Jenkins manually, ensure the data directory is safe. Jenkins keeps everything in /var/lib/jenkins.

kubeadm-lab/ (Root Project Dir)
├── .gitignore
├── vagrantfile                # Cluster & VM configuration
├── README.md
│
├── apps/                      # <--- NEW: Application Source Code (Developer Zone)
│   └── my-nginx-app/
│       ├── Dockerfile
│       └── index.html
│
├── manifests/                 # <--- Infrastructure State (ArgoCD Zone)
│   ├── deployment.yaml        # Updated automatically by Jenkins
│   ├── service.yaml
│   ├── argocd-namespace.yaml
│   └── ... (your other .yaml files)
│
├── pipelines/                 # <--- The "Automation Library" (DevOps Zone)
│   ├── infra/
│   │   └── k8s-bootstrap.Jenkinsfile
│   └── apps/
│       └── my-nginx-app.Jenkinsfile  # The script we just wrote
│
├── scripts/                   # <--- Shell helpers for VM provisioning
│   ├── install_docker.sh
│   ├── install_jenkins.sh
│   └── ... 
│
├── installers/                # <--- Local binaries/zips (ignored by git)
├── secrets/                   # <--- Local keys (STRICTLY ignored by git)
└── jenkins_home/              # <--- Jenkins Configuration as Code
    └── casc_configs/
        └── jenkins.yaml