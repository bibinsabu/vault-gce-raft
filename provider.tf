
terraform {
  required_version = ">= 0.12"

  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}


provider "google" {
  credentials = file(var.account_file_path)
  project     = var.gcloud-project
  region      = var.gcloud-region
}