provider "heroku" {}

provider "aws" {
  region = "${var.aws_region}"
}

resource "heroku_app" "default" {
  name   = "${var.app_name}"
  region = "${var.app_region}"

  config_vars = {
    S3_ACCESS_KEY_ID = "${aws_iam_access_key.s3_user_access_key.id}"
    S3_SECRET_KEY    = "${aws_iam_access_key.s3_user_access_key.secret}"
    S3_BUCKET        = "${local.bucket_name}"
    S3_BUCKET_DOMAIN = "${aws_s3_bucket.static_assets.bucket_domain_name}"
  }

  buildpacks = [
    "heroku/ruby",
  ]
}

locals {
  cors_allowed_origins = [
    "https://${var.app_name}.herokuapp.com", # Unfortunatelly have to be done this way to avoid cyclic dependencies
    "${var.aws_bucket_cors_origins}",
  ]

  bucket_name = "${var.app_name}-static-assets"
}

resource "aws_s3_bucket" "static_assets" {
  bucket = "${local.bucket_name}"
  acl    = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = "${local.cors_allowed_origins}"
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  force_destroy = true
}

resource "aws_iam_user" "s3_user" {
  name = "${var.app_name}-static-assets-user"

  force_destroy = true
}

resource "aws_iam_user_policy" "s3_user_policy" {
  user = "${aws_iam_user.s3_user.name}"

  policy = "${data.aws_iam_policy_document.s3_access.json}"
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.static_assets.arn}",
    ]
  }

  statement {
    actions = ["s3:*"]

    resources = [
      "${aws_s3_bucket.static_assets.arn}",
      "${aws_s3_bucket.static_assets.arn}/*",
    ]
  }
}

resource "aws_iam_access_key" "s3_user_access_key" {
  user = "${aws_iam_user.s3_user.name}"
}
