variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "project_id" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "terraform_state_bucket" {
  type    = string
  default = "terraform-state-bucket" # Replace with a globally unique name
}

variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 0
  description = "number of gke nodes"
}

variable "project_number" {
  default     = "192935960695"
  description = "project number"
}

variable "project" {
  description = "The GCP project ID"
  type        = string
  default     = "gtb-gcp9ba0325a" # Replace with your actual project ID
}

### Define a list of roiam members for iam_bindings
locals {
  iam_bindings = [
    {
      role  = "roles/redis.admin"
      email = google_service_account.redis_service_account.email
    },
    {
      role  = "roles/cloudsql.admin"
      email = google_service_account.cloud_sql_admin.email
    },
    {
      role  = "roles/cloudsql.client"
      email = google_service_account.cloud_sql_client.email
    },
    {
      role  = "roles/cloudsql.instanceUser"
      email = google_service_account.cloud_sql_instanceuser.email
    }
  ]
}


### Define a list of iam_service_accounts for iam_service_accounts
locals {
  iam_service_accounts = [
    {
      account_id   = "redis-service-account"
      display_name = "Redis Service Account"
    },
    {
      account_id   = "cloud-sql-admin"
      display_name = "Cloud SQL Admin Service Account"
    },
    {
      account_id   = "oidc-service-account"
      display_name = "OIDC Service Account"
    }
  ]
}