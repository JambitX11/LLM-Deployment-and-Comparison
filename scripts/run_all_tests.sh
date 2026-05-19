#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

MODEL="${1:-qwen}"
MAX_NEW_TOKENS="${MAX_NEW_TOKENS:-256}"
DTYPE="${DTYPE:-auto}"
NUM_THREADS="${NUM_THREADS:-}"

case "$MODEL" in
  qwen|chatglm3|baichuan)
    if [ -n "$NUM_THREADS" ]; then
      python scripts/run_questions_cpu.py \
        --model "$MODEL" \
        --max_new_tokens "$MAX_NEW_TOKENS" \
        --dtype "$DTYPE" \
        --num_threads "$NUM_THREADS"
    else
      python scripts/run_questions_cpu.py \
        --model "$MODEL" \
        --max_new_tokens "$MAX_NEW_TOKENS" \
        --dtype "$DTYPE"
    fi
    ;;
  *)
    echo "Usage: bash scripts/run_all_tests.sh [qwen|chatglm3|baichuan]" >&2
    exit 1
    ;;
esac

echo "Done. Raw outputs are saved under results/raw_outputs"
