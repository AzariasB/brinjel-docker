# Brinjel Docker

**After doing some more testings locally with the self-hosted version, it's become clear self-hosting that tool is not what the developers had in mind, archiving this repo in case it becomes easier in the future**

A valid dockerfile to build and run [brinjel](https://framagit.org/brinjel/brinjel) locally.

The image is published and accessible at [azariasb/brinjel](https://hub.docker.com/r/azariasb/brinjel).

It weights ~200MB on disk, is rootless (uses `nobody` by default).
Because of the way elixir compiles (heavy use of bash scripts) it makes it almost useless to make it distroless.

An exemple [docker-compose.yml](./docker-compose.yml) is given to easily setup locally the project.
It requires a postgres database to run. A light version of an image is used here.

## Setup

- Clone this repository
- Create an `env` file from the `env.example` file and change the secrets
- Run `docker compose up -d`
- Access `127.0.0.1:4000` and enjoy!

## Git patches

- To be able to run brinjel without https, the secure websocket settings has been disabled.
