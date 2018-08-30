# SmartCitizen API [![Build Status](https://travis-ci.org/fablabbcn/smartcitizen-api.svg?branch=master)](https://travis-ci.org/fablabbcn/smartcitizen-api)
[![Maintainability](https://api.codeclimate.com/v1/badges/2ac767745186038373f5/maintainability)](https://codeclimate.com/github/fablabbcn/smartcitizen-api/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/2ac767745186038373f5/test_coverage)](https://codeclimate.com/github/fablabbcn/smartcitizen-api/test_coverage)

### [Documentation](https://developer.smartcitizen.me)

* Production API - [https://api.smartcitizen.me](https://api.smartcitizen.me)
* Errors - [https://errors.smartcitizen.me](https://errors.smartcitizen.me)
* Basic Map Example - [https://api.smartcitizen.me/examples/map](https://api.smartcitizen.me/examples/map) ([map](https://github.com/fablabbcn/smartcitizen/blob/master/public/examples/map.html))
* OAuth 2.0 (Implicit Grant) Example - [http://example.smartcitizen.me](http://example.smartcitizen.me) ([smartcitizen-oauth-example](https://github.com/fablabbcn/smartcitizen-oauth-example))

## Installing Locally

### Docker quickstart

1. Copy the env.example to .env, and edit your variables, domain name, etc

`cp env.example .env`

1. Start all services

`docker-compose up`

(NOT WORKING!) If you want to start the Cassandra cluster with 3 nodes do:

`docker-compose -f docker-cassandra.yml up`


2. Create the database (first time only)

`docker-compose exec app rake db:setup`

### Linux (Tested on Ubuntu 16.04)

`apt-get install libmysqlclient-dev`

### Redis and Postgresql

`brew tap homebrew/services`

`brew install redis postgresql`

`brew services start redis`

`brew services start postgresql`

### KairosDB

`wget https://github.com/kairosdb/kairosdb/releases/download/v1.0.0/kairosdb-1.0.0-1.tar.gz`

`tar -zxvf kairosdb-1.0.0-1.tar.gz`

`./kairosdb/bin/kairosdb.sh run`

### SmartCitizen

`git clone https://github.com/fablabbcn/smartcitizen`

`cd smartcitizen`

`get config/application.yml and config/banned_words.production.yml (check production server or contact webmasters@smartcitizen.me)`

`bundle install`

`bundle exec rails s`

### Deploying

First get the `config/application.yml` env vars from the production machine.

`bundle exec cap production deploy` < password currently required. **Don't run this without discussing in Slack or issues first**. We will be automating deployments with CI/Travis so this command will eventually be deprecated.

`bundle exec cap production deploy:setup_config` < deploy configuration (symlinks to nginx, monit, etc..)

### Useful commands

`bundle exec cap production sidekiq:restart` < if sidekiq has a memory leak or something


### Versioning

Currently using this tool to manually handle versioning: https://github.com/gregorym/bump

Use this command to update the VERSION file + create a git tag

`bump patch --tag`

Then push the git tag with:

`git push --tags`
