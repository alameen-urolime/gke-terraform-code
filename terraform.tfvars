cluster_name = "ameen-test-cluster"
# create a zonal cluster for non-prod clusters
cluster_location        = "us-west1-a" # inside oregon region
project                 = "peerless-column-407106"
region                  = "us-west1"
standard_machine_type   = "e2-standard-4"
standard_min_node_count = 1
standard_max_node_count = 3

#
# VPC Networking
#
vpc = "ameen-test"

gke_subnet_name   = "ameen-test-cluster"
gke_subnet_region = "us-west1"

gke_subnet_cidr          = "10.11.0.0/16"
gke_subnet_cluster_cidr  = "10.30.0.0/17"
gke_subnet_services_cidr = "10.30.128.0/17"
