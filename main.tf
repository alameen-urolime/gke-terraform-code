terraform {
  required_version = ">= 0.13.0"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.23.0"
    }

    google-beta = {
      source = "hashicorp/google-beta"
      version = "4.23.0"
    }
  }

  # Store Terraform state and the history of all revisions remotely, and protect that state with locks to prevent corruption.
  backend "gcs" {
    bucket      = "test-bucket-amn"
    prefix      = "terraform-dev"
    credentials = "./peerless-column-407106-9f432ec8b0ad.json"
  }
}

# https://www.terraform.io/docs/providers/google/index.html
# this wiil be used by default (if a resource does not specify provider )
provider "google" {
  credentials = file("./peerless-column-407106-9f432ec8b0ad.json")
  project     = var.project
  region      = var.region
  # version = "~> 2.18"
}

# use this for resources needing beta api's
provider "google-beta" {
  credentials = file("./peerless-column-407106-9f432ec8b0ad.json")
  project     = var.project
  region      = var.region
  # version = "~> 2.18"
}
