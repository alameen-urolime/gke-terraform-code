resource "google_cloudbuild_trigger" "cloudbuild-app-trigger" {
  name     = "test-ameen-nodeapp-trigger"
  filename = "cloudbuild.yaml"

  github {
    owner = "alameen-urolime"
    name  = "elk-gcp"
    push {
      branch = "^main$"
    }
  }
}   