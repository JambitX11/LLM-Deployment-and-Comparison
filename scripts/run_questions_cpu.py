import argparse
import json
import sys
from datetime import datetime
from pathlib import Path

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
    parser.add_argument("--max_new_tokens", type=int, default=128)
    parser.add_argument("--limit", type=int, default=None, help="Run only the first N questions.")
    return parser.parse_args()


def load_questions(path, limit):
    question_path = Path(path)
    with question_path.open("r", encoding="utf-8") as file:
        questions = json.load(file)

    if not isinstance(questions, list) or not questions:
        raise ValueError(f"Question file is empty or invalid: {question_path}")

    return questions[:limit] if limit is not None else questions


def write_header(file, model_name, model_path, question_file, max_new_tokens):
    file.write(f"# {model_name} 批量测试结果\n\n")
    file.write(f"- 运行时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    file.write(f"- 模型路径：`{model_path}`\n")
    file.write(f"- 问题文件：`{question_file}`\n")
    file.write(f"- max_new_tokens：`{max_new_tokens}`\n\n")


def main():
    args = parse_args()
    config = MODEL_REGISTRY[args.model]
    model_path = args.model_path or config["default_path"]
    output_path = Path(args.output or f"results/raw_outputs/{args.model}_all_questions.md")
    output_path.parent.mkdir(parents=True, exist_ok=True)

    try:
        questions = load_questions(args.questions, args.limit)
    except Exception as exc:
        print(f"[ERROR] Failed to read questions: {exc}", file=sys.stderr)
        sys.exit(1)

    print(f"[INFO] Loading {config['name']} from {model_path}")
    print("[INFO] This may take several minutes on CPU.")

    try:
        tokenizer, model = config["load_model"](model_path)
    except Exception as exc:
        print(f"[ERROR] Failed to load model: {exc}", file=sys.stderr)
        print("Check whether the model has been downloaded to /mnt/data and whether memory is enough.", file=sys.stderr)
        sys.exit(1)

    with output_path.open("w", encoding="utf-8") as file:
        write_header(file, config["name"], model_path, args.questions, args.max_new_tokens)

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
                answer = config["generate_answer"](tokenizer, model, prompt, args.max_new_tokens)
            except Exception as exc:
                answer = f"[ERROR] Failed to generate answer: {exc}"
                print(answer, file=sys.stderr)

            print(answer)

            file.write(f"## 问题 {qid}：{title}\n\n")
            file.write(f"- 测试能力：{ability}\n\n")
            file.write("### 输入问题\n\n")
            file.write(f"```text\n{prompt}\n```\n\n")
            file.write("### 模型输出\n\n")
            file.write(f"```text\n{answer}\n```\n\n")
            file.write("### 简短分析\n\n")
            file.write("待填写。\n\n")
            file.flush()

    print("=" * 60)
    print(f"Done. Results saved to {output_path}")


if __name__ == "__main__":
    main()
