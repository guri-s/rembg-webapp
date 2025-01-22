# Create a new GCP project
resource "google_project" "rembg_project" {
  name            = var.project_name
  project_id      = var.project_id
  billing_account = var.billing_account_id
  org_id          = var.org_id
}

# Enable required APIs
resource "google_project_service" "cloud_run_api" {
  project = google_project.rembg_project.project_id
  service = "run.googleapis.com"

  disable_dependent_services = true
}

resource "google_project_service" "artifact_registry_api" {
  project = google_project.rembg_project.project_id
  service = "artifactregistry.googleapis.com"

  disable_dependent_services = true
}

# Create Artifact Registry Repository
resource "google_artifact_registry_repository" "repo" {
  project                = google_project.rembg_project.project_id
  location               = var.region
  repository_id          = var.repository_id
  description            = "Docker repository for rembg images"
  cleanup_policy_dry_run = true
  format                 = "DOCKER"
  docker_config {
    immutable_tags = false
  }
  depends_on = [google_project_service.artifact_registry_api]
}

#Create Cloud Run service
resource "google_cloud_run_service" "rembg_service" {
  autogenerate_revision_name = false
  location                   = var.region
  name                       = var.google_cloud_run_service_name
  project                    = var.project_id

  template {
    spec {
      container_concurrency = 80
      service_account_name  = google_service_account.service_account.email
      timeout_seconds       = 300

      containers {
        args    = []
        command = []
        image   = var.docker_image_tag
        name    = var.docker_image_name

        ports {
          container_port = 5100
          name           = "http1"
          protocol       = null
        }

        resources {
          limits = {
            "cpu"    = "2000m"
            "memory" = "2Gi"
          }
          requests = {}
        }

        startup_probe {
          failure_threshold     = 1
          initial_delay_seconds = 0
          period_seconds        = 240
          timeout_seconds       = 240

          tcp_socket {
            port = 5100
          }
        }
      }
    }
  }

  traffic {
    latest_revision = true
    percent         = 100
    revision_name   = null
    tag             = null
    url             = null
  }

  depends_on = [
    google_project_service.cloud_run_api,
    google_service_account.service_account
  ]
}

resource "google_service_account" "service_account" {
  account_id   = var.service_account_id
  display_name = "Service Account"
}

resource "google_cloud_run_service_iam_member" "public_access" {
  location = var.region
  project  = google_project.rembg_project.project_id
  service  = google_cloud_run_service.rembg_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"

  depends_on = [
    google_cloud_run_service.rembg_service,
    google_service_account.service_account
  ]
}
