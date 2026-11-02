# Used to tag the final docker image
ARG BRINJEL_VERSION=1.0.0
ARG OTP_VERSION=29.1.2

# renovate: datasource=docker depName=library/elixir versioning=semver
ARG ELIXIR_VERSION=1.20.5
# renovate: datasource=docker depName=library/debian versioning=debian
ARG DEBIAN_VERSION=trixie-20261027-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG DEBIAN_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

ENV MIX_ENV="prod"

RUN apt-get update -y \
    && apt-get install --no-install-recommends -y build-essential git npm curl \
    && apt-get clean \
    && git clone --depth 1 https://framagit.org/brinjel/brinjel.git /app \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY local-fixes.patch .


# install hex + rebar
RUN git apply local-fixes.patch \
    && mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get --only $MIX_ENV \
    && mix deps.compile

WORKDIR /app/assets

RUN npm ci

WORKDIR /app

# compile assets
# Compile the release
RUN mix assets.deploy \
    && mix compile \
    && mix release

FROM ${DEBIAN_IMAGE}

RUN apt-get update -y \
    && apt-get install --no-install-recommends -y \
    dash \
    libstdc++6 \
    openssl \
    libsctp1 \
    libncurses6 \
    locales \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen


ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8" \
    MIX_ENV="prod"

WORKDIR /app

USER nobody

COPY --chown=nobody:nobody ./bin /app
COPY --from=builder --chown=nobody:nobody /app/_build/${MIX_ENV}/rel/brinjel ./

ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["run"]
