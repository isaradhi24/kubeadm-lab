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
### if ArgoCD not installed
```bash
sudo -u vagrant kubectl create namespace argocd --dry-run=client -o yaml | \
sudo -u vagrant kubectl apply -f -

sudo -u vagrant kubectl apply \
  -n argocd \
  -f /vagrant/manifests/argocd-install.yaml \
  --server-side
```
### if something looks "stuck"
```bash
kubectl get events -n argocd --sort-by=.metadata.creationTimestamp
or
kubectl describe pod -n argocd <pod>
```
### After ArgoCD up and verything is running
## Portfowarding
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
or
### if your on vm run below
kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443  
```
## Login password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```
## login to ArgoCD in browser

url : https://localhost:8080
or
url : https://120.0.0.1:8080

user: admin
passowd: from above step


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
```bash
kubectl get pods -A | grep -E "Crash|Pending|Error"
```

### ⚡ Quick Daily Check
```bash
kubectl get nodes
kubectl get pods -n kube-system
kubectl get pods -n argocd
```
