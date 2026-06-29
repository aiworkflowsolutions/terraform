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
    Dockerfile        = optional(string)
    repoType          = string # e.g., "fe", "be", "helm"
    env               = optional(list(string))
    alCode            = optional(string)
    isTemplateRepo    = bool
  }))

  default = [
    {
      orgIdentifier     = "default"
      projectIdentifier = "IDA"
      repoName          = "Ping"
      repoType          = "forgeopsextras"
      repoIdentifier    = "forgeopsextras"
      isTemplateRepo    = false
      env               = ["dev"]
    }   
  ]
}
