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
```

### Component status
```bash
kubectl get componentstatuses
```

## 📦 2. System Pods (kube-system)
```bash
kubectl get pods -n kube-system -o wide
kubectl get ds -n kube-system
kubectl get deploy -n kube-system
```

## 🔥 3. ArgoCD Health Check

### Namespace
```bash
kubectl get ns argocd
```
### Pods
```bash
kubectl get pods -n argocd -o wide
```
### Services
```bash
kubectl get svc -n argocd
```
### Applications
```bash
kubectl get applications -n argocd
```

## ⚙️ 4. Workload Overview
### All resources
```bash
kubectl get all -A
```
### Deployments
```bash
kubectl get deployments -A
```
### DaemonSets
```bash
kubectl get ds -A
```
### ReplicaSets
```bash
kubectl get rs -A
```

## 📊 5. Node Deep Dive
```bash
kubectl describe node k8s-master
kubectl describe node k8s-worker1
```

## 🚨 6. Debugging

### Events
```bash
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

### Problem pods
kubectl get pods -A | grep -E "Crash|Pending|Error"
```

## ⚡ Quick Daily Check
```bash
kubectl get nodes
kubectl get pods -n kube-system
kubectl get pods -n argocd
```
