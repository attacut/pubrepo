# PostgreSQL HA with Vault Integration

การใช้งาน HashiCorp Vault กับ PostgreSQL HA ผ่าน ArgoCD Vault Plugin (AVP)

## Prerequisites

- HashiCorp Vault ติดตั้งและใช้งานได้แล้ว
- ArgoCD พร้อม Vault Plugin ติดตั้งแล้ว
- Vault CLI ติดตั้งบนเครื่อง (สำหรับ setup)

## Setup Instructions

### 1. เตรียม Vault Secrets

รัน script เพื่อสร้าง secrets ใน Vault:

```bash
# Set Vault token
export VAULT_TOKEN=<your-vault-token>
export VAULT_ADDR=http://vault.vault.svc.cluster.local:8200

# Run setup script
cd helm/postgresql-ha
./vault-setup.sh
```

Script จะสร้าง secrets ที่ path:
- `secret/postgresql-ha` - สำหรับ PostgreSQL passwords
- `secret/pgpool` - สำหรับ Pgpool passwords

**บันทึก passwords ที่ script แสดง** เอาไว้ในที่ปลอดภัย!

### 2. Update values.yaml

แก้ไขไฟล์ `values.yaml` เพื่อเปิดใช้งาน Vault:

```yaml
postgresql:
  vault:
    enabled: true
    path: "secret/data/postgresql-ha"
  existingSecret: "postgresql-ha-postgresql"  # ใช้ชื่อตาม Release name

pgpool:
  vault:
    enabled: true
    path: "secret/data/pgpool"
  existingSecret: "postgresql-ha-pgpool"  # ใช้ชื่อตาม Release name
```

### 3. Deploy ผ่าน ArgoCD

สร้าง ArgoCD Application:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: postgresql-ha
  namespace: argocd
spec:
  project: default
  source:
    repoURL: <your-repo-url>
    path: helm/postgresql-ha
    targetRevision: HEAD
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: database
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

**สำคัญ:** ต้องเปิด AVP plugin ใน ArgoCD Server ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  configManagementPlugins: |
    - name: argocd-vault-plugin
      generate:
        command: ["argocd-vault-plugin"]
        args: ["generate", "./"]
```

### 4. Deploy ด้วย Helm (ถ้าไม่ใช้ ArgoCD)

ถ้าต้องการ deploy ด้วย Helm โดยตรง:

```bash
# ต้องสร้าง secrets manually ก่อน
kubectl create secret generic postgresql-ha-postgresql \
  --from-literal=password='<password-from-vault>' \
  --from-literal=postgres-password='<postgres-password-from-vault>' \
  --from-literal=repmgr-password='<repmgr-password-from-vault>' \
  -n database

kubectl create secret generic postgresql-ha-pgpool \
  --from-literal=admin-password='<admin-password-from-vault>' \
  --from-literal=sr-check-password='<sr-check-password-from-vault>' \
  -n database

# แล้ว deploy ด้วย Helm
helm install postgresql-ha . \
  --namespace database \
  --create-namespace \
  -f values.yaml
```

## Vault Secrets Structure

### PostgreSQL Secret (`secret/postgresql-ha`)

```json
{
  "password": "xxxxxxxxxx",
  "postgres-password": "xxxxxxxxxx",
  "repmgr-password": "xxxxxxxxxx"
}
```

### Pgpool Secret (`secret/pgpool`)

```json
{
  "admin-password": "xxxxxxxxxx",
  "sr-check-password": "xxxxxxxxxx"
}
```

## การ Rotate Passwords

เมื่อต้องการเปลี่ยน password:

1. อัพเดท secrets ใน Vault:
```bash
vault kv put secret/postgresql-ha \
  password="new-password" \
  postgres-password="new-postgres-password" \
  repmgr-password="new-repmgr-password"
```

2. Refresh ArgoCD Application หรือ restart pods:
```bash
# ถ้าใช้ ArgoCD
argocd app sync postgresql-ha

# หรือ restart pods
kubectl rollout restart statefulset -n database
kubectl rollout restart deployment -n database
```

## Troubleshooting

### ตรวจสอบว่า AVP ทำงานหรือไม่

```bash
# ดู annotations ของ secret
kubectl get secret postgresql-ha-postgresql -o yaml -n database

# ดูว่ามี annotation avp.kubernetes.io/path หรือไม่
```

### ตรวจสอบ Vault connectivity

```bash
# จาก pod ใน cluster
kubectl run vault-test --rm -it --image=vault:latest -- /bin/sh
vault login <token>
vault kv get secret/postgresql-ha
```

### ดู logs ของ ArgoCD

```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server -f
```

## Security Best Practices

1. ✅ ใช้ Vault Policy เพื่อ limit การเข้าถึง secrets
2. ✅ ใช้ Kubernetes Service Account เพื่อ authenticate กับ Vault
3. ✅ Enable audit logging ใน Vault
4. ✅ Rotate passwords เป็นประจำ
5. ✅ ใช้ namespace ที่แยกกันสำหรับ database

## Example Vault Policy

```hcl
# postgresql-ha-policy.hcl
path "secret/data/postgresql-ha" {
  capabilities = ["read"]
}

path "secret/data/pgpool" {
  capabilities = ["read"]
}
```

Apply policy:
```bash
vault policy write postgresql-ha postgresql-ha-policy.hcl
```

## References

- [ArgoCD Vault Plugin](https://argocd-vault-plugin.readthedocs.io/)
- [HashiCorp Vault](https://www.vaultproject.io/)
- [PostgreSQL HA Helm Chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql-ha)
