variable "app_name" {
  description = "Heroku application name"
}

variable "app_region" {
  description = "Heroku application region"
}

variable "aws_region" {
  description = "AWS region"
}

variable "aws_bucket_cors_origins" {
  description = "CORS origins for AWS bucket"
  default     = []
}
