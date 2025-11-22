# External Secrets Operator with Vault Kubernetes Auth

This implementation enables External Secrets Operator to authenticate with HashiCorp Vault using Kubernetes Service Account tokens instead of static tokens.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Kubernetes Cluster                                      │
│                                                         │
│  ┌──────────────────────────────────────────────┐       │
│  │ External Secrets Operator                    │       │
│  │ (ServiceAccount: external-secrets)           │       │
│  └────────────────┬─────────────────────────────┘       │
│                   │                                     │
│                   │ 1. Requests secret using            │
│                   │    ServiceAccount JWT token         │
│                   ▼                                     │
│  ┌──────────────────────────────────────────────┐       │
│  │ ClusterSecretStore                           │       │
│  │ - Server: vault.example.com                  │       │
│  │ - Auth: kubernetes                           │       │
│  │ - Mount: dev-kubernetes                      │       │
│  │ - Role: external-secrets                     │       │
│  └────────────────┬─────────────────────────────┘       │
└───────────────────┼─────────────────────────────────────┘
                    │
                    │ 2. Authenticates with JWT
                    ▼
┌─────────────────────────────────────────────────────────┐
│ HashiCorp Vault                                         │
│                                                         │
│  ┌──────────────────────────────────────────────┐       │
│  │ Kubernetes Auth Backend                      │       │
│  │ Path: dev-kubernetes                         │       │
│  │                                              │       │
│  │ Role: external-secrets                       │       │
│  │ - Bound SA: external-secrets                 │       │
│  │ - Bound NS: external-secrets                 │       │
│  │ - Policy: dev-external-secrets-policy        │       │
│  └────────────────┬─────────────────────────────┘       │
│                   │ 3. Returns Vault token              │
│                   ▼                                     │
│  ┌──────────────────────────────────────────────┐       │
│  │ KV Secrets Engine v2                         │       │
│  │ Path: kv/dev/*                               │       │
│  └──────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────┘
```

## Components Created

### 1. Terraform Module (`terraform-admin/modules/vault-kubernetes-auth/`)

Creates the following Vault resources:

- **Kubernetes Auth Backend**: Mounted at `{env}-kubernetes` (e.g., `dev-kubernetes`, `prod-kubernetes`)
- **Vault Policy**: `{env}-external-secrets-policy` - grants read access to `kv/{env}/data/*`
- **Kubernetes Role**: `external-secrets` - binds the external-secrets ServiceAccount to the policy

### 2. Ansible Template (`ansible/roles/deploy_helm_apps/templates/additional/external-secrets-cluster-store.yaml.j2`)

Creates Kubernetes resources:

- **ServiceAccount**: `external-secrets` in `external-secrets` namespace
- **ClusterSecretStore**: `vault-backend` - configures ESO to use Kubernetes auth with Vault

## Deployment Flow

1. **Terraform (terraform-admin)**:
   - Creates Vault Kubernetes auth backend
   - Creates policies and roles
   - Initial config with `disable_local_ca_jwt = true`

2. **Ansible Bootstrap**:
   - Deploys External Secrets Operator Helm chart
   - Creates ServiceAccount for ESO
   - Creates ClusterSecretStore with Kubernetes auth configuration

3. **Post-Bootstrap Configuration** (Manual):
   - Configure Vault Kubernetes auth with cluster details
   - Enable ESO to authenticate with Vault

## Post-Bootstrap Configuration

After the cluster is bootstrapped, you need to configure Vault to trust the Kubernetes cluster:

### Step 1: Get Kubernetes Cluster Information

```bash
# Set your environment
export ENV_NAME=dev  # or prod

# Get the Kubernetes API server address
kubectl cluster-info

# Get the service account JWT token
# For Kubernetes 1.24+ (recommended):
SA_JWT_TOKEN=$(kubectl create token external-secrets -n external-secrets --duration=87600h)

# For Kubernetes <1.24 (legacy clusters):
# SA_JWT_TOKEN=$(kubectl get secret -n external-secrets \
#   $(kubectl get sa external-secrets -n external-secrets -o jsonpath='{.secrets[0].name}') \
#   -o jsonpath='{.data.token}' | base64 --decode)
# Get the Kubernetes CA certificate
kubectl config view --raw --minify --flatten \
  -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode > k8s-ca.crt
```

### Step 2: Configure Vault Kubernetes Auth

The `kubernetes_host` is already configured by Terraform using the VIP from `kv/{env}/ip`. You only need to add the CA certificate and token reviewer JWT:

```bash
# Login to Vault
export VAULT_ADDR=https://your-vault-server.com
export ENV_NAME=dev  # or prod
vault login

# Get the VIP (already set by Terraform, just for verification)
KUBERNETES_HOST=$(vault kv get -field=vip kv/${ENV_NAME}/ip)
echo "Kubernetes API: https://${KUBERNETES_HOST}:6443"

# Update the config with CA cert and token reviewer JWT
vault write auth/${ENV_NAME}-kubernetes/config \
  token_reviewer_jwt="${SA_JWT_TOKEN}" \
  kubernetes_ca_cert=@k8s-ca.crt \
  disable_local_ca_jwt=false
```

**Note**: Terraform automatically sets `kubernetes_host` to `https://{VIP}:6443` by reading from `kv/{env}/ip` in Vault.

## Usage Example

Once configured, create an ExternalSecret to sync secrets from Vault:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: my-secret
  namespace: my-app
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
  target:
    name: my-secret
    creationPolicy: Owner
  data:
    - secretKey: database-password
      remoteRef:
        key: my-app
        property: db_password
```

This will read from `kv/dev/data/my-app` in Vault and create a Kubernetes Secret with the `database-password` key.

## Storing Secrets in Vault

```bash
# Store a secret in Vault
vault kv put kv/dev/my-app \
  db_password="super-secret-password" \
  api_key="another-secret"

# Verify the secret
vault kv get kv/dev/my-app
```

## Troubleshooting

### Check ESO Logs

```bash
kubectl logs -n external-secrets -l app.kubernetes.io/name=external-secrets
```

### Test Vault Authentication

```bash
# Get the service account token (Kubernetes 1.24+)
SA_TOKEN=$(kubectl create token external-secrets -n external-secrets --duration=87600h)

# Test login
vault write auth/${ENV_NAME}-kubernetes/login \
  role=external-secrets \
  jwt=${SA_TOKEN}
```

### Verify ClusterSecretStore Status

```bash
kubectl get clustersecretstore vault-backend -o yaml
```

## Environment Variables

The following environment variables are required in the GitHub Actions workflow:

- `VAULT_ADDR`: Vault server address (e.g., `https://vault.example.com`)
- `ENV_NAME`: Environment name (`dev` or `prod`)

These are already configured in `.github/workflows/terraform-ansible.yml`.

## Security Considerations

1. **No Static Tokens**: This implementation uses Kubernetes Service Account tokens which are automatically rotated
2. **Least Privilege**: The policy grants only read access to environment-specific paths
3. **Namespace Binding**: The role is bound to specific ServiceAccount and namespace
4. **Token TTL**: Tokens expire after 1 hour (configurable via `token_ttl`)

## References

- [External Secrets Operator - Vault Provider](https://external-secrets.io/latest/provider/hashicorp-vault/)
- [Vault Kubernetes Auth Method](https://developer.hashicorp.com/vault/docs/auth/kubernetes)
