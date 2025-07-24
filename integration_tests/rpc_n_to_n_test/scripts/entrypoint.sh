#!/bin/bash

ROLE="$1"
MODE="$2"

if [ -z "$ROLE" ] || [ -z "$MODE" ]; then
  echo "[ERROR] Usage: ./entrypoint.sh <client|server> <mode>"
  exit 1
fi

echo "[Entrypoint] Starting $ROLE in mode $MODE..."

if [ "$ROLE" = "client" ]; then
  exec /app/src/build/rpc_n_to_n_client -m "$MODE"
elif [ "$ROLE" = "server" ]; then
  exec /app/src/build/rpc_n_to_n_server -m "$MODE"
else
  echo "[ERROR] Unknown role: $ROLE"
  exit 1
fi
