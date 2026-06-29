# # #### memorystore
# resource "google_redis_instance" "default" {
#   name               = "my-redis-instance"
#   tier               = "BASIC" # Options: BASIC or STANDARD
#   memory_size_gb     = 1
#   region             = "us-central1"
#   authorized_network = "default"
#   project            = var.project

#   depends_on = [google_project_service.enable_apis]
# }