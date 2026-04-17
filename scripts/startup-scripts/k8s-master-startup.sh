#!/bin/bash
# Master Node Startup Script

echo "🚀 Starting K8s-Master Recovery..."

# 1. Disable Swap (K8s won't run with it)
sudo swapoff -a
echo "✅ Swap disabled."

# 2. Restart Kubelet
sudo systemctl restart kubelet
echo "⏳ Kubelet restarted. Waiting for API Server to wake up..."

# 3. Wait for API Server (Port 6443) to be active
while ! nc -z localhost 6443; do   
  sleep 3
  echo "Waiting for 6443..."
done
echo "✅ API Server is UP."

# 4. Verification
kubectl get nodes

# 5. Fix ArgoCD (Clear old tunnels and start a new one)
echo "🔧 Setting up ArgoCD Bridge..."
sudo pkill -f "port-forward" || true
nohup kubectl port-forward svc/argocd-server -n argocd 8888:443 --address 0.0.0.0 > /dev/null 2>&1 &

echo "✨ Master is ready! ArgoCD: https://192.168.56.10:8888"