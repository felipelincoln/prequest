FROM elixir:1.10.4

RUN mix do \
local.hex --force, \
local.rebar --force, \
archive.install hex phx_new 1.5.4 --force

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
apt install -y nodejs
