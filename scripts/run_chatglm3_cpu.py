import argparse
import sys

import torch
from transformers import AutoModel, AutoModelForCausalLM, AutoTokenizer


DEFAULT_MODEL_PATH = "/mnt/data/chatglm3-6b"
MODEL_NAME = "ChatGLM3-6B"


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
    parser = argparse.ArgumentParser(description="Run ChatGLM3-6B on CPU.")
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
    )

    try:
        model = AutoModelForCausalLM.from_pretrained(
            model_path,
            trust_remote_code=True,
            torch_dtype=parse_dtype(dtype),
            device_map="cpu",
            low_cpu_mem_usage=True,
        )
    except Exception:
        # ChatGLM models often document AutoModel rather than AutoModelForCausalLM.
        # Keep this fallback so the script still matches the official model API.
        model = AutoModel.from_pretrained(
            model_path,
            trust_remote_code=True,
            torch_dtype=parse_dtype(dtype),
            device_map="cpu",
            low_cpu_mem_usage=True,
        )

    model.eval()
    return tokenizer, model


def generate_answer(tokenizer, model, prompt, max_new_tokens):
    # ChatGLM3 usually provides model.chat(tokenizer, prompt, history=[]).
    # If the model README changes, this call may need small adjustments.
    if hasattr(model, "chat"):
        response, _ = model.chat(
            tokenizer,
            prompt,
            history=[],
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
        tokenizer, model = load_model(args.model_path, dtype=args.dtype)
        answer = generate_answer(tokenizer, model, args.prompt, args.max_new_tokens)
    except FileNotFoundError:
        print(f"[ERROR] Model path not found: {args.model_path}", file=sys.stderr)
        print("Please download the model to /mnt/data first, or pass --model_path.", file=sys.stderr)
        sys.exit(1)
    except Exception as exc:
        print("[ERROR] ChatGLM3 CPU inference failed.", file=sys.stderr)
        print(f"Reason: {exc}", file=sys.stderr)
        print("Check dependencies, model files, memory size, and the model README.", file=sys.stderr)
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
