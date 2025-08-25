```
rails new highpoint -d sqlite3 --skip-docker --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-active-storage --skip-action-cable --skip-asset-pipeline --skip-javascript --skip-hotwire --skip-jbuilder --skip-test --skip-system-test --skip-bootsnap --skip-dev-gems --skip-thruster --skip-rubocop --skip-brakeman --skip-ci --skip-kamal --no-devcontainer
```

# README

### TODO
- Copy:
  - Gemfile (with proper Ruby/Rails versions)
  - bin/legacy
  - bin/capnet
  - app/jobs/fetch_document_job.rb
  - app/models/*
  - config/application.rb
  - config/queue.yml
- Update app/models/document/fetchable.rb extract logic
- Update app/models/{legacy,capnet}.rb to push_s3! logic and keys

Code divided into Legacy and Capnet main classes to keep systems isolated.

To display CLI usage:

```
bin/legacy
# or
bin/capnet
```

These CLI binstubs will walk through usage instructions when executed
without any args.

Workflow:
- Load documents table from CSV/Excel spreadsheet file
- Fetch data from system into local "raw" folders
- Transform raw data into "transformed" folders
- Package transformed data into "packaged" zips
- Push zips to S3
- Download S3 zips onto system environment
- Ingest directly into system from the local server

Currently each step is executed via the CLI manually, but the entire system could be automated easily once we have a few good test runs.
