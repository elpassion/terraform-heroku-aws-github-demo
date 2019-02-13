provider "heroku" {}

resource "heroku_app" "default" {
  name   = "${var.app_name}"
  region = "${var.app_region}"

  buildpacks = [
    "heroku/ruby",
  ]
}
