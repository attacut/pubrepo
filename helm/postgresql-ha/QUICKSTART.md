# Quick Start: PostgreSQL HA with Vault

ขั้นตอนการ deploy PostgreSQL HA ด้วย Vault integration แบบด่วน

## 🚀 Quick Deploy (5 นาที)

### 1. Setup Vault Secrets
```bash
cd helm/postgresql-ha

# ตั้งค่า Vault token
export VAULT_TOKEN=<your-vault-token>
export VAULT_ADDR=http://vault.vault.svc.cluster.local:8200

# รัน setup script
make vault-setup

# เก็บ passwords ที่แสดงออกมา!
```

### 2. Enable Vault Integration

แก้ไข `values.yaml` หรือใช้ `values-vault.yaml`:

```yaml
postgresql:
  vault:
    enabled: true
    path: "secret/data/postgresql-ha"
  existingSecret: "postgresql-ha-postgresql"

pgpool:
  vault:
    enabled: true
    path: "secret/data/pgpool"
  existingSecret: "postgresql-ha-pgpool"
```

### 3. Deploy ด้วย ArgoCD

```bash
# Apply ArgoCD application
make deploy-argocd

# หรือ manual
kubectl apply -f argocd-application.yaml

# ตรวจสอบ status
argocd app get postgresql-ha
argocd app sync postgresql-ha
```

### 4. ตรวจสอบ Deployment

```bash
# ดู status
make status

# ดู logs
make logs-postgresql
make logs-pgpool

# ทดสอบการเชื่อมต่อ
make test-connection
```

## 📋 Checklist

- [ ] Vault ติดตั้งและทำงานได้
- [ ] ArgoCD ติดตั้ง AVP plugin แล้ว
- [ ] Storage Class `nfs-client` พร้อมใช้งาน
- [ ] Namespace `database` สร้างแล้ว (หรือจะสร้างอัตโนมัติ)
- [ ] Vault secrets สร้างแล้ว
- [ ] ArgoCD Application deployed

## 🔍 Verification

### ตรวจสอบ Pods
```bash
kubectl get pods -n database
```

ควรเห็น:
- `postgresql-ha-postgresql-ha-0` (Ready 1/1)
- `postgresql-ha-postgresql-ha-1` (Ready 1/1)
- `postgresql-ha-postgresql-ha-2` (Ready 1/1)
- `postgresql-ha-postgresql-ha-pgpool-xxx` (Ready 1/1) x2

### ตรวจสอบ Secrets (จาก Vault)
```bash
kubectl get secret -n database
```

ควรเห็น:
- `postgresql-ha-postgresql` (จาก AVP)
- `postgresql-ha-pgpool` (จาก AVP)

### ทดสอบการเชื่อมต่อ
```bash
# Port forward
make port-forward

# จากเครื่องอื่น เชื่อมต่อ
psql -h localhost -p 5432 -U postgres -d postgres
```

## 🛠️ Useful Commands

```bash
# ดู passwords
make get-passwords

# Backup ทันที
make backup-now

# Scale up/down
make scale-up
make scale-down

# Port forward
make port-forward

# ดู logs
make logs-postgresql
make logs-pgpool

# Cleanup (⚠️ ลบข้อมูลทั้งหมด!)
make clean
```

## 📊 Connection Info

### Internal (ใน Kubernetes)
```
Host: postgresql-ha-pgpool.database.svc.cluster.local
Port: 5432
Username: postgres
Password: <from vault>
Database: <your-database>
```

### Connection String
```
postgresql://postgres:<password>@postgresql-ha-pgpool.database.svc.cluster.local:5432/<database>
```

## 🔐 Security Notes

1. ✅ Passwords เก็บใน Vault
2. ✅ Secrets inject ด้วย AVP
3. ✅ TLS/SSL enabled (optional)
4. ✅ Network Policy enabled
5. ✅ Pod Security Context configured

## 📈 High Availability Features

- ✅ **3 PostgreSQL replicas** (Sync Replication)
- ✅ **2 Pgpool replicas** (Load Balancer)
- ✅ **Automatic failover** (ด้วย Repmgr)
- ✅ **Daily backups** (Cron Job)
- ✅ **Pod Disruption Budgets** (PDB)

## 🐛 Troubleshooting

### Pods ไม่ขึ้น
```bash
# ดู events
kubectl describe pod -n database postgresql-ha-postgresql-ha-0

# ดู logs
kubectl logs -n database postgresql-ha-postgresql-ha-0

# ตรวจสอบ PVC
kubectl get pvc -n database
```

### AVP ไม่ทำงาน
```bash
# ตรวจสอบว่า secret มี annotation หรือไม่
kubectl get secret -n database postgresql-ha-postgresql -o yaml

# ควรเห็น:
# annotations:
#   avp.kubernetes.io/path: "secret/data/postgresql-ha"
```

### Vault Connection ล้มเหลว
```bash
# Test จาก pod
kubectl run vault-test --rm -it --image=vault:latest -- vault status

# ตรวจสอบ Vault service
kubectl get svc -n vault
```

## 📚 More Information

- [Full Documentation](VAULT_INTEGRATION.md)
- [Values Configuration](values-vault.yaml)
- [ArgoCD Application](argocd-application.yaml)

## 🆘 Support

หากมีปัญหา:
1. ตรวจสอบ logs: `make logs-postgresql`
2. ดู status: `make status`
3. Run `make help` เพื่อดู commands ทั้งหมด
