Kubeadm-lab Structure

kubeadm-lab
|-- k8s-master
|-- k8s-worker1
|-- elk-server

# Kubernetes Lab Health Check

This document contains standard commands to verify cluster health after reboot, snapshot restore, or idle periods.

---

## 🧭 1. Cluster Basics

### Check nodes
```bash
kubectl get nodes -o wide
```
### Cluster info
```bash
kubectl cluster-info

### Component status
```bash
kubectl get componentstatuses

📦 2. System Pods (kube-system)
kubectl get pods -n kube-system -o wide
kubectl get ds -n kube-system
kubectl get deploy -n kube-system

🔥 3. ArgoCD Health Check
Namespace
kubectl get ns argocd
Pods
kubectl get pods -n argocd -o wide
Services
kubectl get svc -n argocd
Applications
kubectl get applications -n argocd

⚙️ 4. Workload Overview
All resources
kubectl get all -A
Deployments
kubectl get deployments -A
DaemonSets
kubectl get ds -A
ReplicaSets
kubectl get rs -A

📊 5. Node Deep Dive
kubectl describe node k8s-master
kubectl describe node k8s-worker1

🚨 6. Debugging
Events
kubectl get events -A --sort-by=.metadata.creationTimestamp
Problem pods
kubectl get pods -A | grep -E "Crash|Pending|Error"

⚡ Quick Daily Check
kubectl get nodes
kubectl get pods -n kube-system
kubectl get pods -n argocd
