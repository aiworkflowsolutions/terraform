
#GCP backend
# terraform {
#   backend "gcs" {
#     bucket  = "my-unique-terraform-state-bucket" # Replace with your bucket name
#     prefix  = "terraform/state"                 # Path within the bucket to store the state file
#     project = var.project_id                    # GCP project ID
#   }
# }

#K8s backend Secret
terraform {
  backend "kubernetes" {
    namespace     = "terraform-gcp"
    secret_suffix = "tfstate-default-state"
    config_path   = "~/.kube/config"
  }
}


# kubectl create namespace terraform
# apiVersion: rbac.authorization.k8s.io/v1
# kind: Role
# metadata:
#   namespace: terraform
#   name: terraform-state-manager
# rules:
#   - apiGroups: [""]
#     resources: ["secrets"]
#     verbs: ["get", "list", "create", "update", "delete"]

# ---
# apiVersion: rbac.authorization.k8s.io/v1
# kind: RoleBinding
# metadata:
#   namespace: terraform
#   name: terraform-state-binding
# roleRef:
#   apiGroup: rbac.authorization.k8s.io
#   kind: Role
#   name: terraform-state-manager
# subjects:
#   - kind: User
#     name: <YOUR_USER_NAME> # Replace with your Kubernetes user or service account
#     apiGroup: ""
# kubectl apply -f rbac.yaml
# terraform init
# kubectl get secret terraform-state -n terraform -o yaml




