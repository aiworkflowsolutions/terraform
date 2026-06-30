# Terraform - Harness & GitHub Repo Automation

Automates client onboarding by creating GitHub repos and importing Harness CI/CD pipelines into dedicated Harness projects.

---

## How it works

For each new client, you define their repos in `config.auto.tfvars`. Terraform:
1. Creates a **Harness project** for the client
2. Creates **GitHub repos** from templates
3. Pushes **`.harness/` config files** into each repo
4. Imports **pipelines, input sets, and PR triggers** into Harness

---

## Quick start

### 1. Configure `config.auto.tfvars`

```hcl
github_token = "ghp_your_token_here"

harness_platform_api_key = "pat.KL30gt_VQXSrCQmCJxVnuw.your_pat_here"

repositories = [
  {
    repoName          = "hairstudio-fe"
    repoType          = "fe"
    projectName       = "hairstudio"
    orgIdentifier     = "default"
    projectIdentifier = "Hairstudio"
    isTemplateRepo    = false
    env               = ["dev", "stg", "prd"]
  },
  {
    repoName          = "hairstudio-be"
    repoType          = "be"
    projectName       = "hairstudio"
    orgIdentifier     = "default"
    projectIdentifier = "Hairstudio"
    isTemplateRepo    = false
    env               = ["dev", "stg", "prd"]
  },
  {
    repoName          = "helm-chart-hairstudio"
    repoType          = "helm"
    projectName       = "hairstudio"
    orgIdentifier     = "default"
    projectIdentifier = "Hairstudio"
    isTemplateRepo    = false
    env               = []
  },
  {
    repoName          = "postgres-helm"
    repoType          = "postgres"
    projectName       = "hairstudio"
    orgIdentifier     = "default"
    projectIdentifier = "Hairstudio"
    isTemplateRepo    = false
    env               = []
  },
  {
    repoName          = "keycloak-helm"
    repoType          = "keycloak"
    projectName       = "hairstudio"
    orgIdentifier     = "default"
    projectIdentifier = "Hairstudio"
    isTemplateRepo    = false
    env               = []
  }
]
```

### 2. Run Terraform

```bash
cd Terraform-Harness
terraform init
terraform apply
```

---

## What gets created

### Repo types

| repoType | Template | `.harness/` files | Harness resources | Pipeline stages |
|----------|----------|:-----------------:|:-----------------:|-----------------|
| **fe** | `generic-repo-template` | pipeline.yaml, K8s.yaml, inputset.yaml, service.yaml | Pipeline + InputSet + PR Trigger | CI (Nexus) → Deploy |
| **be** | `generic-repo-template` | pipeline.yaml, K8s.yaml, inputset.yaml, service.yaml | Pipeline + InputSet + PR Trigger | CI (Nexus) → Deploy |
| **helm** | `generic-helm-chart-repo-template` | _(none)_ | _(none)_ | — |
| **postgres** | `helm-chart-postgres` | pipeline.yaml, K8s.yaml, inputset.yaml, service.yaml | Pipeline + InputSet + PR Trigger | Deploy only |
| **keycloak** | `helm-chart-keycloak` | pipeline.yaml, K8s.yaml, inputset.yaml, service.yaml | Pipeline + InputSet + PR Trigger | Deploy only |

### Example: onboarding hairstudio

| Repo | Template | Purpose |
|------|----------|---------|
| `hairstudio-fe` | `generic-repo-template` | Frontend app pipeline |
| `hairstudio-be` | `generic-repo-template` | Backend app pipeline |
| `helm-chart-hairstudio` | `generic-helm-chart-repo-template` | Helm chart storage (no pipeline) |
| `postgres-helm` | `helm-chart-postgres` | Postgres infra pipeline |
| `keycloak-helm` | `helm-chart-keycloak` | Keycloak infra pipeline |

### Harness project

Each client gets their **own Harness project** (e.g. `Hairstudio`), auto-created by Terraform.

---

## How services link to helm charts

The `projectName` field drives the helm chart repo name in service definitions:

```yaml
# hairstudio-fe/.harness/service.yaml
repoName: helm-chart-hairstudio        # ← from projectName
folderPath: /helm-charts-hairstudio
valuesPaths:
  - manifests/hairstudio-fe/sit/immutable/values.yaml
```

```yaml
# postgres-helm/.harness/service.yaml
repoName: postgres-helm                # ← own repo name
folderPath: /postgres                  # ← chart subdirectory
valuesPaths: []                        # ← uses chart's built-in values.yaml
```

```yaml
# keycloak-helm/.harness/service.yaml
repoName: keycloak-helm                # ← own repo name
folderPath: ""                         # ← chart at root
valuesPaths: []                        # ← uses chart's built-in values.yaml
```

---

## Variables reference

| Variable | Required | Default | Description |
|----------|:--------:|---------|-------------|
| `repoName` | ✅ | — | GitHub repo name (e.g. `hairstudio-fe`) |
| `repoType` | ✅ | — | One of: `fe`, `be`, `helm`, `postgres`, `keycloak` |
| `orgIdentifier` | ✅ | — | Harness org (usually `default`) |
| `projectIdentifier` | ✅ | — | Harness project (e.g. `Hairstudio`) |
| `projectName` | ❌ | `repoName` | Shared project name for helm chart naming |
| `isTemplateRepo` | ✅ | — | Whether this is a template repo |
| `env` | ❌ | `[]` | Environment list (`dev`, `stg`, `prd`) |

### Config file variables (in `config.auto.tfvars`)

| Variable | Description |
|----------|-------------|
| `github_token` | GitHub PAT with repo & template permissions |
| `harness_platform_api_key` | Harness PAT for API access |

---

## Prerequisites

### GitHub templates
These repos must exist in `github.com/aiworkflowsolutions/`:
- `generic-repo-template` — for fe, be repos
- `generic-helm-chart-repo-template` — for helm chart repos
- `helm-chart-postgres` — for postgres infra repos (set as template repo)
- `helm-chart-keycloak` — for keycloak infra repos (set as template repo)

### Harness account
- Account ID is configured in the `provider "harness"` block in `repos.tf`
- Generate a PAT at: Harness → Account Settings → Access Control → API Keys

### Per-client setup after onboarding
Each new repo created from `helm-chart-postgres` or `helm-chart-keycloak` needs:
1. Update `values.yaml` — search for `myproject` and replace with client name
2. Commit and push to the client's branch