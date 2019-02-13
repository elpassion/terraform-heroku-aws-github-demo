# Typical heroku rails project setup

This repository aims to showcase possible heroku project infrastructure defined in code

## Heroku credentials

Heroku credentials can be provided by using environment variables:

```
$ export HEROKU_EMAIL="<heroku_email>"
$ export HEROKU_API_KEY="<heroku_api_key>"
```

or by setting them in a [.netrc](https://ec.haxx.se/usingcurl-netrc.html) file:

```
machine api.heroku.com
login <heroku_email>
password <heroku_api_key>
```

## AWS credentials

AWS credentials can be provided by using environment variables:

```
$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
```

Or by using shared credentials file. The default location is $HOME/.aws/credentials (You can use `aws configure` to create this file).

## Heroku application

To create heroku app you'll need to provide two variables:
* `app_name` - Heroku application name, must be globally unique and have a minimum of 3 characters
* `app_region` - Region in which app should be deployed (`eu` or `us`)

These variables can be provided:

* in `terraform.tfvars` file:
  ```
  app_name = "<app-name>"
  app_region = "<region>"
  ```

* as command line option
  ```
  $ terraform apply -var 'app_name=name' -var 'app_region=region'
  ```

* terraform will ask for missing variables
  ```
  terraform plan
  $ terraform apply
  var.app_name
    Heroku application name

    Enter a value:
  ```

## AWS bucket

AWS bucket will be set up with cors rules allowing `POST`, `GET`, `PUT` from heroku app url and any additional domains specified in `aws_bucket_cors_origins`. Bucket name will be set to `<app_name>-static-assets`. Bucket name and bucket domain will be set also as env variables on heroku (`S3_BUCKET`, `S3_BUCKET_DOMAIN`)

## S3 Access

User for s3 access will be set up with credentials set in heroku env variables (`S3_ACCESS_KEY_ID`, `S3_SECRET_KEY`)