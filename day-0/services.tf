resource "google_project_service" "cloudresourcemanager" {
  project = var.google_project
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "compute" {
  project = var.google_project
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  project = var.google_project
  service = "container.googleapis.com"
}

resource "google_project_service" "dns" {
  project = var.google_project
  service = "dns.googleapis.com"
}

resource "google_project_service" "iam" {
  project = var.google_project
  service = "iam.googleapis.com"
}