# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

This is a **deployment wrapper** for Open WebUI, not the Open WebUI application source code. It consists of a Docker Compose configuration and a small shell script to manage the container lifecycle. The actual application runs from the prebuilt `ghcr.io/open-webui/open-webui:main` image.

## Commands

Manage the stack with `./manage.sh {start|stop|restart|down}` (wraps `docker compose`):

```bash
./manage.sh start    # docker compose up -d
./manage.sh stop     # docker compose stop
./manage.sh restart  # docker compose restart
./manage.sh down     # docker compose down (removes containers)
```

There is no build, lint, or test tooling in this repo — changes are limited to editing `compose.yaml` and re-running `./manage.sh restart` (or `down` + `start` if volumes/ports/env changed structurally).

## Version control

This repo is pushed to GitHub as a private repository: `dirkloose/open-webui-local` (remote `origin`, branch `main`). The `gh` CLI is installed and authenticated for GitHub operations (issues, PRs, etc.) if needed.

## Architecture

- `compose.yaml` — single-service Docker Compose file defining the `open-webui` container:
  - Exposes the app on host port `3000` (container port `8080`).
  - Persists app data in the named volume `open-webui` (mounted at `/app/backend/data`).
  - Configured to talk to an **LM Studio** instance on the host via `OPENAI_API_BASE_URL=http://host.docker.internal:1234/v1` (OpenAI-compatible API), with `OPENAI_API_KEY=lm-studio` as a placeholder key.
  - Ollama integration is explicitly disabled (`ENABLE_OLLAMA_API=false`).
  - `WEBUI_AUTH=true` — login is required.
- `manage.sh` — `cd`s to its own directory first, so it can be invoked from anywhere; thin dispatcher around `docker compose` subcommands.

## Notes for making changes

- Since the app itself is an external prebuilt image, most "features" are configured via environment variables in `compose.yaml` (see Open WebUI's own env var documentation for available options) rather than by writing code here.
- The backing LLM provider is LM Studio running on the host machine, not a container in this compose file — `host.docker.internal` is used to reach it from inside Docker.