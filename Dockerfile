FROM elixir:1.10.4-alpine AS build

# install build dependencies
RUN apk add build-base npm git bash python

# install dev dependencies
RUN apk add inotify-tools

# prepare build dir
WORKDIR /app

# install hex and rebar
RUN mix do local.hex --force, local.rebar --force

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# copy builds to avoid recompiling
RUN cp -r _build/dev/ _build/test/
RUN cp -r _build/dev/ _build/prod/

# install node dependencies
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm ci --prefix ./assets --progress=false --no-audit --loglevel=error

# build assets
COPY priv priv
COPY assets assets
COPY lib lib
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# set build-time env variable
ARG MIX_ENV

# compile and build release
RUN mix do compile, release


# production stage
FROM alpine:3.11 AS production

RUN apk add openssl ncurses-libs
WORKDIR /app
ARG MIX_ENV
COPY --from=build /app/_build/$MIX_ENV/rel/prequest ./

CMD ["bin/prequest", "start"]
