resource "google_service_account" "iam_service_accounts" {
  for_each = { for idx, sa in local.iam_service_accounts : idx => sa }

  project      = var.project_id
  account_id   = each.value.account_id
  display_name = each.value.display_name
  lifecycle {
    ignore_changes = [account_id, display_name] # Ignore changes to role and member attributes
  }
}

resource "google_project_iam_member" "iam_bindings" {
  for_each = { for idx, binding in local.iam_bindings : idx => binding }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.email}"
  lifecycle {
    ignore_changes = [role, member] # Ignore changes to role and member attributes
  }
}


# # #Define a GCP service account that will be used for OIDC authentication.
# resource "google_service_account" "oidc_service_account" {
#   account_id   = "oidc-service-account"
#   display_name = "OIDC Service Account"
#     lifecycle {
#       ignore_changes = [account_id, display_name] # Ignore changes to account_id and display_name
#     }
# }




# #Create a Workload Identity Pool to allow external identities (e.g., OIDC tokens) to authenticate.
# resource "google_iam_workload_identity_pool" "oidc_pool" {
#   project                   = var.project_id
#   provider                  = google
#   workload_identity_pool_id = "my-oidc-pool"
#   display_name              = "OIDC Pool"
#     lifecycle {
#       ignore_changes = [workload_identity_pool_id, display_name]
#     }
# }


# # Bind the Service Account to the Workload Identity Pool
# resource "google_service_account_iam_member" "oidc_binding" {
#   service_account_id = google_service_account.oidc_service_account.name
#   role               = "roles/iam.workloadIdentityUser"
#   member = "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.oidc_pool.workload_identity_pool_id}/*"
#   lifecycle {
#     ignore_changes = [role, member]
#   }
# }