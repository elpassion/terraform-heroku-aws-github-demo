output "heroku_git_url" {
  value = "${heroku_app.default.git_url}"
}

output "heroku_web_url" {
  value = "${heroku_app.default.web_url}"
}
