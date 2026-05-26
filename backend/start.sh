#!/usr/bin/env sh
set -e

cd "$(dirname "$0")"

echo "Waiting for database and running migrations..."
attempt=1
max_attempts=15
until alembic upgrade head; do
  if [ "$attempt" -ge "$max_attempts" ]; then
    echo "Alembic migrations failed after ${max_attempts} attempts."
    exit 1
  fi
  echo "Migration attempt ${attempt} failed — retrying in 3s..."
  attempt=$((attempt + 1))
  sleep 3
done
echo "Migrations complete."

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
