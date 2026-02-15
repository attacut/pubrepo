#!/bin/bash
set -e

# PostgreSQL HA Vault Setup Script
# This script creates secrets in Vault for PostgreSQL HA deployment

VAULT_ADDR="${VAULT_ADDR:-http://vault.vault.svc.cluster.local:8200}"
VAULT_TOKEN="${VAULT_TOKEN}"

# Check if vault is available
if ! command -v vault &> /dev/null; then
    echo "Error: vault CLI is not installed"
    exit 1
fi

# Check if VAULT_TOKEN is set
if [ -z "$VAULT_TOKEN" ]; then
    echo "Error: VAULT_TOKEN environment variable is not set"
    echo "Usage: VAULT_TOKEN=<your-token> ./vault-setup.sh"
    exit 1
fi

echo "Setting up Vault secrets for PostgreSQL HA..."
echo "Vault Address: $VAULT_ADDR"

# Generate secure random passwords
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

POSTGRES_PASSWORD=$(generate_password)
POSTGRES_ADMIN_PASSWORD=$(generate_password)
REPMGR_PASSWORD=$(generate_password)
PGPOOL_ADMIN_PASSWORD=$(generate_password)
SR_CHECK_PASSWORD=$(generate_password)

echo ""
echo "Generated passwords (save these securely!):"
echo "==========================================="
echo "PostgreSQL Password:       $POSTGRES_PASSWORD"
echo "PostgreSQL Admin Password: $POSTGRES_ADMIN_PASSWORD"
echo "Repmgr Password:           $REPMGR_PASSWORD"
echo "Pgpool Admin Password:     $PGPOOL_ADMIN_PASSWORD"
echo "SR Check Password:         $SR_CHECK_PASSWORD"
echo "==========================================="
echo ""

# Create PostgreSQL secrets in Vault
echo "Creating PostgreSQL secrets in Vault..."
vault kv put secret/postgresql-ha \
  password="$POSTGRES_PASSWORD" \
  postgres-password="$POSTGRES_ADMIN_PASSWORD" \
  repmgr-password="$REPMGR_PASSWORD"

# Create Pgpool secrets in Vault
echo "Creating Pgpool secrets in Vault..."
vault kv put secret/pgpool \
  admin-password="$PGPOOL_ADMIN_PASSWORD" \
  sr-check-password="$SR_CHECK_PASSWORD"

echo ""
echo "✅ Vault secrets created successfully!"
echo ""
echo "Next steps:"
echo "1. Update your values.yaml to enable Vault integration:"
echo ""
echo "   postgresql:"
echo "     vault:"
echo "       enabled: true"
echo "       path: secret/data/postgresql-ha"
echo "     existingSecret: <release-name>-postgresql"
echo ""
echo "   pgpool:"
echo "     vault:"
echo "       enabled: true"
echo "       path: secret/data/pgpool"
echo "     existingSecret: <release-name>-pgpool"
echo ""
echo "2. Deploy using ArgoCD with AVP plugin enabled"
echo ""
