pipeline {
    agent any

    stages {
        stage('Preparation') {
            steps {
                // Ensure the workspace is clean
                cleanWs()
                checkout scm
                //git credentialsId: 'GitHub_ID', 
                //url: 'https://github.com/isaradhi24/kubeadm-lab.git',
                //branch: 'main'

            }
        }

        stage('Bootstrap K8s Tools') {
            steps {
                sshagent(['k8s-master-ssh']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no vagrant@192.168.56.10 << 'EOF'
                        # 1. Install Helm if missing
                        if ! command -v helm &> /dev/null; then
                            curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
                        fi

                        # 2. Install ArgoCD via Helm
                        kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
                        helm repo add argo https://argoproj.github.io/argo-helm
                        helm repo update
                        helm upgrade --install argocd argo/argo-cd -n argocd --wait

                        # 3. AUTOMATION: Ensure external access via NodePort
                        kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
EOF
                    """
                }
            }
        }

        
        /* COMMENTING OUT UNTIL SONARQUBE IS UP
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube-lab') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=demo-app'
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        */

        stage('Trigger ArgoCD Sync') {
            steps {
                echo "In a GitOps flow, Jenkins would now update the Image Tag in Git."
                echo "ArgoCD will then detect the change and sync the cluster."
            }
        }
    }
}