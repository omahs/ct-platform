resource "google_service_account" "grafana" {
  account_id   = "${var.name}-grafana"
  display_name = "${var.name}-grafana"
}

#This grafana service account only need the workload identity user role
resource "google_service_account_iam_binding" "grafana" {
  members = [
    "serviceAccount:${var.google_project}.svc.id.goog[grafana/grafana]"
  ]
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.grafana.name
}