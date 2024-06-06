# README

This README would normally document whatever steps are necessary to get the
application up and running.

## Requirements
- Ruby 2.5.5
- Libraries: bundler

## Dependencies
  - `bundle install`

## Configuration and setup
  - Set database username, password and host in 'database.yml':
  - Create and setup the database:
    `bundle exec rails db:create`
  - I assume that you will have a dump of schema.sql file, if it's not then run this command
    `bundle exec rails db:setup`

## Run
  - Start server
    `bundle exec rails server`
  - And now you can visit the site with the URL http://localhost:3000

## Test
  - `bundle exec rspec spec/`

## Postman Collection
  - You can test our API endpoints using the Postman collection.
   `https://www.postman.com/chetanmehta1612/workspace/backend-server/collection/36140358-94f5f4fe-e6fc-4009-9703-2e49317e84d8?action=share&creator=36140358`
