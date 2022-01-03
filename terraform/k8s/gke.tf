variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# -----------------------------------------------
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/176#issuecomment-559643682
# resource "kubernetes_cluster_role_binding" "terraform-user-ns" {
#   metadata {
#     name = "terraform-user-ns-system-anonymous"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "cluster-admin"
#   }
#   subject {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "User"
#     name      = "system:anonymous"
#   }
# }
# -----------------------------------------------
# AS kubernetes_cluster_role_binding admin is forbiddent, we need to run locally kubectl
# https://stackoverflow.com/questions/54094575/how-to-run-kubectl-apply-commands-in-terraform
# resource "null_resource" "delete_crb_admin_anonymous_start" {
#   provisioner "local-exec" {
#     command = "kubectl delete clusterrolebindings cluster-system-anonymous"
#   }
# }
resource "null_resource" "create_crb_admin_anonymous" {
  triggers = {trigger: google_container_cluster.primary.endpoint}
  provisioner "local-exec" {
    command = "kubectl create clusterrolebinding cluster-system-anonymous --clusterrole=cluster-admin --user=system:anonymous"
  }
}

resource "null_resource" "local_argocd_install" {
  depends_on = [
    kubernetes_namespace.argocd_namespace,
  ]
  provisioner "local-exec" {
    command = "kubectl apply -f manifests/argocd/install.yml"
  }
}

provider "kubernetes" {
  host = "https://${google_container_cluster.primary.endpoint}"
  client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
  client_key             = google_container_cluster.primary.master_auth.0.client_key
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}

resource "kubernetes_namespace" "argocd_namespace" {
  depends_on = [
    null_resource.create_crb_admin_anonymous,
  ]
  lifecycle {
    ignore_changes = [metadata]
  }

  metadata {
    name = "argocd"
    # labels = {
    #   role            = "openfaas-system"
    #   access          = "openfaas-system"
    #   istio-injection = "enabled"
    # }
  }
  
}

resource "null_resource" "delete_crb_admin_anonymous_end" {
  depends_on = [
    "null_resource.local_argocd_install"
  ]
  provisioner "local-exec" {
    command = "kubectl delete clusterrolebindings cluster-system-anonymous"
  }
}

# BELOW METHOD IS 2nd OPTION TO CREATE NS
# provider "kubectl" {
#   host                   = google_container_cluster.primary.endpoint
#   cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
#   token                  = google_container_cluster.primary.master_auth.0.client_key
#   load_config_file       = false
# }

# resource "kubectl_manifest" "argocd_namespace" {
#   depends_on = [
#     null_resource.create_crb_admin_anonymous,
#   ]
#   yaml_body = file("manifests/argocd/namespace.yml")
# }

# # this one will deploy only one part of the manifest
# resource "kubectl_manifest" "argocd_install" {
#   yaml_body = file("manifests/argocd/install.yml")
# }
