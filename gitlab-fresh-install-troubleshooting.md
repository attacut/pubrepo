# GitLab Fresh Installation Troubleshooting

## 🚨 Problem: Upgrade Path Error on Fresh Install

**Situation**: 
- ติดตั้งครั้งแรก (Fresh Installation)
- ยังไม่เคยมี GitLab ใน cluster
- แต่ได้รับ error: "unsupported upgrade path"

## 🔍 Possible Root Causes (Non-Version Related)

### 1. **Existing Resources in Cluster**
มี resources หรือ metadata ใน Kubernetes ที่ทำให้ GitLab คิดว่าเป็น upgrade

```bash
# ตรวจสอบ resources ที่อาจเหลืออยู่
kubectl get all --all-namespaces | grep -i gitlab
kubectl get secrets --all-namespaces | grep -i gitlab
kubectl get configmaps --all-namespaces | grep -i gitlab
kubectl get pv | grep -i gitlab
kubectl get pvc --all-namespaces | grep -i gitlab
```

### 2. **Helm Release History**
มี Helm release ที่ fail หรือ incomplete

```bash
# ดู helm releases ทั้งหมด
helm list --all-namespaces

# ดู release history
helm history gitlab -n gitlab 2>/dev/null || echo "No history found"

# ดู releases ที่ fail
helm list --failed --all-namespaces
```

### 3. **Chart Dependencies Issue**
Chart dependencies อาจมีปัญหาหรือ outdated

```bash
# อยู่ใน chart directory
cd /Users/noppasinsritongkul/Desktop/GIT/pubrepo/helm/gitlab

# ตรวจสอบ dependencies
helm dependency list

# Update dependencies
helm dependency update
```

### 4. **GitLab Operator หรือ CRDs**
อาจมี GitLab Operator หรือ Custom Resource Definitions อยู่แล้ว

```bash
# ตรวจสอบ CRDs ที่เกี่ยวข้องกับ GitLab
kubectl get crd | grep -i gitlab

# ตรวจสอบ operators
kubectl get deployments --all-namespaces | grep -i gitlab
kubectl get deployments --all-namespaces | grep -i operator
```

## ✅ Step-by-Step Solutions

### Solution 1: Complete Environment Check
```bash
# 1. ตรวจสอบว่าไม่มี GitLab resources
kubectl get all --all-namespaces | grep -i gitlab
kubectl get secrets --all-namespaces | grep -i gitlab
kubectl get pv | grep -i gitlab

# 2. ตรวจสอบ helm releases
helm list --all-namespaces
helm list --all --all-namespaces

# 3. หากพบ resources เก่า ให้ลบ
# kubectl delete <resource-type> <name> -n <namespace>
```

### Solution 2: Clean Chart Dependencies
```bash
# Navigate to chart directory
cd /Users/noppasinsritongkul/Desktop/GIT/pubrepo/helm/gitlab

# Clean and update dependencies
rm -rf charts/
rm Chart.lock
helm dependency update

# Verify dependencies
helm dependency list
```

### Solution 3: Use Dry-Run to Debug
```bash
# Test installation without actually installing
helm install gitlab ./helm/gitlab -n gitlab --create-namespace --dry-run --debug

# This will show exactly what resources would be created
# and may reveal why GitLab thinks it's an upgrade
```

### Solution 4: Use Different Installation Method
```bash
# Install from official GitLab repo instead
helm repo add gitlab https://charts.gitlab.io/
helm repo update

# List available versions
helm search repo gitlab/gitlab

# Install from official repo
helm install gitlab gitlab/gitlab \
  --set global.storageClass=nfs-client \
  --set global.hosts.domain=gitlab.local \
  --set global.hosts.https=false \
  --set global.ingress.enabled=false \
  --set gitlab.webservice.service.type=NodePort \
  --set gitlab.webservice.service.nodePort.http=30080 \
  --set gitlab.gitlab-shell.service.type=NodePort \
  --set gitlab.gitlab-shell.service.nodePort=30022 \
  --set postgresql.install=true \
  --set redis.install=true \
  --set gitlab-runner.install=false \
  --set prometheus.install=false \
  --set installCertmanager=false \
  --set nginx-ingress.enabled=false \
  --namespace gitlab \
  --create-namespace
```

### Solution 5: Check Kubernetes Cluster State
```bash
# ตรวจสอบ cluster version
kubectl version --short

# ดู cluster info
kubectl cluster-info

# ตรวจสอบ nodes
kubectl get nodes -o wide

# ดู storage classes
kubectl get storageclass
```

## 🔧 Specific Troubleshooting Commands

### Debug Helm Installation
```bash
# เพิ่ม --debug flag เพื่อดู detailed logs
helm install gitlab ./helm/gitlab -n gitlab --create-namespace --debug

# หรือใช้ template command เพื่อดู generated YAML
helm template gitlab ./helm/gitlab --debug > generated-manifests.yaml
```

### Check GitLab Chart Integrity
```bash
cd /Users/noppasinsritongkul/Desktop/GIT/pubrepo/helm/gitlab

# ตรวจสอบ Chart.yaml
cat Chart.yaml | grep -E "(version|appVersion)"

# ตรวจสอบ templates
ls -la templates/

# Validate chart
helm lint .
```

### Monitor Real-time Events
```bash
# Terminal 1: Monitor events
kubectl get events -w --all-namespaces

# Terminal 2: Run installation
helm install gitlab ./helm/gitlab -n gitlab --create-namespace
```

## 📋 Pre-Installation Checklist

### Environment Verification
- [ ] Kubernetes cluster is healthy
- [ ] No existing GitLab resources
- [ ] Storage class `nfs-client` exists and works
- [ ] Sufficient resources (CPU/Memory)
- [ ] No conflicting applications on NodePorts 30022, 30080, 30443

### Chart Verification
- [ ] Chart dependencies are updated
- [ ] Chart passes `helm lint`
- [ ] Dry-run completes without errors
- [ ] values.yaml syntax is correct

## 🎯 Most Likely Solutions for Fresh Install

### 1. **Clean Dependencies** (Most Common)
```bash
cd /Users/noppasinsritongkul/Desktop/GIT/pubrepo/helm/gitlab
rm -rf charts/ Chart.lock
helm dependency update
helm install gitlab . -n gitlab --create-namespace
```

### 2. **Use Official Repo** (Safest)
```bash
helm repo add gitlab https://charts.gitlab.io/
helm install gitlab gitlab/gitlab \
  --values /Users/noppasinsritongkul/Desktop/GIT/pubrepo/helm/gitlab/values.yaml \
  --namespace gitlab \
  --create-namespace
```

### 3. **Debug Mode** (For Investigation)
```bash
helm install gitlab ./helm/gitlab -n gitlab --create-namespace --debug --dry-run
```

## 📞 If All Else Fails

### Create Minimal values.yaml
```yaml
# minimal-values.yaml
global:
  hosts:
    domain: gitlab.local
    https: false
  storageClass: nfs-client
  ingress:
    enabled: false

gitlab:
  webservice:
    service:
      type: NodePort
      nodePort:
        http: 30080
  gitlab-shell:
    service:
      type: NodePort  
      nodePort: 30022

postgresql:
  install: true
redis:
  install: true
gitlab-runner:
  install: false
prometheus:
  install: false
installCertmanager: false
nginx-ingress:
  enabled: false
```

```bash
helm install gitlab gitlab/gitlab -f minimal-values.yaml -n gitlab --create-namespace
```

ปัญหา "upgrade path" ในการติดตั้งครั้งแรกมักเกิดจาก chart dependencies หรือ existing resources ครับ! 🔍
