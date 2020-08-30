FROM elixir:1.10.4-alpine AS build

# install build dependencies
RUN apk add --no-cache build-base npm git python

# install dev dependencies
RUN apk add --no-cache inotify-tools

# prepare build dir
WORKDIR /app

# install hex and rebar
RUN mix do local.hex --force, local.rebar --force

# set build-time env variable
ARG MIX_ENV

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm ci --prefix ./assets --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# compile and build release
COPY lib lib
# uncomment COPY if rel/ exists
# COPY rel rel
RUN mix do compile, release


# production stage
FROM alpine:3.11 AS production

RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

COPY --from=build /app/_build/prod/rel/prequest ./

CMD ["bin/prequest", "start"]
