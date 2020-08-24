FROM elixir:1.10.4

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY prequest/ .

RUN mix do \
local.hex --force, \
local.rebar --force, \
archive.install hex phx_new 1.5.4 --force, \
deps.get

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
apt install -y nodejs
