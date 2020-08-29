FROM elixir:1.10.4-alpine

# install build dependencies
RUN apk add --no-cache build-base npm git python

# prepare build dir
WORKDIR /app

# install hex and rebar
RUN mix do \
local.hex --force, \
local.rebar --force

# set build-time variable
ENV MIX_ENV=prod

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

# compile app
COPY lib lib
RUN mix compile

# run server
CMD ["mix", "phx.server"]
