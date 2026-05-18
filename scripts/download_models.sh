#!/usr/bin/env bash
set -euo pipefail

MODEL_DIR="${MODEL_DIR:-/mnt/data}"
mkdir -p "$MODEL_DIR"
cd "$MODEL_DIR"

clone_if_missing() {
  local dir_name="$1"
  local repo_url="$2"

  if [ -d "$dir_name" ]; then
    echo "[SKIP] $MODEL_DIR/$dir_name already exists"
  else
    echo "[CLONE] $repo_url"
    git clone "$repo_url"
  fi
}

clone_if_missing "Qwen-7B-Chat" "https://www.modelscope.cn/qwen/Qwen-7B-Chat.git"
clone_if_missing "chatglm3-6b" "https://www.modelscope.cn/ZhipuAI/chatglm3-6b.git"
clone_if_missing "Baichuan2-7B-Chat" "https://www.modelscope.cn/baichuan-inc/Baichuan2-7B-Chat.git"

echo "Done. Models are under $MODEL_DIR"
