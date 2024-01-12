# https://www.terraform.io/docs/providers/google/r/container_cluster.html
resource "google_container_cluster" "cluster" {
  provider = google-beta

  name     = var.cluster_name
  location = var.cluster_location
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = var.vpc
  subnetwork               = google_compute_subnetwork.gke_subnet.name
min_master_version       = "1.27.3-gke.100"

  # Basic authentication allows a user to authenticate to the cluster with a username and password. 
  # When disabled, you will still be able to authenticate to the cluster with client certificate or IAM.
  # To maximize the security of your cluster, leave this option disabled. 
  # Basic authentication is not recommended because it provides no confidentiality protection for transmitted credentials.
  # 
  # Setting an empty username and password explicitly disables basic auth
  # master_auth {
  #   username = ""
  #   password = ""
  # }

  addons_config {
    # Whether we should enable the network policy addon for the master. This must be
    # enabled in order to enable network policy for the nodes. It can only be disabled
    # if the nodes already do not have network policies enabled. Defaults to disabled;
    # set disabled = false to enable.    
    network_policy_config {
      disabled = false
    }
    # istio_config {
    #   disabled = false
    #     auth     = "AUTH_MUTUAL_TLS"
    # }
    http_load_balancing {
      disabled = true
    }

  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  # Configuration for cluster IP allocation. As of now, only pre-allocated
  # subnetworks (custom type with secondary ranges) are supported. This will
  # activate IP aliases.
  ip_allocation_policy {
    # Whether alias IPs will be used for pod IPs in the cluster. Defaults to
    # true if the ip_allocation_policy block is defined, and to the API
    # default otherwise. Prior to June 17th 2019, the default on the API is
    # false; afterwards, it's true.
    # use_ip_aliases = true
    # TODO: figure out how to use variables for these networks
    cluster_secondary_range_name  = google_compute_subnetwork.gke_subnet.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.gke_subnet.secondary_ip_range[1].range_name

  }
  // we will be using istio services for these
  logging_service    = "none"
  monitoring_service = "none"

}

# https://www.terraform.io/docs/providers/google/r/container_node_pool.html
resource "google_container_node_pool" "standard" {
  provider = google-beta

  name     = "${var.cluster_name}-standard"
  location = var.cluster_location
  cluster  = google_container_cluster.cluster.name

  # Node management configuration, wherein auto-repair and auto-upgrade is configured.
  management {
    auto_repair  = "true"
    auto_upgrade = "true"
  }

  autoscaling {
    min_node_count = var.standard_min_node_count
    max_node_count = var.standard_max_node_count
  }
  # initial_node_count = var.standard_min_node_count

  node_config {
    machine_type = var.standard_machine_type

    # The metadata key/value pairs assigned to instances in the cluster.
    metadata = {
      disable-legacy-endpoints = "true"
    }

    # The set of Google API scopes to be made available on all of the node VMs
    # under the "default" service account. These can be either FQDNs, or scope
    # aliases. The cloud-platform access scope authorizes access to all Cloud
    # Platform services, and then limit the access by granting IAM roles
    # https://cloud.google.com/compute/docs/access/service-accounts#service_account_permissions
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    # Tags are used to identify valid sources or targets for network firewalls.
    tags = ["${var.cluster_name}"]
  }

  # Change how long update operations on the node pool are allowed to take
  # before being considered to have failed. The default is 10 mins.
  # https://www.terraform.io/docs/configuration/resources.html#operation-timeouts
  timeouts {
    update = "20m"
  }

}


# resource "kubernetes_deployment" "example" {
#   metadata {
#     name = "example-deployment"
#   }

#   spec {
#     selector {
#       match_labels = {
#         app = "example-app"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "example-app"
#         }
#       }

#       spec {
#         container {
#           image = "gcr.io/google-samples/hello-app:1.0"
#           name  = "example-app"
#           port {
#             container_port = 8080
#           }
#         }
#       }
#     }
#   }
# }
