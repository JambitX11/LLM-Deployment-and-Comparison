import argparse
import sys

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer


DEFAULT_MODEL_PATH = "/mnt/data/Qwen-7B-Chat"
MODEL_NAME = "Qwen-7B-Chat"


def parse_args():
    parser = argparse.ArgumentParser(description="Run Qwen-7B-Chat on CPU.")
    parser.add_argument("--model_path", default=DEFAULT_MODEL_PATH, help="Local model directory.")
    parser.add_argument("--prompt", required=True, help="Input question or instruction.")
    parser.add_argument("--max_new_tokens", type=int, default=256, help="Maximum generated tokens.")
    return parser.parse_args()


def load_model(model_path):
    tokenizer = AutoTokenizer.from_pretrained(
        model_path,
        trust_remote_code=True,
    )
    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        trust_remote_code=True,
        torch_dtype=torch.float32,
        device_map="cpu",
    )
    model.eval()
    return tokenizer, model


def generate_answer(tokenizer, model, prompt, max_new_tokens):
    # Qwen-7B-Chat normally provides model.chat(). If the API changes, fall back
    # to the standard causal language model generate() interface.
    if hasattr(model, "chat"):
        response, _ = model.chat(
            tokenizer,
            prompt,
            history=None,
            max_new_tokens=max_new_tokens,
        )
        return response

    inputs = tokenizer(prompt, return_tensors="pt")
    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_new_tokens=max_new_tokens,
            do_sample=False,
        )
    generated = outputs[0][inputs["input_ids"].shape[-1] :]
    return tokenizer.decode(generated, skip_special_tokens=True)


def main():
    args = parse_args()
    try:
        tokenizer, model = load_model(args.model_path)
        answer = generate_answer(tokenizer, model, args.prompt, args.max_new_tokens)
    except FileNotFoundError:
        print(f"[ERROR] Model path not found: {args.model_path}", file=sys.stderr)
        print("Please download the model to /mnt/data first, or pass --model_path.", file=sys.stderr)
        sys.exit(1)
    except Exception as exc:
        print("[ERROR] Qwen CPU inference failed.", file=sys.stderr)
        print(f"Reason: {exc}", file=sys.stderr)
        print("Check whether dependencies are installed and whether the model directory is complete.", file=sys.stderr)
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
