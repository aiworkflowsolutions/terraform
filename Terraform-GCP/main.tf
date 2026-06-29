resource "google_project" "project" {
  name            = var.project_name
  project_id      = random_id.id.hex
  billing_account = var.billing_account
  lifecycle {
    ignore_changes = [project_id]
  }
}


resource "time_sleep" "wait_60s" {
  depends_on      = [google_project_service.enable_apis]
  create_duration = "60s"
}


resource "random_id" "id" {
  byte_length = 4
  prefix      = var.project_name
}



resource "google_project_service" "enable_apis" {
  for_each = toset(local.project_apis)
  service  = each.value
  project  = var.project_id
  lifecycle {
    ignore_changes = [disable_on_destroy]
  }
}
# This Terraform configuration sets up a GCP project with various services enabled,
locals {
  project_apis = [
    "servicenetworking.googleapis.com", # Service Networking API
    "firestore.googleapis.com",         # Firestore API
    "sqladmin.googleapis.com",
    "iamcredentials.googleapis.com",
    "sqladmin.googleapis.com",             # Cloud SQL Admin API
    "redis.googleapis.com",                # Redis API
    "container.googleapis.com",            # Kubernetes Engine API
    "compute.googleapis.com",              # Compute Engine API
    "iam.googleapis.com",                  # IAM API
    "cloudresourcemanager.googleapis.com", # Cloud Resource Manager API
    "monitoring.googleapis.com",           # Cloud Monitoring API
    "logging.googleapis.com",              # Cloud Logging API
    "billingbudgets.googleapis.com",       # Cloud Billing Budgets API
    "serviceusage.googleapis.com"          # Service Usage API
  ]
}

resource "google_service_account" "redis_service_account" {
  account_id   = "redis-service-account"
  display_name = "Redis Service Account"
  project      = var.project_id

  lifecycle {
    ignore_changes = [account_id, display_name]
  }
}

resource "google_service_account" "cloud_sql_admin" {
  account_id   = "cloud-sql-admin"
  display_name = "Cloud SQL Admin Service Account"
  project      = var.project_id
  lifecycle {
    ignore_changes = [account_id, display_name]
  }
}

resource "google_service_account" "cloud_sql_client" {
  account_id   = "cloud-sql-client"
  display_name = "Cloud SQL client Service Account"
  project      = var.project_id
  lifecycle {
    ignore_changes = [account_id, display_name]
  }
}

resource "google_service_account" "cloud_sql_instanceuser" {
  account_id   = "cloud-sql-instanceuser"
  display_name = "Cloud SQL instanceUser Service Account"
  project      = var.project_id
  lifecycle {
    ignore_changes = [account_id, display_name]
  }
}

resource "google_service_account" "oidc_service_account" {
  account_id   = "oidc-service-account"
  display_name = "OIDC Service Account"
  project      = var.project_id
  lifecycle {
    ignore_changes = [account_id, display_name]
  }
}

# terraform {
#  backend "gcs" {
#    bucket  = "seed-bucket"
#    prefix  = "terraform/state"
#  }
# }
