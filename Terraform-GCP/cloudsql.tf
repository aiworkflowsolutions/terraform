# #cloud SQL Instance
# resource "google_sql_database_instance" "default" {
#   name             = "banfield-sql-instance"
#   database_version = "MYSQL_8_0"
#   region           = "us-central1"
#   project          = var.project_id

#   settings {
#     tier = "db-f1-micro" # Smallest instance type
#     ip_configuration {
#       private_network = "projects/${var.project_id}/global/networks/${var.project_id}-vpc"
#     }
#     backup_configuration {
#       enabled = true
#     }
#   }

#   depends_on = [google_project_service.enable_apis]

#   lifecycle {
#     ignore_changes = [settings] # Ignore changes to settings
#   }
# }


# ## Create a database
# ## and a user for the Cloud SQL instance
# ## The database and user will be created in the Cloud SQL instance
# resource "google_sql_database" "mydb-gb" {
#   name     = "my_sqldatabase"
#   instance = google_sql_database_instance.default.name
#   project  = var.project_id
#   lifecycle {
#     ignore_changes = [name] # Ignore changes to the database name
#   }
# }

# resource "google_sql_user" "default" {
#   name     = "admin-user"
#   instance = google_sql_database_instance.default.name
#   password = "Password1!"
#   project  = var.project_id
#   lifecycle {
#     ignore_changes = [password] # Ignore changes to the password
#   }
# }
