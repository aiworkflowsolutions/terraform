locals {

  repo_to_api = {
    for repo in var.repositories : repo.repoName => {
        repoName           = repo.repoName
        repoNameAsIs       = repo.repoName
        orgIdentifier      = repo.orgIdentifier
        projectIdentifier  = repo.projectIdentifier
        repoIdentifier     = replace(repo.repoName, "-", "")
        repoType           = repo.repoType
        Dockerfile         = repo.Dockerfile
        isTemplateRepo     = repo.isTemplateRepo
        env                = repo.env
    }
  }

  helm_repos = {
    for repo in var.repositories : repo.repoName => repo
    if repo.repoType == "helm"
  }

  # New repos (fe, be) — create repo + push .harness files + import pipeline
  new_repos = {
    for repo in var.repositories : repo.repoName => repo
    if contains(["fe", "be"], repo.repoType)
  }

  # Existing repos (postgres, keycloak) — import pipeline only, no repo creation
  existing_repos = {
    for repo in var.repositories : repo.repoName => repo
    if contains(["postgres", "keycloak"], repo.repoType)
  }

  repo_files = flatten([
    for repo in var.repositories : [
      for file in (
        repo.repoType == "fe" ? [
          {
            file     = ".harness/pipeline.yaml"
            template = "${path.module}/fe/pipeline.yaml"
            filename = "pipeline.yaml"
          },
          {
            file     = ".harness/K8s.yaml"
            template = "${path.module}/fe/K8s.yaml"
            filename = "K8s.yaml"
          },
          {
            file     = ".harness/inputset.yaml"
            template = "${path.module}/fe/inputset.yaml"
            filename = "inputset.yaml"
          },
          {
            file     = ".harness/service.yaml"
            template = "${path.module}/fe/service.yaml"
            filename = "service.yaml"
          }
        ] : (repo.repoType == "be" ? [
          {
            file     = ".harness/pipeline.yaml"
            template = "${path.module}/be/pipeline.yaml"
            filename = "pipeline.yaml"
          },
          {
            file     = ".harness/K8s.yaml"
            template = "${path.module}/be/K8s.yaml"
            filename = "K8s.yaml"
          },
          {
            file     = ".harness/inputset.yaml"
            template = "${path.module}/be/inputset.yaml"
            filename = "inputset.yaml"
          },
          {
            file     = ".harness/service.yaml"
            template = "${path.module}/be/service.yaml"
            filename = "service.yaml"
          }
        ] : [])
      ) : {
        repoName       = repo.repoName
        repoIdentifier = replace(repo.repoName, "-", "")
        repoType       = repo.repoType
        orgIdentifier  = repo.orgIdentifier
        projectIdentifier = repo.projectIdentifier
        file           = file.file
        template       = file.template
        filename       = file.filename
      }
      if repo.createRepo
    ]
  ])
}

resource "time_sleep" "wait_for_repo_creation" {
  depends_on = [
    github_repository_file.repo_files
  ]
  create_duration = "15s"
}

resource "github_repository" "new_repo" {
  for_each = {
    for repo in var.repositories : "${repo.orgIdentifier}-${repo.projectIdentifier}-${repo.repoName}" => repo
    if repo.createRepo
  }

  name        = each.value.repoName
  description = var.repo_description

  template {
    owner      = var.github_owner
    repository = each.value.repoType == "helm" ? "generic-helm-chart-repo-template" : "generic-repo-template"
  }
}

resource "github_repository_file" "repo_files" {
  for_each = {
    for file in local.repo_files :
    "${file.orgIdentifier}-${file.projectIdentifier}-${file.repoName}-${file.filename}" => file
  }

  repository = github_repository.new_repo["${each.value.orgIdentifier}-${each.value.projectIdentifier}-${each.value.repoName}"].name
  branch     = "main"
  overwrite_on_create = true
  file       = each.value.file
  content = templatefile(each.value.template, {
    repoName           = each.value.repoName
    pipelineName       = each.value.repoName
    pipelineIdentifier = each.value.repoIdentifier
    projectName        = each.value.projectName != null ? each.value.projectName : each.value.repoName
    Dockerfile         = ""
    projectIdentifier  = each.value.projectIdentifier
    orgIdentifier      = each.value.orgIdentifier
  })

  commit_message = "Add ${each.value.filename} to .harness/ for ${each.value.repoName}"

  depends_on = [github_repository.new_repo]
}

# ─── Harness resources ───────────────────────────────────────────────────────

provider "harness" {
  endpoint         = "https://app.harness.io/gateway"
  account_id       = "7QVp4k5TQ0qKIPNSh1DkyA"
  platform_api_key = "pat.7QVp4k5TQ0qKIPNSh1DkyA.6711f76713b2902b6f314faa.zk3QAiIQXsBITlQ8gPff "
}

# Auto-create a Harness project for each unique projectIdentifier
locals {
  projects = distinct([
    for repo in var.repositories : {
      org_id      = repo.orgIdentifier
      project_id  = repo.projectIdentifier
      project_name = repo.projectName != null ? repo.projectName : repo.projectIdentifier
    }
  ])
}

resource "harness_platform_project" "project" {
  for_each = {
    for proj in local.projects : "${proj.org_id}-${proj.project_id}" => proj
  }

  identifier = each.value.project_id
  name       = each.value.project_name
  org_id     = each.value.org_id
  color      = "#0063F7"
}

# New repos (fe, be) — pipeline import depends on repo creation
resource "harness_platform_pipeline" "pipeline" {
  for_each   = local.new_repos
  depends_on = [github_repository_file.repo_files, time_sleep.wait_for_repo_creation, harness_platform_project.project]

  identifier      = replace(each.value.repoName, "-", "")
  org_id          = each.value.orgIdentifier
  project_id      = each.value.projectIdentifier
  name            = each.value.repoName
  import_from_git = true

  git_import_info {
    branch_name   = "main"
    file_path     = ".harness/pipeline.yaml"
    connector_ref = "account.Github"
    repo_name     = each.value.repoName
  }

  pipeline_import_request {
    pipeline_name        = each.value.repoName
    pipeline_description = "This pipeline is auto-created for ${each.value.repoName}."
  }
}

# Existing repos (postgres, keycloak) — import pipeline without repo creation
resource "harness_platform_pipeline" "existing_pipeline" {
  for_each = local.existing_repos
  depends_on = [harness_platform_project.project]

  identifier      = replace(each.value.repoName, "-", "")
  org_id          = each.value.orgIdentifier
  project_id      = each.value.projectIdentifier
  name            = each.value.repoName
  import_from_git = true

  git_import_info {
    branch_name   = "main"
    file_path     = ".harness/pipeline.yaml"
    connector_ref = "account.Github"
    repo_name     = each.value.repoName
  }

  pipeline_import_request {
    pipeline_name        = each.value.repoName
    pipeline_description = "Pipeline for ${each.value.repoName}."
  }
}

resource "harness_platform_input_set" "inputset" {
  for_each   = local.new_repos
  depends_on = [harness_platform_pipeline.pipeline]

  identifier      = replace(each.value.repoName, "-", "")
  org_id          = each.value.orgIdentifier
  project_id      = each.value.projectIdentifier
  name            = each.value.repoName
  pipeline_id     = each.value.repoName
  import_from_git = true

  git_import_info {
    branch_name   = "main"
    file_path     = ".harness/inputset.yaml"
    connector_ref = "account.Github"
    repo_name     = each.value.repoName
  }

  input_set_import_request {
    input_set_name        = each.value.repoName
    input_set_description = ""
  }
}

resource "harness_platform_input_set" "existing_inputset" {
  for_each   = local.existing_repos
  depends_on = [harness_platform_pipeline.existing_pipeline]

  identifier      = replace(each.value.repoName, "-", "")
  org_id          = each.value.orgIdentifier
  project_id      = each.value.projectIdentifier
  name            = each.value.repoName
  pipeline_id     = each.value.repoName
  import_from_git = true

  git_import_info {
    branch_name   = "main"
    file_path     = ".harness/inputset.yaml"
    connector_ref = "account.Github"
    repo_name     = each.value.repoName
  }

  input_set_import_request {
    input_set_name        = each.value.repoName
    input_set_description = ""
  }
}

resource "harness_platform_triggers" "triggers" {
  for_each   = local.new_repos
  depends_on = [harness_platform_input_set.inputset]

  identifier  = "${replace(each.value.repoName, "-", "")}trigger"
  org_id      = each.value.orgIdentifier
  project_id  = each.value.projectIdentifier
  name        = "${each.value.repoName}-trigger"
  target_id   = each.value.repoName
  yaml        = <<-EOT
  trigger:
    name: ${each.value.repoName}-trigger
    identifier: ${replace(each.value.repoName, "-", "")}trigger
    enabled: true
    description: ""
    tags: {}
    projectIdentifier: ${each.value.projectIdentifier}
    orgIdentifier: ${each.value.orgIdentifier}
    pipelineIdentifier: ${each.value.repoName}
    source:
      type: Webhook
      spec:
        type: Github
        spec:
          type: PullRequest
          spec:
            connectorRef: account.Github
            autoAbortPreviousExecutions: false
            payloadConditions: []
            headerConditions: []
            repoName: ${each.value.repoName}
            actions:
              - Open
              - Reopen
              - Edit
    pipelineBranchName: <+trigger.branch>
    inputSetRefs:
      - "${replace(each.value.repoName, "-", "")}pr"
    EOT
}

resource "harness_platform_triggers" "existing_triggers" {
  for_each   = local.existing_repos
  depends_on = [harness_platform_input_set.existing_inputset]

  identifier  = "${replace(each.value.repoName, "-", "")}trigger"
  org_id      = each.value.orgIdentifier
  project_id  = each.value.projectIdentifier
  name        = "${each.value.repoName}-trigger"
  target_id   = each.value.repoName
  yaml        = <<-EOT
  trigger:
    name: ${each.value.repoName}-trigger
    identifier: ${replace(each.value.repoName, "-", "")}trigger
    enabled: true
    description: ""
    tags: {}
    projectIdentifier: ${each.value.projectIdentifier}
    orgIdentifier: ${each.value.orgIdentifier}
    pipelineIdentifier: ${each.value.repoName}
    source:
      type: Webhook
      spec:
        type: Github
        spec:
          type: PullRequest
          spec:
            connectorRef: account.Github
            autoAbortPreviousExecutions: false
            payloadConditions: []
            headerConditions: []
            repoName: ${each.value.repoName}
            actions:
              - Open
              - Reopen
              - Edit
    pipelineBranchName: <+trigger.branch>
    inputSetRefs:
      - "${replace(each.value.repoName, "-", "")}pr"
    EOT
}

output "repository_urls" {
  value = [
    for repo in var.repositories :
    "https://github.com/${var.github_owner}/${repo.repoName}"
  ]
}