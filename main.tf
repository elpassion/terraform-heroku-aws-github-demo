provider "heroku" {}

provider "aws" {
  region = "${var.aws_region}"
}

provider "github" {
  organization = "${var.github_organization}"
}

resource "heroku_app" "default" {
  name   = "${var.app_name}"
  region = "${var.app_region}"

  config_vars = {
    S3_ACCESS_KEY_ID  = "${aws_iam_access_key.s3_user_access_key.id}"
    S3_SECRET_KEY     = "${aws_iam_access_key.s3_user_access_key.secret}"
    S3_BUCKET         = "${local.bucket_name}"
    S3_BUCKET_DOMAIN  = "${aws_s3_bucket.static_assets.bucket_domain_name}"
    CLOUDFRONT_DOMAIN = "${aws_cloudfront_distribution.static_assets.domain_name}"
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

  bucket_name             = "${var.app_name}-static-assets"
  static_assets_origin_id = "S3-${local.bucket_name}-OriginID"
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

resource "aws_cloudfront_distribution" "static_assets" {
  origin {
    domain_name = "${aws_s3_bucket.static_assets.bucket_regional_domain_name}"
    origin_id   = "${local.static_assets_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.static_assets.cloudfront_access_identity_path}"
    }
  }

  enabled = true
  comment = "Cloudfront distribution for serving ${local.bucket_name} assets"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.static_assets_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_identity" "static_assets" {
  comment = "${local.bucket_name} cloudfront origin identity"
}

data "aws_iam_policy_document" "static_assets_bucket_policy" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.static_assets.arn}",
    ]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.static_assets.iam_arn}"]
    }
  }

  statement {
    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.static_assets.arn}",
      "${aws_s3_bucket.static_assets.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.static_assets.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "static_assets_bucket_policy" {
  bucket = "${aws_s3_bucket.static_assets.id}"
  policy = "${data.aws_iam_policy_document.static_assets_bucket_policy.json}"
}

resource "github_repository" "default" {
  name        = "${var.app_name}"
  description = "Main repository for app code"

  private            = "${var.github_private_repo}"
  has_issues         = true
  has_projects       = false
  has_wiki           = true
  allow_squash_merge = false
}

resource "github_team" "default" {
  name        = "${var.app_name} awesome team"
  description = "Awesome team working on ${var.app_name} project"
  privacy     = "closed"
}

resource "github_team_repository" "default" {
  team_id    = "${github_team.default.id}"
  repository = "${github_repository.default.name}"
  permission = "push"
}

resource "github_team_membership" "members" {
  username = "${element(var.github_team_members, count.index)}"
  team_id  = "${github_team.default.id}"
  role     = "member"

  count = "${length(var.github_team_members)}"
}

resource "github_team_membership" "maintainers" {
  username = "${element(var.github_team_maintainers, count.index)}"
  team_id  = "${github_team.default.id}"
  role     = "maintainer"

  count = "${length(var.github_team_maintainers)}"
}

resource "github_repository_collaborator" "admin" {
  repository = "${github_repository.default.name}"
  username   = "${element(var.github_team_maintainers, count.index)}"
  permission = "admin"

  count = "${length(var.github_repo_admins)}"
}
