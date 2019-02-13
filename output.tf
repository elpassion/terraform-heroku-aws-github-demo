output "heroku_git_url" {
  value = "${heroku_app.default.git_url}"
}

output "heroku_web_url" {
  value = "${heroku_app.default.web_url}"
}

output "s3_bucket_domain_name" {
  value = "${aws_s3_bucket.static_assets.bucket_domain_name}"
}

output "s3_bucket_regional_domain_name" {
  value = "${aws_s3_bucket.static_assets.bucket_regional_domain_name}"
}

output "cloudfront_domain_name" {
  value = "${aws_cloudfront_distribution.static_assets.domain_name}"
}

output "git_clone_url" {
  value = "${github_repository.default.git_clone_url}"
}
