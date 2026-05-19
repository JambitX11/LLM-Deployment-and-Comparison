import argparse
import sys

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer


DEFAULT_MODEL_PATH = "/mnt/data/Baichuan2-7B-Chat"
MODEL_NAME = "Baichuan2-7B"


def parse_dtype(dtype):
    if dtype == "auto":
        return "auto"
    if dtype == "float16":
        return torch.float16
    if dtype == "bfloat16":
        return torch.bfloat16
    if dtype == "float32":
        return torch.float32
    raise ValueError(f"Unsupported dtype: {dtype}")


def parse_args():
    parser = argparse.ArgumentParser(description="Run Baichuan2-7B on CPU.")
    parser.add_argument("--model_path", default=DEFAULT_MODEL_PATH, help="Local model directory.")
    parser.add_argument("--prompt", required=True, help="Input question or instruction.")
    parser.add_argument("--max_new_tokens", type=int, default=256, help="Maximum generated tokens.")
    parser.add_argument(
        "--dtype",
        choices=["auto", "float16", "bfloat16", "float32"],
        default="auto",
        help="Model dtype. Use auto to avoid forcing 7B weights to float32 on CPU.",
    )
    return parser.parse_args()


def load_model(model_path, dtype="auto"):
    tokenizer = AutoTokenizer.from_pretrained(
        model_path,
        trust_remote_code=True,
        use_fast=False,
    )
    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        trust_remote_code=True,
        torch_dtype=parse_dtype(dtype),
        device_map="cpu",
        low_cpu_mem_usage=True,
    )
    model.eval()
    return tokenizer, model


def build_inputs(tokenizer, prompt):
    # Baichuan2-7B-Chat may support chat templates in newer tokenizer versions.
    # Baichuan2-7B-Base is not instruction-tuned, so plain prompt generation is expected.
    if hasattr(tokenizer, "apply_chat_template") and tokenizer.chat_template:
        messages = [{"role": "user", "content": prompt}]
        return tokenizer.apply_chat_template(
            messages,
            add_generation_prompt=True,
            return_tensors="pt",
        )
    return tokenizer(prompt, return_tensors="pt")["input_ids"]


def generate_answer(tokenizer, model, prompt, max_new_tokens):
    input_ids = build_inputs(tokenizer, prompt)
    with torch.no_grad():
        outputs = model.generate(
            input_ids=input_ids,
            max_new_tokens=max_new_tokens,
            do_sample=False,
        )
    generated = outputs[0][input_ids.shape[-1] :]
    return tokenizer.decode(generated, skip_special_tokens=True)


def main():
    args = parse_args()
    try:
        tokenizer, model = load_model(args.model_path, dtype=args.dtype)
        answer = generate_answer(tokenizer, model, args.prompt, args.max_new_tokens)
    except FileNotFoundError:
        print(f"[ERROR] Model path not found: {args.model_path}", file=sys.stderr)
        print("Please download Baichuan2 to /mnt/data first, or pass --model_path.", file=sys.stderr)
        sys.exit(1)
    except Exception as exc:
        print("[ERROR] Baichuan CPU inference failed.", file=sys.stderr)
        print(f"Reason: {exc}", file=sys.stderr)
        print("If using Baichuan2-7B-Base, the answer may be less instruction-following than the Chat model.", file=sys.stderr)
        sys.exit(1)

    print("=" * 60)
    print(f"Model: {MODEL_NAME}")
    print(f"Model path: {args.model_path}")
    print("-" * 60)
    print(f"Prompt:\n{args.prompt}")
    print("-" * 60)
    print(f"Answer:\n{answer}")
    print("=" * 60)


if __name__ == "__main__":
    main()
