resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

locals {
  common_tags = {
    company      = var.company
    project      = "${var.company}-${var.project}"
    billing-code = var.billing_code
  }

  gcs_bucket_name = "test-app-${random_integer.rand.result}"
}

