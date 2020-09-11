# Contributing to Prequest

Make sure to have [docker-compose](https://docs.docker.com/compose/) installed.  

## Running the application locally
Enter the development container:

```shell
git clone https://github.com/felipelincoln/prequest.git
cd prequest/
docker-compose run --service-ports web /bin/sh
```

Create the database, run migrations and start the server:

```shell
mix ecto.setup
mix phx.server
```

After exiting the container (with the `exit` command) you can get back to it:

```shell
docker start -a -i prequest_web_run_<hash>

```
Alternatively, you can fast start the services:

```shell
docker-compose up
```

## Test pipeline
Good practice to run before making commits. It will mirror our [GitHub action](https://github.com/felipelincoln/prequest/blob/master/.github/workflows/test.yml).  
Run the following inside the container:

```shell
mix ci
```

This will run:  

```shell
mix format --check-formatted --dry-run
mix credo --strict
mix sobelow -v
mix test
```

## Building documentation
Run whenever your changes may cause [documentation](https://felipelincoln.github.io/prequest/readme.html) changes.  
Run the following inside the container:

```shell
mix docs
```
