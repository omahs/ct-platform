resource "google_service_account" "traefik" {
  account_id   = "${var.name}-traefik"
  display_name = "${var.name}-traefik"
}

#This traefik service account only need the workload identity user role
resource "google_service_account_iam_binding" "traefik" {
  members = [
    "serviceAccount:${var.google_project}.svc.id.goog[traefik/traefik]"
  ]
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.traefik.name
}