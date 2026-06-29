#terraform {
#  required_providers {
#    github = {
#      source = "integrations/github"
#      version = "6.3.1"
#    }
#  }
#}


terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = "0.34.2"
    }
  }
}


provider "github" {
  token = var.github_token
  owner = var.github_owner
}
