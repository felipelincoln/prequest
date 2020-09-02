# Prequest boilerplate - Phoenix and Docker
![](https://miro.medium.com/max/1200/1*LSfSkdT9K3bQFKvyPEl3OA.png)
This is the boilerplate we built and use at Prequest.

## Summary
In this guide we will build from scratch:

1. [Phoenix live application](#phoenix-live-application)
3. Create our development environment using docker-compose
2. Deploy it to Heroku using releases and Docker
4. Setup CI using GitHub Actions
5. Build a documentation page using ExDoc and GitHub Pages

To match the results in this guide make sure you have installed the following versions of elixir/OTP and phoenix:

```
$ elixir -v
Erlang/OTP 23 [erts-11.0.3] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]

Elixir 1.10.4 (compiled with Erlang/OTP 22)
```
```
$ mix phx.new -v
Phoenix v1.5.4
```

And Docker and docker-compose:
```
$ docker -v
Docker version 19.03.12, build 48a66213fe
```

```
$ docker-compose -v
docker-compose version 1.25.4, build unknown
```
