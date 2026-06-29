output "project_id" {
  value = google_project.project.project_id
}

######k8s cluster info
# output "region" {
#   value       = var.region
#   description = "GCloud Region"
# }

# output "kubernetes_cluster_name" {
#   value       = google_container_cluster.primary.name
#   description = "GKE Cluster Name"
# }

# output "kubernetes_cluster_host" {
#   value       = google_container_cluster.primary.endpoint
#   description = "GKE Cluster Host"
# }


### Output for GSA
# output "redis_service_account_email" {
#   value = google_service_account.redis_service_account.email
# }

# output "cloud_sql_admin_service_account_email" {
#   value = google_service_account.cloud_sql_admin.email
# }