#!/bin/bash
echo "🚀 Starting K8s-Master Recovery..."

export KUBECONFIG=/etc/kubernetes/admin.conf

sudo swapoff -a
echo "✅ Swap disabled."

sudo systemctl restart kubelet
echo "⏳ Waiting for API Server..."

until nc -z localhost 6443; do
  sleep 3
  echo "Waiting for 6443..."
done

echo "✅ API Server is UP."

echo "🔍 Cluster status:"
kubectl get nodes -o wide
kubectl get pods -A | grep -v Running || true

echo "🔧 Restarting ArgoCD port-forward..."
sudo pkill -f "port-forward" || true

nohup kubectl -n argocd port-forward svc/argocd-server 8888:443 \
  --address 0.0.0.0 > /var/log/argocd.log 2>&1 &

echo "✨ Master is ready!"
echo "ArgoCD: https://192.168.56.10:8888"