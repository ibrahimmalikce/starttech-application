#!/usr/bin/env bash
set -euo pipefail

ALB_DNS="${1:?Usage: health-check.sh <alb-dns-name>}"
URL="http://${ALB_DNS}/health"
MAX_RETRIES=20
SLEEP=15

echo "Running smoke test against $URL"

for i in $(seq 1 $MAX_RETRIES); do
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL" || echo "000")

  if [[ "$HTTP_STATUS" == "200" ]]; then
    echo "✅ Health check passed (attempt $i)"
    exit 0
  fi

  echo "⏳ Attempt $i/$MAX_RETRIES — status $HTTP_STATUS, retrying in ${SLEEP}s..."
  sleep $SLEEP
done

echo "❌ Health check failed after $MAX_RETRIES attempts"
exit 1