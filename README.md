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