#!/usr/bin/env sh
set -e

cd "$(dirname "$0")"

echo "Running database migrations..."
alembic upgrade head

PORT="${PORT:-8000}"
WORKERS="${WEB_CONCURRENCY:-2}"

echo "Starting Gunicorn on 0.0.0.0:${PORT} with ${WORKERS} workers..."
exec gunicorn app.main:app \
  -k uvicorn.workers.UvicornWorker \
  -b "0.0.0.0:${PORT}" \
  -w "${WORKERS}" \
  --timeout 120 \
  --access-logfile - \
  --error-logfile - \
  --forwarded-allow-ips='*'
