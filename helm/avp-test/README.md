# AVP Test Helm Chart

Helm chart สำหรับทดสอบ ArgoCD Vault Plugin (AVP)

## การใช้งาน

### 1. เตรียม Vault Secrets

สร้าง secrets ใน Vault ที่ path: `secret/data/myapp`

```bash
vault kv put secret/myapp \
  username="admin" \
  password="supersecret" \
  database="mydb" \
  api-key="abc123xyz" \
  host="db.example.com" \
  port="5432"
```

### 2. สร้าง ArgoCD Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: avp-test
  namespace: argocd
spec:
  project: default
  source:
    repoURL: <your-repo-url>
    path: helm/avp-test
    targetRevision: HEAD
    helm:
      values: |
        vault:
          path: secret/data/myapp
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
  # Important: Enable AVP plugin
  plugin:
    name: argocd-vault-plugin
```

### 3. หรือใช้ annotation

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: avp-test
  namespace: argocd
  annotations:
    argocd.argoproj.io/config-management-plugin: argocd-vault-plugin
spec:
  # ... rest of the spec
```

## AVP Placeholder Syntax

Chart นี้ใช้ AVP placeholders 2 แบบ:

### 1. Annotation-based (แนะนำ)
```yaml
metadata:
  annotations:
    avp.kubernetes.io/path: "secret/data/myapp"
stringData:
  username: <username>
  password: <password>
```

### 2. Inline path syntax
```yaml
data:
  value: <path:secret/data/myapp#field>
```

## ตรวจสอบการทำงาน

```bash
# ดู logs ของ AVP sidecar
kubectl logs -n argocd deployment/argocd-repo-server -c argocd-vault-plugin

# ตรวจสอบ secret ที่ถูกสร้าง
kubectl get secret avp-test-secret -o yaml

# ดูค่าที่ถูก decode
kubectl get secret avp-test-secret -o jsonpath='{.data.username}' | base64 -d
```
