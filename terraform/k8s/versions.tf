terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.5.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.13.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}
