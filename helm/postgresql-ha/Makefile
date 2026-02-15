.PHONY: help vault-setup vault-check deploy-argocd test-connection clean

RELEASE_NAME ?= postgresql-ha
NAMESPACE ?= database
VAULT_ADDR ?= http://vault.vault.svc.cluster.local:8200

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

vault-setup: ## Setup Vault secrets
	@echo "Setting up Vault secrets..."
	@if [ -z "$$VAULT_TOKEN" ]; then \
		echo "Error: VAULT_TOKEN is not set"; \
		echo "Usage: VAULT_TOKEN=<token> make vault-setup"; \
		exit 1; \
	fi
	@./vault-setup.sh

vault-check: ## Check Vault connectivity and secrets
	@echo "Checking Vault connection..."
	@vault status
	@echo ""
	@echo "Checking PostgreSQL secrets..."
	@vault kv get secret/postgresql-ha || echo "❌ PostgreSQL secrets not found"
	@echo ""
	@echo "Checking Pgpool secrets..."
	@vault kv get secret/pgpool || echo "❌ Pgpool secrets not found"

deploy-argocd: ## Deploy using ArgoCD
	@echo "Deploying PostgreSQL HA via ArgoCD..."
	@kubectl apply -f argocd-application.yaml
	@echo "✅ ArgoCD Application created"
	@echo "Monitor deployment: argocd app get postgresql-ha"

deploy-helm: ## Deploy using Helm directly (for testing)
	@echo "Deploying PostgreSQL HA with Helm..."
	@helm upgrade --install $(RELEASE_NAME) . \
		--namespace $(NAMESPACE) \
		--create-namespace \
		-f values-vault.yaml
	@echo "✅ Deployment complete"

template: ## Generate Kubernetes manifests (for testing)
	@helm template $(RELEASE_NAME) . \
		-f values-vault.yaml \
		--namespace $(NAMESPACE)

test-connection: ## Test PostgreSQL connection
	@echo "Testing PostgreSQL connection..."
	@kubectl run postgresql-client --rm --tty -i --restart='Never' \
		--namespace $(NAMESPACE) \
		--image docker.io/bitnami/postgresql:16 \
		--env="PGPASSWORD=$$(kubectl get secret -n $(NAMESPACE) $(RELEASE_NAME)-postgresql -o jsonpath='{.data.password}' | base64 -d)" \
		--command -- psql --host $(RELEASE_NAME)-pgpool.$(NAMESPACE).svc.cluster.local -U postgres -d postgres -p 5432

status: ## Check deployment status
	@echo "PostgreSQL StatefulSet:"
	@kubectl get statefulset -n $(NAMESPACE) -l app.kubernetes.io/name=postgresql-ha
	@echo ""
	@echo "Pgpool Deployment:"
	@kubectl get deployment -n $(NAMESPACE) -l app.kubernetes.io/component=pgpool
	@echo ""
	@echo "Services:"
	@kubectl get svc -n $(NAMESPACE) -l app.kubernetes.io/name=postgresql-ha
	@echo ""
	@echo "PVCs:"
	@kubectl get pvc -n $(NAMESPACE) -l app.kubernetes.io/name=postgresql-ha

logs-postgresql: ## Show PostgreSQL logs
	@kubectl logs -n $(NAMESPACE) -l app.kubernetes.io/component=postgresql --tail=100 -f

logs-pgpool: ## Show Pgpool logs
	@kubectl logs -n $(NAMESPACE) -l app.kubernetes.io/component=pgpool --tail=100 -f

port-forward: ## Port forward to PostgreSQL
	@echo "Forwarding port 5432..."
	@kubectl port-forward -n $(NAMESPACE) svc/$(RELEASE_NAME)-pgpool 5432:5432

get-passwords: ## Get passwords from Kubernetes secrets
	@echo "PostgreSQL Passwords:"
	@echo "===================="
	@echo "postgres password: $$(kubectl get secret -n $(NAMESPACE) $(RELEASE_NAME)-postgresql -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || echo 'N/A')"
	@echo "postgres-password: $$(kubectl get secret -n $(NAMESPACE) $(RELEASE_NAME)-postgresql -o jsonpath='{.data.postgres-password}' 2>/dev/null | base64 -d || echo 'N/A')"
	@echo "repmgr-password:   $$(kubectl get secret -n $(NAMESPACE) $(RELEASE_NAME)-postgresql -o jsonpath='{.data.repmgr-password}' 2>/dev/null | base64 -d || echo 'N/A')"
	@echo ""
	@echo "Pgpool Passwords:"
	@echo "================="
	@echo "admin-password:    $$(kubectl get secret -n $(NAMESPACE) $(RELEASE_NAME)-pgpool -o jsonpath='{.data.admin-password}' 2>/dev/null | base64 -d || echo 'N/A')"
	@echo "sr-check-password: $$(kubectl get secret -n $(NAMESPACE) $(RELEASE_NAME)-pgpool -o jsonpath='{.data.sr-check-password}' 2>/dev/null | base64 -d || echo 'N/A')"

clean: ## Delete deployment
	@echo "⚠️  This will delete all PostgreSQL data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		helm uninstall $(RELEASE_NAME) -n $(NAMESPACE) || true; \
		kubectl delete pvc -n $(NAMESPACE) -l app.kubernetes.io/name=postgresql-ha || true; \
		echo "✅ Cleanup complete"; \
	else \
		echo "Cancelled"; \
	fi

backup-now: ## Trigger backup job manually
	@echo "Creating manual backup job..."
	@kubectl create job -n $(NAMESPACE) --from=cronjob/$(RELEASE_NAME)-postgresql-ha-backup manual-backup-$$(date +%s)
	@echo "✅ Backup job created"
	@echo "Monitor: kubectl logs -n $(NAMESPACE) -l job-name=manual-backup-* -f"

scale-up: ## Scale up PostgreSQL replicas
	@kubectl scale statefulset -n $(NAMESPACE) $(RELEASE_NAME)-postgresql-ha --replicas=5
	@echo "✅ Scaled to 5 replicas"

scale-down: ## Scale down PostgreSQL replicas
	@kubectl scale statefulset -n $(NAMESPACE) $(RELEASE_NAME)-postgresql-ha --replicas=3
	@echo "✅ Scaled to 3 replicas"
