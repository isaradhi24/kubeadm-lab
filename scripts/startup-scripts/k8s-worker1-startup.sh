#!/bin/bash
# Worker Node Startup Script

echo "🚀 Starting K8s-Worker1 Recovery..."

# 1. Disable Swap
sudo swapoff -a
echo "✅ Swap disabled."

# 2. Restart Kubelet
sudo systemctl restart kubelet
echo "✅ Kubelet restarted."

# 3. Clean up and Restart GitHub Runner
echo "🤖 Restarting GitHub Runner..."
# Kill any existing runner processes
ps aux | grep Runner.Listener | grep -v grep | awk '{print $2}' | xargs kill -9 > /dev/null 2>&1 || true

# Start the runner
cd ~
mkdir -p actions-runner && cd actions-runner

# Create a folder
mkdir actions-runner && cd actions-runner
# Download the latest runner package
curl -O -L https://github.com/actions/runner/releases/download/v2.333.1/actions-runner-linux-x64-2.333.1.tar.gz

# Extract the installer
tar xzf ./actions-runner-linux-x64-2.333.1.tar.gz

# you can see files
# config.sh
# run.sh
# svc.sh

# Register the runner with GitHub
./config.sh --url https://github.com/isaradhi24/kubeadm-lab \
--token  \
--lables k8s-worker1 --unattended

sudo ./svc.sh install
sudo ./svc.sh start

nohup ./run.sh > ~/scripts/runner_startup.log 2>&1 &


echo "✅ GitHub Runner is listening in the background."
echo "✨ Worker is ready!"