#!/bin/bash

# GitLab Runner Deployment Script
# Author: GitHub Copilot
# Date: $(date)

set -e

echo "🚀 GitLab Runner Deployment Script"
echo "=================================="

# Variables
NAMESPACE="gitlab-runner"
RUNNER_TOKEN=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_step() {
    echo -e "${GREEN}📋 $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
print_step "Checking prerequisites..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed or not in PATH"
    exit 1
fi

# Check if helm is available
if ! command -v helm &> /dev/null; then
    print_error "helm is not installed or not in PATH"
    exit 1
fi

print_step "Prerequisites check passed ✅"

# Get GitLab Runner Token
if [ -z "$RUNNER_TOKEN" ]; then
    echo ""
    print_warning "GitLab Runner Token is required!"
    echo "📋 How to get GitLab Runner Token:"
    echo "1. Go to your GitLab project/group"
    echo "2. Navigate to Settings → CI/CD → Runners"
    echo "3. Click 'New project runner' or 'New group runner'"
    echo "4. Configure and get the token (format: glrt-xxxxxxxxxxxxxxxxxxxx)"
    echo ""
    read -p "Enter your GitLab Runner Token: " RUNNER_TOKEN
    
    if [ -z "$RUNNER_TOKEN" ]; then
        print_error "Runner token is required to continue"
        exit 1
    fi
fi

# Create namespace
print_step "Creating namespace '$NAMESPACE'..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Create secret with runner token
print_step "Creating GitLab Runner secret..."
RUNNER_TOKEN_B64=$(echo -n "$RUNNER_TOKEN" | base64)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-runner-secret
  namespace: $NAMESPACE
type: Opaque
data:
  runner-token: $RUNNER_TOKEN_B64
  runner-registration-token: ""
EOF

# Add GitLab Helm repository
print_step "Adding GitLab Helm repository..."
helm repo add gitlab https://charts.gitlab.io
helm repo update

# Deploy GitLab Runner
print_step "Deploying GitLab Runner..."
helm upgrade --install gitlab-runner gitlab/gitlab-runner \
  --namespace $NAMESPACE \
  --values values.yaml \
  --set runners.secret=gitlab-runner-secret \
  --wait

# Check deployment status
print_step "Checking deployment status..."
kubectl get pods -n $NAMESPACE
kubectl get deployment -n $NAMESPACE

echo ""
print_step "✅ GitLab Runner deployed successfully!"
echo ""
echo "🔍 Useful commands:"
echo "  kubectl logs -f deployment/gitlab-runner -n $NAMESPACE"
echo "  kubectl get pods -n $NAMESPACE"
echo "  helm status gitlab-runner -n $NAMESPACE"
echo ""
echo "📝 Next steps:"
echo "1. Check runner logs for any errors"
echo "2. Verify runner appears in GitLab UI"
echo "3. Test with a simple CI/CD pipeline"
