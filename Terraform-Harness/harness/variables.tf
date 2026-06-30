# modules/github-repository-template/variables.tf

variable "github_token" {
  description = "Name of the new repository"
  type        = string
  default     = ""
}

variable "github_owner" {
  description = "Name of the new repository"
  type        = string
  default     = "aiworkflowsolutions"
}

variable "repo_description" {
  description = "Description of the new repository"
  type        = string
  default     = "Created from a template repository"
}

variable "harness_platform_api_key" {
  description = "Harness Platform API Key (PAT)"
  type        = string
  sensitive   = true
}

variable "repo_private" {
  description = "Whether the repository is private or public"
  type        = bool
  default     = false
}

variable "template_repoName" {
  description = "The name of the template repository"
  type        = string
  default     = "generic-repo-template"
}

variable "repositories" {
  description = "List of repositories to create, including name and type, along with project details"
  type = list(object({
    orgIdentifier     = string
    projectIdentifier = string
    repoIdentifier    = string
    repoName          = string
    projectName       = optional(string)
    createRepo        = optional(bool, true)
    Dockerfile        = optional(string)
    repoType          = string # e.g., "fe", "be", "postgres", "keycloak", "helm"
    env               = optional(list(string))
    alCode            = optional(string)
    isTemplateRepo    = bool
  }))

  default = [
    {
      repoName          = "example-fe"
      repoType          = "fe"
      projectName       = "example"
      orgIdentifier     = "default"
      projectIdentifier = "Example"
      repoIdentifier    = "examplefe"
      isTemplateRepo    = false
      env               = ["dev"]
    }
  ]
}
