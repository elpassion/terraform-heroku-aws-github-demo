# Typical heroku rails project setup

This repository aims to showcase possible heroku project infrastructure defined in code

### Heroku credentials

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