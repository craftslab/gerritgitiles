# gerritgitiles

This repository provides Docker artifacts for running Gitiles `v1.6.0` alongside Gerrit `2.13.14` (from Gerrit `stable-2.13`).

## Files

- `Dockerfile` builds the standalone Gitiles WAR from `v1.6.0` with Bazel and deploys it to Jetty.
- `docker-compose.yml` starts Gerrit 2.13 and Gitiles together with a shared repository volume.
- `gitiles.config` points Gitiles at Gerrit’s shared Git repository volume.

## Build

```bash
docker compose build gitiles
```

## Run

```bash
docker compose up
```

Services listen on:

- Gerrit: `http://localhost:8080`
- Gitiles: `http://localhost:8081`
- Gerrit SSH: `ssh://localhost:29418`

The `gerrit-git` named volume is mounted read-only into Gitiles at `/var/git`, so repositories created by Gerrit are browsable from Gitiles.

## Version overrides

You can override the Gitiles ref or Bazel version at build time:

```bash
docker build \
  --build-arg GITILES_REF=v1.6.0 \
  --build-arg BAZEL_VERSION=7.0.1 \
  -t craftslab/gitiles:custom .
```
