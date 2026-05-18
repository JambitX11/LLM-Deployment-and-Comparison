#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

MODEL="${1:-all}"
MAX_NEW_TOKENS="${MAX_NEW_TOKENS:-128}"
OUT_DIR="results/raw_outputs"
mkdir -p "$OUT_DIR"

QUESTIONS=(
  "请说出以下两句话区别在哪里？1、冬天：能穿多少穿多少 2、夏天：能穿多少穿多少"
  "请解释这句话中两个“谁都看不上”的区别：单身狗产生的原因有两个，一是谁都看不上，二是谁都看不上。"
  "他知道我知道你知道他不知道吗？这句话里，到底谁不知道？"
  "明明明明明白白白喜欢他，可她就是不说。明明和白白谁喜欢谁？"
  "请解释下面对话中每个“意思”的不同含义：甲：你这是什么意思？乙：没什么意思，就是意思意思。甲：你这就不够意思了。乙：小意思，小意思。"
)

run_suite() {
  local name="$1"
  local script="$2"

  echo "========== Running $name =========="
  for i in "${!QUESTIONS[@]}"; do
    local qid=$((i + 1))
    local output_file="$OUT_DIR/${name}_q${qid}.txt"
    echo "[${name}] Question ${qid}, output: ${output_file}"
    python "$script" \
      --max_new_tokens "$MAX_NEW_TOKENS" \
      --prompt "${QUESTIONS[$i]}" | tee "$output_file"
  done
}

case "$MODEL" in
  qwen)
    run_suite "qwen" "scripts/run_qwen_cpu.py"
    ;;
  chatglm3)
    run_suite "chatglm3" "scripts/run_chatglm3_cpu.py"
    ;;
  baichuan)
    run_suite "baichuan" "scripts/run_baichuan_cpu.py"
    ;;
  all)
    run_suite "qwen" "scripts/run_qwen_cpu.py"
    run_suite "chatglm3" "scripts/run_chatglm3_cpu.py"
    run_suite "baichuan" "scripts/run_baichuan_cpu.py"
    ;;
  *)
    echo "Usage: bash scripts/run_all_tests.sh [qwen|chatglm3|baichuan|all]" >&2
    exit 1
    ;;
esac

echo "Done. Raw outputs are saved under $OUT_DIR"
