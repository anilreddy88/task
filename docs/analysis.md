# Design Analysis

## 1. Design Justification

### Infrastructure Choices

**GKE Autopilot over Standard GKE:**
GKE Autopilot was chosen because it eliminates node management overhead, enforces security best practices by default (no SSH to nodes, no privileged containers), and optimizes cost through per-pod billing. For a microservice like the User Profile service, Autopilot provides the right balance of simplicity and production readiness.

**Private VPC with Cloud NAT:**
All resources sit inside a private VPC with no public IPs. GKE nodes use Cloud NAT for outbound internet access (pulling images, external APIs) while remaining unreachable from the internet. This follows the principle of least exposure.

**Cloud SQL with Private IP Only:**
The PostgreSQL instance is accessible only through VPC peering via Private Service Access. No public IP is assigned, which eliminates an entire attack surface. The GKE pods connect to the database over the internal network without going through the internet.

**Modular Terraform Structure:**
Infrastructure is split into four modules (networking, gke, cloudsql, security) to allow independent development, testing, and reuse. Each module has clear inputs and outputs, making dependencies explicit.

### CI/CD Choices

**GitHub Actions with Workload Identity Federation:**
WIF eliminates the need for long-lived JSON service account keys. The CI/CD pipeline authenticates to GCP using short-lived OIDC tokens, which is more secure and easier to rotate than static credentials.

**Helm for Deployment Packaging:**
Helm was chosen over raw Kubernetes manifests because it provides templating, versioned releases, rollback capability, and environment-specific value overrides. The chart separates configuration (values.yaml) from templates, making it easy to deploy to different environments.

**Multi-stage Docker Build:**
The Dockerfile uses a multi-stage build to keep the final image small and secure. Build dependencies (pip, compilers) are not included in the production image. The application runs as a non-root user with Gunicorn as the production WSGI server.

## 2. Security (Workload Identity and Vault/Secret Manager Value)

### Workload Identity

Workload Identity federates Kubernetes Service Accounts (KSA) with GCP Service Accounts (GSA). This provides several advantages:

- **No key management** - pods authenticate to GCP services without mounting JSON keys
- **Automatic credential rotation** - tokens are short-lived and rotated automatically
- **Audit trail** - all access is logged through Cloud Audit Logs tied to the GSA
- **Granular access** - each workload can have its own GSA with specific IAM roles

In this project, the `user-profile-ksa` KSA is bound to `userprofile-workload-sa` GSA, which has only two roles:
- `roles/cloudsql.client` - connect to Cloud SQL instances
- `roles/secretmanager.secretAccessor` - read secrets from Secret Manager

### Secret Manager

Secret Manager is used instead of Kubernetes Secrets for the database connection string because:

- **Centralized management** - secrets are managed in one place across all environments
- **Versioning** - every change creates a new version with full history
- **Access control** - IAM policies control who can read/write secrets
- **Audit logging** - all secret access is logged in Cloud Audit Logs
- **No plaintext in manifests** - the secret value never appears in Helm charts, Kubernetes manifests, or CI/CD logs (masked with `::add-mask::`)

The CI/CD pipeline retrieves the secret at deploy time and injects it as an environment variable. The secret is masked in GitHub Actions logs to prevent accidental exposure.

### Least-Privilege IAM

The GSA is granted only the minimum roles necessary:

| Role | Purpose |
|------|---------|
| `roles/cloudsql.client` | Connect to Cloud SQL via private IP |
| `roles/secretmanager.secretAccessor` | Read DB connection string |
| `roles/iam.workloadIdentityUser` | Allow KSA to impersonate GSA |

No broad roles like `roles/editor` or `roles/owner` are used.

## 3. CI/CD Tooling (Challenges and Decisions)

### Pipeline Design

The pipeline is split into two jobs with a clear separation of concerns:

1. **build-and-push** - builds the Docker image and pushes to Artifact Registry. Runs on every push and PR for validation.
2. **deploy** - deploys to GKE using Helm. Runs only on the main branch to prevent accidental deployments from PRs.

### Key Decisions

**Artifact Registry over Container Registry:**
GCR is deprecated. Artifact Registry provides better access control, regional storage, and vulnerability scanning.

**Commit SHA as Image Tag:**
Each image is tagged with the git commit SHA for traceability. This creates a direct link between the deployed image and the source code, making debugging and rollbacks straightforward.

**Helm `--set` for Secrets:**
Database credentials are passed via `--set` at deploy time rather than being baked into values files. This keeps secrets out of version control and Kubernetes manifests.

### Challenges

- **Workload Identity Federation setup** requires careful coordination between the GitHub repo, GCP project, and IAM configurations. The WIF provider and service account must be pre-configured before the pipeline can run.
- **Private GKE cluster access** from GitHub Actions runners requires the master endpoint to be accessible. We keep `enable_private_endpoint = false` so the API server is reachable, but restrict access via master authorized networks.
- **Secret injection without exposure** requires using `::add-mask::` in GitHub Actions to prevent the secret from appearing in logs, and passing it through Helm `--set` to avoid it being stored in manifests.

## 4. Run Instructions for Validation

### Prerequisites

- GCP Project with billing enabled
- `gcloud` CLI installed and authenticated (`gcloud auth login`)
- Terraform >= 1.14 installed
- Helm >= 3.x installed
- `kubectl` installed

### Step 1: Configure Terraform Variables

```bash
cd terraform

# Edit terraform.tfvars with your project values
# At minimum, set:
#   project_id  = "your-gcp-project-id"
#   db_password = "a-secure-password"
```

### Step 2: Provision Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

This creates the VPC, GKE Autopilot cluster, Cloud SQL instance, service accounts, IAM bindings, and Secret Manager secret.

### Step 3: Configure kubectl

```bash
gcloud container clusters get-credentials userprofile-gke \
  --region us-central1 \
  --project your-gcp-project-id
```

### Step 4: Build and Push the Docker Image

```bash
# Create the Artifact Registry repository
gcloud artifacts repositories create userprofile-repo \
  --repository-format=docker \
  --location=us-central1

# Configure Docker auth
gcloud auth configure-docker us-central1-docker.pkg.dev

# Build and push
cd app
docker build -t us-central1-docker.pkg.dev/PROJECT_ID/userprofile-repo/user-profile:latest .
docker push us-central1-docker.pkg.dev/PROJECT_ID/userprofile-repo/user-profile:latest
```

### Step 5: Deploy with Helm

```bash
helm upgrade --install user-profile ./helm/user-profile \
  -f ./helm/user-profile/values.yaml \
  --set image.repository=us-central1-docker.pkg.dev/PROJECT_ID/userprofile-repo/user-profile \
  --set image.tag=latest \
  --set serviceAccount.annotations."iam\.gke\.io/gcp-service-account"=userprofile-workload-sa@PROJECT_ID.iam.gserviceaccount.com
```

### Step 6: Verify Deployment

```bash
# Check pod status
kubectl get pods -l app=user-profile

# Check service
kubectl get svc user-profile

# Test the endpoint (port-forward for local access)
kubectl port-forward svc/user-profile 8080:80
curl http://localhost:8080/
curl http://localhost:8080/health
```

### Step 7: Configure GitHub Actions (Optional)

Set the following secrets in your GitHub repository (Settings > Secrets and variables > Actions):

- `GCP_PROJECT_ID` - your GCP project ID
- `WIF_PROVIDER` - Workload Identity Federation provider resource name
- `WIF_SERVICE_ACCOUNT` - GCP service account email for CI/CD

Then enable the workflow from the Actions tab to allow automatic builds and deployments.

### Cleanup

```bash
# Remove Helm release
helm uninstall user-profile

# Destroy infrastructure
cd terraform
terraform destroy
```
