# resource "google_storage_bucket" "terraform_state_bucket" {
#   name                        = var.terraform_state_bucket # Replace with a globally unique bucket name
#   location                    = var.region                       # Replace with your preferred region
#   storage_class               = "STANDARD"                          # Storage class (e.g., STANDARD, NEARLINE, etc.)
#   uniform_bucket_level_access = true                                # Enables uniform access control

#   versioning {
#     enabled = false # Enables versioning to keep a history of state file changes
#   }

#   lifecycle_rule {
#     action {
#       type = "Delete"
#     }
#     condition {
#       age = 365 # Deletes objects older than 365 days
#     }
#   }
# }


# # resource "google_storage_bucket_iam_member" "terraform_bucket_access" {
# #   bucket = google_storage_bucket.terraform_state_bucket.name
# #   role   = "roles/storage.admin"
# #   member = "serviceAccount:${google_service_account.iam_service_accounts["redis-service-account"].email}"
# # }