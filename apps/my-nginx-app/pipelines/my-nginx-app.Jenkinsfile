pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "isaradhi24/my-nginx-app"
        MANIFEST_PATH = "/vagrant/manifests/deployment.yaml"
    }
    stages {
        stage('Build & Push') {
            steps {
                dir('/tmp/my-nginx-app') {
                    sh "docker build -t ${DOCKER_IMAGE}:v${BUILD_NUMBER} ."
                    withCredentials([usernamePassword(credentialsId: 'DockerHub_ID', usernameVariable: 'U', passwordVariable: 'P')]) {
                        sh "docker login -u $U -p $P"
                        sh "docker push ${DOCKER_IMAGE}:v${BUILD_NUMBER}"
                    }
                }
            }
        }
        
        stage('Update GitOps Manifest') {
            steps {
                echo "Updating ${MANIFEST_PATH} to version v${BUILD_NUMBER}"
                
                // This command looks for 'image: isaradhi24/my-nginx-app:...' and replaces the tag
                sh "sed -i 's|image: ${DOCKER_IMAGE}:.*|image: ${DOCKER_IMAGE}:v${BUILD_NUMBER}|g' ${MANIFEST_PATH}"
                
                // Verify the change in the logs
                sh "grep 'image:' ${MANIFEST_PATH}"
            }
        }
    }
}