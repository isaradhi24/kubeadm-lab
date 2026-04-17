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
cd ~/actions-runner
nohup ./run.sh > ~/scripts/runner_startup.log 2>&1 &

echo "✅ GitHub Runner is listening in the background."
echo "✨ Worker is ready!"