# resource "google_billing_budget" "affable_heading_budget" {
#   billing_account = var.billing_account

#   display_name = "My Budget"

#   amount {
#     specified_amount {
#       currency_code = "USD"
#       units         = 50 # Budget amount in USD
#     }
#   }

#   threshold_rules {
#     threshold_percent = 0.5 # 50% threshold
#   }

#   threshold_rules {
#     threshold_percent = 0.9 # 90% threshold
#   }

#   all_updates_rule {
#     pubsub_topic   = google_pubsub_topic.budget_notifications.id
#     schema_version = "1.0"
#   }
# }

# resource "google_pubsub_topic" "budget_notifications" {
#   name    = "budget-notifications"
#   project = var.project_id
# }