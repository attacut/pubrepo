# GitLab Deployment Guide - Complete with Persistent Storage

## การกำหนดค่าที่ทำไว้ (Updated)

### ✅ Services ที่เปิดใช้งาน (Core Components)
- **GitLab** - Core application with NodePort (30080/30443)
- **PostgreSQL** - Database with persistent storage (8Gi)
- **Redis** - Cache and session storage with persistent storage (8Gi)
- **MinIO** - Object storage with persistent storage (10Gi)
- **Gitaly** - Git repository storage with persistent storage (50Gi)

### ❌ Services ที่ปิด (Features เสริม)
- **GitLab Runner** - CI/CD runner (install: false)
- **Prometheus** - Monitoring (install: false) 
- **Cert-Manager** - SSL certificate management (installCertmanager: false)
- **Nginx Ingress** - Load balancer (enabled: false - ใช้ NodePort แทน)
- **GitLab Zoekt** - Code search (install: false)
- **OpenBao** - Secrets management (install: false)

### 🗄️ Storage Configuration
- **Global Storage Class**: `nfs-client`
- **Domain**: `gitlab.local` (แก้ไขใน /etc/hosts หรือ DNS)
- **HTTPS**: Disabled initially (https: false)
- **Access Method**: NodePort
  - GitLab Web HTTP: `http://gitlab.local:30080`
  - GitLab Web HTTPS: `https://gitlab.local:30443`
  - GitLab SSH: `gitlab.local:30022`

### 📦 Persistent Storage Details
- **PostgreSQL**: 8Gi (database data)
- **Redis**: 8Gi (cache & sessions)
- **MinIO**: 10Gi (object storage)
- **Gitaly**: 50Gi (git repositories)

## ขั้นตอนการ Deploy

### 1. ตรวจสอบ Prerequisites
```bash
# ตรวจสอบ NFS Storage Class
kubectl get storageclass nfs-client

# ตรวจสอบ Node resources
kubectl top nodes
```

### 2. สร้าง Namespace
```bash
kubectl create namespace gitlab
```

### 3. Deploy GitLab
```bash
cd /Users/noppasinsritongkul/Desktop/GIT/pubrepo
helm install gitlab ./helm/gitlab -n gitlab
```

### 4. ติดตาม Deployment (ใช้เวลาประมาณ 10-15 นาที)
```bash
# ดู status ของ pods
kubectl get pods -n gitlab -w

# ดู services และ NodePort
kubectl get svc -n gitlab

# ดู persistent volumes
kubectl get pv
kubectl get pvc -n gitlab
```

### 5. ตรวจสอบ NodePort Services
```bash
# ดู NodePort ที่ถูกจัดสรร
kubectl get svc -n gitlab | grep NodePort

# Expected output:
# gitlab-webservice-default   NodePort   10.x.x.x   <none>   8080:30080/TCP,8181:30443/TCP
# gitlab-gitlab-shell         NodePort   10.x.x.x   <none>   22:30022/TCP
```

### 6. รับ Initial Root Password
```bash
# รอให้ deployment เสร็จแล้วรัน (อาจต้องรอ 10-15 นาที)
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath='{.data.password}' | base64 --decode
echo
```

## การเข้าถึง GitLab

### เตรียม Local DNS
1. หา IP ของ Kubernetes Node:
   ```bash
   kubectl get nodes -o wide
   ```

2. เพิ่มใน `/etc/hosts` (macOS/Linux) หรือ `C:\Windows\System32\drivers\etc\hosts` (Windows):
   ```
   <NODE-IP> gitlab.local
   ```

### Web Interface
- **URL**: `http://gitlab.local:30080`
- **Username**: `root`
- **Password**: ได้จากคำสั่งในขั้นตอนที่ 6

### SSH Access สำหรับ Git
```bash
# Clone repository
git clone ssh://git@gitlab.local:30022/username/repository.git

# Configure Git SSH
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
# แล้วเพิ่ม public key ใน GitLab Settings > SSH Keys
```

## ตรวจสอบ Persistent Storage

### ดู PVC ที่สร้างขึ้น
```bash
kubectl get pvc -n gitlab

# Expected PVCs:
# data-gitlab-postgresql-0          Bound   8Gi   RWO   nfs-client
# redis-data-gitlab-redis-master-0  Bound   8Gi   RWO   nfs-client  
# gitlab-minio                      Bound   10Gi  RWO   nfs-client
# repo-data-gitlab-gitaly-0         Bound   50Gi  RWO   nfs-client
```

### ทดสอบ Data Persistence
```bash
# สร้าง project ใน GitLab web interface
# สร้าง repository และ push code
# แล้วลบ pods เพื่อทดสอบ
kubectl delete pod -l app=postgresql -n gitlab
kubectl delete pod -l app=redis -n gitlab
kubectl delete pod -l app=gitaly -n gitlab

# รอให้ pods กลับมาแล้วตรวจสอบว่าข้อมูลยังอยู่
```

## Troubleshooting

### ตรวจสอบ Pod Status
```bash
# ดู pods ที่มีปัญหา
kubectl get pods -n gitlab | grep -v Running

# ดู logs ของ pods ที่มีปัญหา
kubectl logs <pod-name> -n gitlab
kubectl describe pod <pod-name> -n gitlab
```

### ตรวจสอบ Storage Issues
```bash
# ตรวจสอบ PVC
kubectl describe pvc -n gitlab

# ตรวจสอบ events
kubectl get events -n gitlab --sort-by='.lastTimestamp'
```

### ตรวจสอบ Network/NodePort
```bash
# ทดสอบการเชื่อมต่อ
curl -I http://gitlab.local:30080
telnet gitlab.local 30080
```

### Memory/CPU Issues
```bash
# ดู resource usage
kubectl top pods -n gitlab
kubectl describe node

# หาก resources ไม่เพียงพอ สามารถ scale down ได้
kubectl scale deployment gitlab-sidekiq-all-in-1-v2 --replicas=1 -n gitlab
```

## การ Scale และ Optimize

### ลด Resource Usage (หาก Node มี RAM น้อย)
```bash
# ลด Sidekiq replicas
kubectl patch deployment gitlab-sidekiq-all-in-1-v2 -p '{"spec":{"replicas":1}}' -n gitlab

# ลด Webservice replicas  
kubectl patch deployment gitlab-webservice-default -p '{"spec":{"replicas":1}}' -n gitlab
```

### เพิ่ม Storage (หาก disk เต็ม)
```bash
# แก้ไข PVC size (ต้อง support โดย storage class)
kubectl patch pvc repo-data-gitlab-gitaly-0 -p '{"spec":{"resources":{"requests":{"storage":"100Gi"}}}}' -n gitlab
```

## การ Backup และ Restore

### Database Backup
```bash
# Backup PostgreSQL
kubectl exec -it gitlab-postgresql-0 -n gitlab -- pg_dumpall -U postgres > gitlab-backup-$(date +%Y%m%d).sql

# Restore
kubectl cp gitlab-backup-20250828.sql gitlab-postgresql-0:/tmp/ -n gitlab
kubectl exec -it gitlab-postgresql-0 -n gitlab -- psql -U postgres -f /tmp/gitlab-backup-20250828.sql
```

### Git Repositories Backup
```bash
# Backup repositories
kubectl exec -it gitlab-gitaly-0 -n gitlab -- tar czf /tmp/repos-backup.tar.gz -C /home/git repositories
kubectl cp gitlab-gitaly-0:/tmp/repos-backup.tar.gz ./repos-backup-$(date +%Y%m%d).tar.gz -n gitlab
```

## หมายเหตุสำคัญ

### Security
- **HTTPS**: ปัจจุบันใช้ HTTP เท่านั้น สำหรับ production ควรเปิด HTTPS และติดตั้ง cert-manager
- **SSH Keys**: ตั้งค่า SSH Keys สำหรับ secure Git access
- **Firewall**: จำกัด access ไปยัง NodePort ports (30022, 30080, 30443)

### Performance  
- **Resource Monitoring**: ติดตาม CPU/Memory usage
- **Storage Growth**: ติดตาม storage usage และเพิ่มตามความจำเป็น
- **Network**: ใช้ LoadBalancer หรือ Ingress สำหรับ production

### High Availability
- การตั้งค่าปัจจุบันเป็น single-node deployment
- สำหรับ production ควรมี multiple replicas และ external databases

คุณสามารถ deploy GitLab แล้วเริ่มใช้งานได้เลย! ข้อมูลจะถูกเก็บใน persistent storage และไม่หายเมื่อ restart pods
