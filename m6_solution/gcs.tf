resource "google_storage_bucket" "course-test" {
  name          = local.gcs_bucket_name
  location      = var.gcp_region
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "logo" {
  name   = "Globo_logo_Vert.png"
  source = "./website/Globo_logo_Vert.png"
  bucket = google_storage_bucket.course-test.name
}

resource "google_storage_bucket_object" "index-file" {
  name   = "index.html"
  source = "./website/index.html"
  bucket = google_storage_bucket.course-test.name
}

resource "google_storage_bucket_iam_binding" "policy" {
  bucket = google_storage_bucket.course-test.name
  role   = "roles/storage.admin"
  members = var.iam_binding_policy_members
}
