import argparse
import json
import sys
import time
from datetime import datetime
from pathlib import Path

import torch

import run_baichuan_cpu
import run_chatglm3_cpu
import run_qwen_cpu


MODEL_REGISTRY = {
    "qwen": {
        "name": run_qwen_cpu.MODEL_NAME,
        "default_path": run_qwen_cpu.DEFAULT_MODEL_PATH,
        "load_model": run_qwen_cpu.load_model,
        "generate_answer": run_qwen_cpu.generate_answer,
    },
    "chatglm3": {
        "name": run_chatglm3_cpu.MODEL_NAME,
        "default_path": run_chatglm3_cpu.DEFAULT_MODEL_PATH,
        "load_model": run_chatglm3_cpu.load_model,
        "generate_answer": run_chatglm3_cpu.generate_answer,
    },
    "baichuan": {
        "name": run_baichuan_cpu.MODEL_NAME,
        "default_path": run_baichuan_cpu.DEFAULT_MODEL_PATH,
        "load_model": run_baichuan_cpu.load_model,
        "generate_answer": run_baichuan_cpu.generate_answer,
    },
}


def parse_args():
    parser = argparse.ArgumentParser(
        description="Load one model once, then run all test questions sequentially on CPU."
    )
    parser.add_argument("--model", choices=sorted(MODEL_REGISTRY.keys()), required=True)
    parser.add_argument("--model_path", default=None, help="Local model directory.")
    parser.add_argument("--questions", default="prompts/test_questions.json")
    parser.add_argument("--output", default=None, help="Markdown output file.")
    parser.add_argument("--max_new_tokens", type=int, default=256)
    parser.add_argument(
        "--dtype",
        choices=["auto", "float16", "bfloat16", "float32"],
        default="auto",
        help="Model dtype. Use auto to avoid forcing 7B weights to float32 on CPU.",
    )
    parser.add_argument(
        "--num_threads",
        type=int,
        default=None,
        help="Set torch CPU thread count. Try 2, 4, or 8 depending on the Notebook CPU.",
    )
    parser.add_argument(
        "--stream",
        action="store_true",
        help="Stream partial output when the selected model supports it. Qwen supports this in many releases.",
    )
    parser.add_argument("--limit", type=int, default=None, help="Run only the first N questions.")
    return parser.parse_args()


def load_questions(path, limit):
    question_path = Path(path)
    with question_path.open("r", encoding="utf-8") as file:
        questions = json.load(file)

    if not isinstance(questions, list) or not questions:
        raise ValueError(f"Question file is empty or invalid: {question_path}")

    return questions[:limit] if limit is not None else questions


def write_header(file, model_name, model_path, question_file, max_new_tokens, dtype, num_threads):
    file.write(f"# {model_name} 批量测试结果\n\n")
    file.write(f"- 运行时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    file.write(f"- 模型路径：`{model_path}`\n")
    file.write(f"- 问题文件：`{question_file}`\n")
    file.write(f"- max_new_tokens：`{max_new_tokens}`\n\n")
    file.write(f"- dtype：`{dtype}`\n")
    file.write(f"- torch num threads：`{num_threads}`\n\n")


def main():
    args = parse_args()
    config = MODEL_REGISTRY[args.model]
    model_path = args.model_path or config["default_path"]
    output_path = Path(args.output or f"results/raw_outputs/{args.model}_all_questions.md")
    output_path.parent.mkdir(parents=True, exist_ok=True)

    if args.num_threads is not None:
        torch.set_num_threads(args.num_threads)

    num_threads = torch.get_num_threads()

    try:
        questions = load_questions(args.questions, args.limit)
    except Exception as exc:
        print(f"[ERROR] Failed to read questions: {exc}", file=sys.stderr)
        sys.exit(1)

    print(f"[INFO] Loading {config['name']} from {model_path}")
    print("[INFO] This may take several minutes on CPU.")
    print(f"[INFO] dtype={args.dtype}, torch_num_threads={num_threads}")

    try:
        load_started = time.perf_counter()
        tokenizer, model = config["load_model"](model_path, dtype=args.dtype)
        load_seconds = time.perf_counter() - load_started
    except Exception as exc:
        print(f"[ERROR] Failed to load model: {exc}", file=sys.stderr)
        print("Check whether the model has been downloaded to /mnt/data and whether memory is enough.", file=sys.stderr)
        sys.exit(1)

    print(f"[INFO] Model loaded in {load_seconds:.2f} seconds.")
    total_generation_seconds = 0.0
    summary_rows = []

    with output_path.open("w", encoding="utf-8") as file:
        write_header(
            file,
            config["name"],
            model_path,
            args.questions,
            args.max_new_tokens,
            args.dtype,
            num_threads,
        )
        file.write(f"- 模型加载耗时：`{load_seconds:.2f} 秒`\n\n")

        for index, item in enumerate(questions, start=1):
            qid = item.get("id", index)
            title = item.get("title", f"Question {qid}")
            ability = item.get("ability", "未填写")
            prompt = item["prompt"]

            print("=" * 60)
            print(f"[{index}/{len(questions)}] {title}")
            print(f"Prompt: {prompt}")
            print("-" * 60)

            try:
                generation_started = time.perf_counter()
                try:
                    answer = config["generate_answer"](
                        tokenizer,
                        model,
                        prompt,
                        args.max_new_tokens,
                        stream=args.stream,
                    )
                except TypeError:
                    answer = config["generate_answer"](tokenizer, model, prompt, args.max_new_tokens)
                generation_seconds = time.perf_counter() - generation_started
            except Exception as exc:
                generation_seconds = time.perf_counter() - generation_started
                answer = f"[ERROR] Failed to generate answer: {exc}"
                print(answer, file=sys.stderr)

            total_generation_seconds += generation_seconds
            summary_rows.append((qid, title, generation_seconds))

            print(answer)
            print(f"[TIME] Question {qid}: {generation_seconds:.2f} seconds")

            file.write(f"## 问题 {qid}：{title}\n\n")
            file.write(f"- 测试能力：{ability}\n\n")
            file.write(f"- 生成耗时：`{generation_seconds:.2f} 秒`\n\n")
            file.write("### 输入问题\n\n")
            file.write(f"```text\n{prompt}\n```\n\n")
            file.write("### 模型输出\n\n")
            file.write(f"```text\n{answer}\n```\n\n")
            file.write("### 简短分析\n\n")
            file.write("待填写。\n\n")
            file.flush()

        file.write("## 耗时汇总\n\n")
        file.write(f"- 模型加载耗时：`{load_seconds:.2f} 秒`\n")
        file.write(f"- 5 题生成总耗时：`{total_generation_seconds:.2f} 秒`\n")
        file.write(f"- 运行总耗时：`{load_seconds + total_generation_seconds:.2f} 秒`\n\n")
        file.write("| 问题 | 标题 | 生成耗时 |\n")
        file.write("| --- | --- | --- |\n")
        for qid, title, generation_seconds in summary_rows:
            file.write(f"| {qid} | {title} | {generation_seconds:.2f} 秒 |\n")

    print("=" * 60)
    print(f"Load time: {load_seconds:.2f} seconds")
    print(f"Generation time: {total_generation_seconds:.2f} seconds")
    print(f"Total measured time: {load_seconds + total_generation_seconds:.2f} seconds")
    print(f"Done. Results saved to {output_path}")


if __name__ == "__main__":
    main()
