FROM elixir:1.10.4-alpine

# install build dependencies
RUN apk add --no-cache build-base npm git python inotify-tools

# prepare build dir
WORKDIR /app

# install hex and rebar
RUN mix do \
local.hex --force, \
local.rebar --force

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# compile app
COPY lib lib
RUN mix compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm install --prefix ./assets --progress=false --no-audit --loglevel=error

# run server
CMD ["mix", "phx.server", "--no-compile"]
