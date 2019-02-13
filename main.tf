provider "heroku" {}

provider "aws" {
  region = "${var.aws_region}"
}

resource "heroku_app" "default" {
  name   = "${var.app_name}"
  region = "${var.app_region}"

  buildpacks = [
    "heroku/ruby",
  ]
}

locals {
  cors_allowed_origins = [
    "https://${var.app_name}.herokuapp.com", # Unfortunatelly have to be done this way to avoid cyclic dependencies
    "${var.aws_bucket_cors_origins}",
  ]
}


resource "aws_s3_bucket" "static_assets" {
  bucket = "${var.app_name}-static-assets"
  acl = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = "${local.cors_allowed_origins}"
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  force_destroy = true
}
