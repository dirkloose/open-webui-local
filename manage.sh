#!/bin/bash

# Gehe in das Verzeichnis, in dem dieses Skript liegt
cd "$(dirname "$0")"

case "$1" in
  start)
    echo "Starte Open-WebUI..."
    docker compose up -d
    ;;
  stop)
    echo "Beende Open-WebUI..."
    docker compose stop
    ;;
  restart)
    echo "Starte Open-WebUI neu..."
    docker compose restart
    ;;
  down)
    echo "Entferne Open-WebUI Container..."
    docker compose down
    ;;
  *)
    echo "Verwendung: $0 {start|stop|restart|down}"
    exit 1
    ;;
esac