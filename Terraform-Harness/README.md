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

## Client onboarding

### 1. Create your config

```hcl
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
    createRepo        = false
    orgIdentifier     = "default"
    projectIdentifier = "Hairstudio"
    isTemplateRepo    = false
    env               = []
  },
  {
    repoName          = "keycloak-helm"
    repoType          = "keycloak"
    createRepo        = false
    orgIdentifier     = "default"
    projectIdentifier = "Hairstudio"
    isTemplateRepo    = false
    env               = []
  }
]
```

### 2. Run Terraform

```bash
terraform init
terraform apply
```

---

## What gets created

### Repo types

| repoType | `createRepo` | Template | `.harness/` files | Harness resources |
|----------|:------------:|----------|:-----------------:|:-----------------:|
| **fe** | `true` (default) | `generic-repo-template` | pipeline.yaml, K8s.yaml, inputset.yaml, service.yaml | Pipeline + InputSet + PR Trigger |
| **be** | `true` (default) | `generic-repo-template` | pipeline.yaml, K8s.yaml, inputset.yaml, service.yaml | Pipeline + InputSet + PR Trigger |
| **helm** | `true` (default) | `generic-helm-chart-repo-template` | _(none)_ | _(none)_ |
| **postgres** | `false` | _(repo exists)_ | _(none)_ | Pipeline + InputSet + PR Trigger |
| **keycloak** | `false` | _(repo exists)_ | _(none)_ | Pipeline + InputSet + PR Trigger |

### Example: onboarding hairstudio

| Repo | Created from | Purpose |
|------|-------------|---------|
| `hairstudio-fe` | `generic-repo-template` | Frontend app + Harness pipeline |
| `hairstudio-be` | `generic-repo-template` | Backend app + Harness pipeline |
| `helm-chart-hairstudio` | `generic-helm-chart-repo-template` | Helm chart repo (one per client) |
| `postgres-helm` | _(already exists)_ | Pipeline imported into client's Harness project |
| `keycloak-helm` | _(already exists)_ | Pipeline imported into client's Harness project |

### Harness project

Each client gets their **own Harness project** (e.g. `Hairstudio`) — fully isolated from other clients.

---

## Pipeline stages

**fe pipeline:** `CI (Nexus build & push Docker)` → `Deploy (K8s rolling deploy)`

**be pipeline:** `CI (Nexus build & push Docker)` → `Deploy (K8s rolling deploy)`

### Runtime variables (set when running a pipeline)

| Variable | Example | Description |
|----------|---------|-------------|
| `serviceRef` | `hairstudiofe` | Harness service to deploy |

---

## How services link to helm charts

The `projectName` field determines the helm chart repo referenced in the service definitions:

```yaml
# hairstudio-fe/.harness/service.yaml
repoName: helm-chart-hairstudio        # ← from projectName
folderPath: /helm-charts-hairstudio
valuesPaths:
  - manifests/hairstudio-fe/sit/immutable/values.yaml
```

```yaml
# hairstudio-be/.harness/service.yaml
repoName: helm-chart-hairstudio        # ← same repo
folderPath: /helm-charts-hairstudio
valuesPaths:
  - manifests/hairstudio-be/sit/immutable/values.yaml
```

---

## Variables reference

| Variable | Required | Default | Description |
|----------|:--------:|---------|-------------|
| `repoName` | ✅ | — | GitHub repo name (e.g. `hairstudio-fe`) |
| `repoType` | ✅ | — | One of: `fe`, `be`, `helm`, `postgres`, `keycloak` |
| `orgIdentifier` | ✅ | — | Harness org (usually `default`) |
| `projectIdentifier` | ✅ | — | Harness project (e.g. `Hairstudio`) |
| `projectName` | ❌ | `repoName` | Shared name used for helm chart repo |
| `createRepo` | ❌ | `true` | Set `false` for existing repos (postgres, keycloak) |
| `isTemplateRepo` | ✅ | — | Whether this is a template repo |
| `env` | ❌ | `[]` | Environment list (`dev`, `stg`, `prd`) |

---

## Prerequisites

- **GitHub token** with repo & template permissions in `config.auto.tfvars`:
  ```hcl
  github_token = "ghp_your_token_here"
  ```
- **Harness account** configured in the `provider "harness"` block in `repos.tf`
- **Existing repos** (postgres, keycloak) must already have `.harness/pipeline.yaml` and `.harness/inputset.yaml` committed
- **Template repos** must exist in the GitHub org:
  - `aiworkflowsolutions/generic-repo-template` (for fe, be repos)
  - `aiworkflowsolutions/generic-helm-chart-repo-template` (for helm repos)