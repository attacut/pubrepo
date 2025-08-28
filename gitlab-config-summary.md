# GitLab Configuration Summary - Final Setup

## 🎯 Configuration Overview

### ✅ **Enabled Components** (Core GitLab Services)
| Service | Status | Purpose | Storage | Access |
|---------|--------|---------|---------|---------|
| **GitLab Core** | ✅ Enabled | Main application | Global PVC | NodePort 30080/30443 |
| **PostgreSQL** | ✅ `install: true` | Database | 8Gi PVC | Internal |
| **Redis** | ✅ `install: true` | Cache/Sessions | 8Gi PVC | Internal |
| **MinIO** | ✅ `enabled: true` | Object Storage | 10Gi PVC | Internal |
| **Gitaly** | ✅ Enabled | Git Repositories | 50Gi PVC | Internal |
| **GitLab Shell** | ✅ Enabled | SSH Access | - | NodePort 30022 |

### ❌ **Disabled Components** (Optional Features)
| Service | Status | Reason |
|---------|--------|---------|
| **GitLab Runner** | ❌ `install: false` | CI/CD - สามารถเปิดทีหลัง |
| **Prometheus** | ❌ `install: false` | Monitoring - ประหยัด resources |
| **Cert-Manager** | ❌ `installCertmanager: false` | SSL - ยังไม่ต้องใช้ |
| **Nginx Ingress** | ❌ `enabled: false` | Load Balancer - ใช้ NodePort |
| **GitLab Zoekt** | ❌ `install: false` | Code Search - feature เสริม |
| **OpenBao** | ❌ `install: false` | Secrets Management - ไม่จำเป็น |

## 🌐 Network Configuration

### Domain & HTTPS
```yaml
global:
  hosts:
    domain: gitlab.local      # แก้ไขใน /etc/hosts
    https: false             # ปิด HTTPS ไว้ก่อน
  ingress:
    enabled: false           # ใช้ NodePort แทน Ingress
    configureCertmanager: false
```

### NodePort Services
```yaml
gitlab:
  webservice:
    service:
      type: NodePort
      nodePort:
        http: 30080         # Web HTTP Access
        https: 30443        # Web HTTPS Access
  gitlab-shell:
    service:
      type: NodePort
      nodePort: 30022       # SSH Git Access
```

## 💾 Storage Configuration

### Global Storage Class
```yaml
global:
  storageClass: "nfs-client"
```

### Per-Service Storage
```yaml
# PostgreSQL Database
postgresql:
  primary:
    persistence:
      storageClass: "nfs-client"
      size: 8Gi

# Redis Cache  
redis:
  master:
    persistence:
      storageClass: "nfs-client" 
      size: 8Gi

# MinIO Object Storage
global:
  minio:
    persistence:
      storageClass: "nfs-client"
      size: 10Gi

# Gitaly Git Repositories
gitlab:
  gitaly:
    persistence:
      storageClass: "nfs-client"
      size: 50Gi
```

## 📦 Expected Resources After Deployment

### Pods (หลัก)
```bash
kubectl get pods -n gitlab

# Expected main pods:
# gitlab-gitaly-0
# gitlab-postgresql-0  
# gitlab-redis-master-0
# gitlab-webservice-default-xxx
# gitlab-sidekiq-all-in-1-v2-xxx
# gitlab-toolbox-xxx
```

### Services
```bash
kubectl get svc -n gitlab

# Expected NodePort services:
# gitlab-webservice-default    NodePort   30080:xxx, 30443:xxx
# gitlab-gitlab-shell          NodePort   30022:xxx
```

### Persistent Volume Claims
```bash
kubectl get pvc -n gitlab

# Expected PVCs:
# data-gitlab-postgresql-0          8Gi     nfs-client
# redis-data-gitlab-redis-master-0  8Gi     nfs-client
# gitlab-minio                      10Gi    nfs-client  
# repo-data-gitlab-gitaly-0         50Gi    nfs-client
```

## 🚀 Deployment Commands

### Quick Deploy
```bash
# Navigate to project
cd /Users/noppasinsritongkul/Desktop/GIT/pubrepo

# Deploy GitLab
helm install gitlab ./helm/gitlab -n gitlab --create-namespace

# Monitor deployment (takes 10-15 minutes)
kubectl get pods -n gitlab -w
```

### Post-Deploy Setup
```bash
# 1. Get initial root password
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath='{.data.password}' | base64 --decode

# 2. Get Node IP
kubectl get nodes -o wide

# 3. Add to /etc/hosts
echo "<NODE-IP> gitlab.local" >> /etc/hosts

# 4. Access GitLab
open http://gitlab.local:30080
```

## 🔧 Common Operations

### Check Storage Usage
```bash
# PostgreSQL storage
kubectl exec -it gitlab-postgresql-0 -n gitlab -- df -h /bitnami/postgresql

# Gitaly repositories
kubectl exec -it gitlab-gitaly-0 -n gitlab -- df -h /home/git

# MinIO object storage  
kubectl exec -it gitlab-minio-xxx -n gitlab -- df -h /export
```

### Test Data Persistence
```bash
# Create a project in GitLab web interface
# Add some data, then restart pods:

kubectl delete pod gitlab-postgresql-0 -n gitlab
kubectl delete pod gitlab-gitaly-0 -n gitlab

# Wait for pods to restart, then verify data is still there
```

### Scale Services
```bash
# Scale down to save resources
kubectl scale deployment gitlab-sidekiq-all-in-1-v2 --replicas=1 -n gitlab

# Scale up for more performance
kubectl scale deployment gitlab-webservice-default --replicas=2 -n gitlab
```

## 🔐 Security Notes

### Current Security Posture
- ✅ **Data Persistence**: All data stored in persistent volumes
- ✅ **Network Isolation**: Services internal to cluster
- ⚠️ **HTTP Only**: No HTTPS/SSL configured yet
- ⚠️ **NodePort Exposure**: Services exposed on specific ports
- ⚠️ **Default Secrets**: Using auto-generated secrets

### Recommended Security Improvements (For Production)
1. **Enable HTTPS**: Install cert-manager and configure TLS
2. **Use LoadBalancer**: Instead of NodePort for better security
3. **External Secrets**: Use Kubernetes secrets management
4. **Network Policies**: Restrict pod-to-pod communication
5. **Regular Backups**: Implement automated backup strategy

## 📊 Resource Requirements

### Minimum Requirements
- **CPU**: 4 cores
- **Memory**: 8GB RAM  
- **Storage**: 100GB+ (for NFS backing store)
- **Network**: Stable connectivity

### Storage Breakdown
- PostgreSQL: 8GB (will grow with usage)
- Redis: 8GB (mostly cache, relatively stable)
- MinIO: 10GB (will grow with uploads/artifacts)
- Gitaly: 50GB (will grow with git repositories)
- **Total**: ~76GB initial + growth

## 🎯 Next Steps After Deployment

1. **Verify Access**: Test web and SSH access
2. **Create Admin User**: Set up additional admin accounts
3. **Configure Git**: Set up SSH keys for developers
4. **Create Projects**: Start using GitLab for code management
5. **Monitor Resources**: Watch CPU/Memory/Storage usage
6. **Plan Scaling**: Consider when to add more resources
7. **Backup Strategy**: Set up regular data backups

## 🆘 Quick Troubleshooting

### Pod Issues
```bash
# Pod not starting
kubectl describe pod <pod-name> -n gitlab
kubectl logs <pod-name> -n gitlab

# Storage issues
kubectl get events -n gitlab | grep -i error
kubectl describe pvc -n gitlab
```

### Access Issues  
```bash
# Test NodePort connectivity
telnet gitlab.local 30080
curl -I http://gitlab.local:30080

# Check DNS/hosts file
ping gitlab.local
nslookup gitlab.local
```

Configuration ของคุณพร้อมใช้งานแล้ว! 🎉
