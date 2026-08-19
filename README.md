# Open WebUI — Local Deployment

A minimal Docker Compose setup that runs [Open WebUI](https://github.com/open-webui/open-webui) as a chat frontend for a **LM Studio** instance running on the host machine.

This repository contains no application code. Open WebUI runs from the prebuilt image `ghcr.io/open-webui/open-webui:main`; everything here is configuration and a small management script.

## Prerequisites

- **Docker Desktop** (or another Docker runtime with Compose v2)
- **LM Studio** running on the host with its local server started on port `1234`, with at least one model loaded

The container reaches LM Studio via `host.docker.internal`, which Docker Desktop provides on macOS and Windows. On native Linux you need to add the following to the service in `compose.yaml`:

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

## Quick start

```bash
./manage.sh start
```

Then open <http://localhost:3000>. On first launch you create an admin account — the first registered user becomes the administrator.

## Managing the stack

`manage.sh` is a thin wrapper around `docker compose` and `cd`s into its own directory first, so it can be called from anywhere.

| Command | Effect |
| --- | --- |
| `./manage.sh start` | `docker compose up -d` — create and start the container |
| `./manage.sh stop` | `docker compose stop` — stop it, keep the container |
| `./manage.sh restart` | `docker compose restart` — restart the running container |
| `./manage.sh down` | `docker compose down` — stop and remove the container |

Anything the script does not cover, run through Compose directly from this directory:

```bash
docker compose logs -f      # follow logs
docker compose ps           # container status
```

## Configuration

All settings live in the `environment:` block of `compose.yaml`:

| Variable | Value | Purpose |
| --- | --- | --- |
| `OPENAI_API_BASE_URL` | `http://host.docker.internal:1234/v1` | LM Studio's OpenAI-compatible endpoint |
| `OPENAI_API_KEY` | `lm-studio` | Placeholder — LM Studio does not check it, but Open WebUI requires a non-empty value |
| `ENABLE_OLLAMA_API` | `false` | Hides the Ollama integration, which is unused here |
| `WEBUI_AUTH` | `true` | Requires login |

Open WebUI supports many more environment variables; see the [official documentation](https://docs.openwebui.com/getting-started/env-configuration/) for the full list.

After changing values, apply them with:

```bash
./manage.sh down && ./manage.sh start
```

`restart` alone is not enough — environment variables are baked in at container creation.

Port mapping is `3000:8080`. To serve on a different host port, change the left-hand side only (for example `8081:8080`).

## Data persistence

Application data — accounts, chat history, settings, uploaded documents — is stored in the named Docker volume `open-webui`, mounted at `/app/backend/data` inside the container.

The volume survives `stop`, `restart`, and `down`. It is only deleted by an explicit:

```bash
docker compose down -v      # destroys all chat history and accounts
```

To back it up:

```bash
docker run --rm -v open-webui:/data -v "$PWD":/backup alpine \
  tar czf /backup/open-webui-backup.tar.gz -C /data .
```

## Updating

The image tag is `main`, which moves. Pull the current build and recreate the container:

```bash
docker compose pull
./manage.sh down
./manage.sh start
```

Your data is untouched, since it lives in the volume rather than the container.

## Troubleshooting

**No models appear in the model picker.** LM Studio's server is not reachable. Check that the local server is started (not just the app running), that a model is loaded, and that it listens on port `1234`. Verify from the host with `curl http://localhost:1234/v1/models`.

**The UI does not load at all.** Check `docker compose logs -f` and confirm nothing else occupies host port `3000`.

**Connection works from the host but not the container.** On Linux, add the `extra_hosts` entry shown under [Prerequisites](#prerequisites). Also make sure LM Studio is bound to all interfaces rather than `127.0.0.1` only.
