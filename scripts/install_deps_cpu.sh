#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "[1/3] Upgrade pip, setuptools, wheel"
pip install -U pip setuptools wheel

echo "[2/3] Install CPU PyTorch"
pip install torch==2.3.0+cpu torchvision==0.18.0+cpu --index-url https://download.pytorch.org/whl/cpu

echo "[3/3] Install project requirements"
pip install -r requirements.txt

echo "Ensure Qwen-compatible transformer packages"
pip install --force-reinstall transformers==4.33.3 transformers_stream_generator==0.0.4 pydantic==1.10.13

echo "Done. Current torch version:"
python -c "import torch; print(torch.__version__)"
echo "Current transformers version:"
python -c "import transformers; print(transformers.__version__)"
