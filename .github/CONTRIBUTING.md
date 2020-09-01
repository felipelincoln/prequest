# Contributing to Prequest

## Running the application locally
Make sure to have [docker-compose](https://docs.docker.com/compose/) installed.

```
git clone https://github.com/felipelincoln/prequest.git
cd prequest/
docker-compose up -d db
docker-compose run web mix ecto.create
docker-compose up
```

Next time running this application you will only need to:

```
docker-compose up
```

## Test pipeline
Good practice to run before making commits. It will mirror our [GitHub action](https://github.com/felipelincoln/prequest/blob/master/.github/workflows/test.yml).
```
docker-compose exec web mix ci
```

This will run:  

`mix format --check-formatted --dry-run `  
`mix credo --strict`  
`mix sobelow -v`  
`mix test`  

## Building documentation
Run whenever your changes may cause [documentation](https://felipelincoln.github.io/prequest/readme.html) changes.

```
docker-compose exec web mix docs
```
