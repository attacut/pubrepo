# GitLab Storage Configuration Summary (Updated)

## ✅ Storage Class ที่กำหนดค่าเสร็จแล้ว

### 🌐 Global Storage Class
```yaml
global:
  storageClass: "nfs-client"
  hosts:
    domain: gitlab.local
    https: false
  ingress:
    enabled: false  # ใช้ NodePort แทน
```

### 🗄️ Individual Service Storage Configuration

#### 1. **PostgreSQL** - Database Storage
```yaml
postgresql:
  install: true
  primary:
    persistence:
      enabled: true
      storageClass: "nfs-client"
      size: 8Gi
      accessModes:
        - ReadWriteOnce
```

#### 2. **Redis** - Cache & Session Storage  
```yaml
redis:
  install: true
  master:
    persistence:
      enabled: true
      storageClass: "nfs-client"
      size: 8Gi
      accessModes:
        - ReadWriteOnce
```

#### 3. **MinIO** - Object Storage
```yaml
global:
  minio:
    enabled: true
    persistence:
      storageClass: "nfs-client"
      size: 10Gi
```

#### 4. **Gitaly** - Git Repository Storage
```yaml
gitlab:
  gitaly:
    persistence:
      storageClass: "nfs-client"
      size: 50Gi
      accessMode: ReadWriteOnce
```

#### 5. **GitLab Services** - NodePort Configuration
```yaml
gitlab:
  webservice:
    service:
      type: NodePort
      nodePort:
        http: 30080
        https: 30443
  gitlab-shell:
    service:
      type: NodePort
      nodePort: 30022
```

## 📊 Expected Persistent Volumes

เมื่อ deploy แล้ว จะมี PVC ดังนี้:

```bash
kubectl get pvc -n gitlab

# Expected output:
# NAME                              STATUS   VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# data-gitlab-postgresql-0          Bound    pv-xxx    8Gi        RWO            nfs-client     xxm
# redis-data-gitlab-redis-master-0  Bound    pv-xxx    8Gi        RWO            nfs-client     xxm  
# gitlab-minio                      Bound    pv-xxx    10Gi       RWO            nfs-client     xxm
# repo-data-gitlab-gitaly-0         Bound    pv-xxx    50Gi       RWO            nfs-client     xxm
```

## 🔐 Data Persistence Guarantee

- ✅ **Database data** (users, projects, issues) → PostgreSQL PVC (8Gi)
- ✅ **Git repositories** → Gitaly PVC (50Gi)
- ✅ **Cache & sessions** → Redis PVC (8Gi)
- ✅ **File uploads & artifacts** → MinIO PVC (10Gi)
- ✅ **Container registry images** → MinIO PVC
- ✅ **GitLab configuration** → Persistent across pod restarts

## 🌐 Network Access Configuration

### NodePort Services
```bash
# Web Interface
http://gitlab.local:30080   # HTTP
https://gitlab.local:30443  # HTTPS (self-signed cert)

# SSH Access  
ssh://git@gitlab.local:30022

# API Access
http://gitlab.local:30080/api/v4
```

### Services ที่ปิดไว้
- ❌ **nginx-ingress**: `enabled: false`
- ❌ **cert-manager**: `installCertmanager: false`
- ❌ **prometheus**: `install: false`
- ❌ **gitlab-runner**: `install: false`
- ❌ **gitlab-zoekt**: `install: false`

## 🚨 Important Notes

### 1. **NFS Storage Class Required**
```bash
kubectl get storageclass nfs-client
# ต้องมี nfs-client และ set เป็น default หรือระบุชัด
```

### 2. **Storage Sizes** (ปรับได้ตามความต้องการ)
- **Gitaly**: 50Gi (เก็บ Git repos) - ขนาดใหญ่สุด
- **MinIO**: 10Gi (files, artifacts, registry)
- **PostgreSQL**: 8Gi (database)  
- **Redis**: 8Gi (cache)

### 3. **Domain Configuration**
```bash
# เพิ่มใน /etc/hosts
<NODE-IP> gitlab.local

# หรือใช้ IP โดยตรง
http://<NODE-IP>:30080
```

### 4. **HTTPS Configuration**
```yaml
# ปัจจุบันปิดไว้ เพราะไม่มี cert-manager
global:
  hosts:
    https: false
  ingress:
    configureCertmanager: false
```

## 🔧 Post-Deployment Checks

### ตรวจสอบ Storage
```bash
# ดู PVC status
kubectl get pvc -n gitlab

# ดู storage usage
kubectl exec -it gitlab-postgresql-0 -n gitlab -- df -h
kubectl exec -it gitlab-gitaly-0 -n gitlab -- df -h
```

### ตรวจสอบ Services
```bash
# ดู NodePort services
kubectl get svc -n gitlab | grep NodePort

# Test connectivity
curl -I http://gitlab.local:30080
```

### ตรวจสอบ Data Persistence
```bash
# สร้าง test project ใน GitLab
# Restart pods
kubectl delete pod gitlab-postgresql-0 -n gitlab
kubectl delete pod gitlab-gitaly-0 -n gitlab

# รอ pods กลับมาแล้วเช็คว่าข้อมูลยังอยู่
```

## 📈 Scaling และ Optimization

### เพิ่ม Storage
```bash
# แก้ไข PVC (ต้อง support โดย storage class)
kubectl patch pvc repo-data-gitlab-gitaly-0 -p '{"spec":{"resources":{"requests":{"storage":"100Gi"}}}}' -n gitlab
```

### ปรับ Resource Limits
```yaml
# ใน values.yaml
gitlab:
  webservice:
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
      limits:
        cpu: 1000m
        memory: 2Gi
```

## ✅ Ready to Deploy!

ไฟล์ values.yaml พร้อม deploy แล้วด้วย:
- ✅ Persistent storage configuration ครบถ้วน
- ✅ NodePort access configuration
- ✅ ปิด features เสริมที่ไม่จำเป็น
- ✅ Domain และ network setup

```bash
cd /Users/noppasinsritongkul/Desktop/GIT/pubrepo
helm install gitlab ./helm/gitlab -n gitlab --create-namespace

# รอ 10-15 นาที แล้วเข้าใช้ที่
# http://gitlab.local:30080
```
