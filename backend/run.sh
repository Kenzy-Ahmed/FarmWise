#!/usr/bin/env bash
# Start the FarmWise API in dev mode: http://localhost:8000/docs
set -euo pipefail
cd "$(dirname "$0")"
exec uvicorn app.main:app --reload --host "${HOST:-0.0.0.0}" --port "${PORT:-8000}"
