# External Secrets Operator - Vault Integration

This guide explains how External Secrets Operator (ESO) authenticates with HashiCorp Vault using Kubernetes authentication to synchronize secrets into the cluster.

## Client JWT Mode

This implementation uses **Client JWT mode** as described in the [HashiCorp Vault documentation](https://developer.hashicorp.com/vault/docs/auth/kubernetes#use-the-vault-client-s-jwt-as-the-reviewer-jwt).

### Why Client JWT Mode?

- **Simpler setup**: No need to create a separate long-lived ServiceAccount token for Vault
- **Better security**: Uses the same JWT that the client (ESO) presents for authentication
- **Self-contained**: Vault uses the client's JWT for both authentication and TokenReview validation

### Configuration Requirements

For client JWT mode to work:

1. **Vault must have network access** to the Kubernetes API server (via VIP)
2. **`disable_local_ca_jwt: true`** must be set (since Vault is external to the cluster)
3. **ESO ServiceAccount must have `system:auth-delegator` permissions** to allow Vault to perform TokenReview API calls using the client's JWT
4. **No CA certificate upload required** - Vault uses the system's default CA bundle to verify the Kubernetes API server's TLS certificate

## Configuration Flow

### 1. Terraform Admin Setup (One-time configuration)

The `terraform-admin/modules/vault-kubernetes-auth/` module creates the complete Vault configuration:

```hcl
# Enable Kubernetes auth backend
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "${var.env}-kubernetes"  # e.g., dev-kubernetes
}

# Configure Kubernetes auth backend with client JWT mode
resource "vault_kubernetes_auth_backend_config" "kubernetes" {
  backend              = vault_auth_backend.kubernetes.path
  kubernetes_host      = "https://${VIP}:6443"
  disable_local_ca_jwt = true  # Use client JWT for both auth and TokenReview
  # Note: No kubernetes_ca_cert needed - Vault uses system CA bundle
}

# Policy for External Secrets Operator
resource "vault_policy" "external_secrets" {
  name   = "${var.env}-external-secrets-policy"
  policy = <<-EOT
    path "kv/${var.env}/data/*" {
      capabilities = ["read", "list"]
    }
    path "kv/${var.env}/metadata/*" {
      capabilities = ["list"]
    }
  EOT
}

# Role for External Secrets Operator
resource "vault_kubernetes_auth_backend_role" "external_secrets" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "external-secrets"
  bound_service_account_names      = ["external-secrets"]
  bound_service_account_namespaces = ["external-secrets"]
  token_policies                   = [vault_policy.external_secrets.name]
  token_ttl                        = 3600   # 1 hour
  token_max_ttl                    = 86400  # 24 hours
}
```

### 2. Ansible Deployment

The `ansible/roles/deploy_helm_apps/` role deploys:

#### RBAC Configuration (`external-secrets-rbac.yaml.j2`)

```yaml
# Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: external-secrets
---
# ServiceAccount
apiVersion: v1
kind: ServiceAccount
metadata:
  name: external-secrets
  namespace: external-secrets
---
# ClusterRoleBinding for TokenReview API access
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: external-secrets-auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator # Allows TokenReview API calls
subjects:
  - kind: ServiceAccount
    name: external-secrets
    namespace: external-secrets
```

#### ClusterSecretStore Configuration (`external-secrets-cluster-store.yaml.j2`)

```yaml
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "{{ vault_addr }}" # e.g., https://vault.example.com
      path: "kv/{{ env }}" # e.g., kv/dev
      version: "v2"
      auth:
        kubernetes:
          mountPath: "{{ env }}-kubernetes" # e.g., dev-kubernetes
          role: "external-secrets"
          serviceAccountRef:
            name: "external-secrets"
            namespace: "external-secrets"
```

### 3. Runtime Authentication

When ESO needs to fetch secrets:

1. **ESO reads its ServiceAccount JWT** from `/var/run/secrets/kubernetes.io/serviceaccount/token`
2. **ESO sends JWT to Vault** at `auth/{env}-kubernetes/login` with `role=external-secrets`
3. **Vault validates the JWT** by calling the Kubernetes TokenReview API using the **same client JWT**:
   ```
   POST https://{VIP}:6443/apis/authentication.k8s.io/v1/tokenreviews
   Authorization: Bearer <client-jwt>
   ```
4. **Kubernetes API validates** the JWT and returns the ServiceAccount identity
5. **Vault verifies** the ServiceAccount matches the role's bound accounts
6. **Vault issues a token** with the `{env}-external-secrets-policy` policy
7. **ESO uses the Vault token** to read secrets from `kv/{env}/data/*`

## Using External Secrets

After setup, create ExternalSecret resources to sync Vault secrets to Kubernetes:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: my-app-secrets
  namespace: my-app
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: vault-backend
  target:
    name: my-app-secrets
    creationPolicy: Owner
  data:
    - secretKey: database-password
      remoteRef:
        key: myapp # kv/{env}/data/myapp
        property: db_pass # Field in the secret
```

This will create a Kubernetes Secret named `my-app-secrets` in the `my-app` namespace with the data from Vault.

## Troubleshooting

### Check ESO Logs

```bash
kubectl logs -n external-secrets -l app.kubernetes.io/name=external-secrets
```

### Verify ServiceAccount Token

```bash
# Exec into ESO pod
kubectl exec -n external-secrets -it <pod-name> -- sh

# Check if SA token exists
cat /var/run/secrets/kubernetes.io/serviceaccount/token
```

### Test Vault Authentication

```bash
# Get SA token from pod
SA_TOKEN=$(kubectl exec -n external-secrets <pod-name> -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)

# Test Vault login
vault write auth/dev-kubernetes/login role=external-secrets jwt=$SA_TOKEN
```

### Verify ClusterSecretStore Status

```bash
kubectl get clustersecretstore vault-backend -o yaml
```

Look for the `status.conditions` field to see if the connection to Vault is healthy.

## References

- [HashiCorp Vault Kubernetes Auth - Client JWT Mode](https://developer.hashicorp.com/vault/docs/auth/kubernetes#use-the-vault-client-s-jwt-as-the-reviewer-jwt)
- [External Secrets Operator - Vault Provider](https://external-secrets.io/latest/provider/hashicorp-vault/)
- [Kubernetes TokenReview API](https://kubernetes.io/docs/reference/kubernetes-api/authentication-resources/token-review-v1/)
