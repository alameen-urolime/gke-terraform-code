resource "google_compute_network" "vpc_network" {
  name                    = var.vpc
  auto_create_subnetworks = "false"
  project                 = var.project
}


# Create a subnet with secondary IP ranges to be used for GKE's IP aliasing:
# https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips
resource "google_compute_subnetwork" "gke_subnet" {
  name          = var.gke_subnet_name
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = var.gke_subnet_cidr
  private_ip_google_access = true


  secondary_ip_range = [
    {
      range_name    = "gke-subnet-cluster-cidr"
      ip_cidr_range = var.gke_subnet_cluster_cidr
    },
    {
      range_name    = "gke-subnet-services-cidr"
      ip_cidr_range = var.gke_subnet_services_cidr
    },
    {
      range_name    = "gke-subnet-cluster-cidr-2"
      ip_cidr_range = "10.31.0.0/17"
    },
    {
      range_name    = "gke-subnet-services-cidr-2"
      ip_cidr_range = "10.31.128.0/17"
    }
  ]


  project = var.project
  region  = var.gke_subnet_region
}
