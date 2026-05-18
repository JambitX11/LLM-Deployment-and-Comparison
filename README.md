# AI Introduction HW3: LLM Deployment and Comparison

本仓库用于《人工智能导论》第三次作业：在 ModelScope/魔搭平台部署并测试开源大语言模型，并对不同模型进行横向对比。

> 说明：本仓库只保存代码、运行说明、测试问题、结果模板、报告模板和截图说明，不保存任何大模型权重文件。模型权重应在 ModelScope 云平台下载到 `/mnt/data/`。

## 作业目标

1. 在 ModelScope 平台启动 Notebook 环境。
2. 下载并部署至少 2-3 个开源大语言模型。
3. 使用统一中文测试问题运行问答测试。
4. 记录模型输出、运行截图和部署截图。
5. 从中文表达、歧义理解、逻辑推理、指代关系、一词多义等角度进行横向对比。
6. 提交公开可访问的 GitHub 项目链接和作业报告。

## 实验平台与环境

- 平台：ModelScope/魔搭 Notebook
- 建议代码目录：`/mnt/workspace/LLM-Deployment-and-Comparison`
- 建议模型目录：`/mnt/data/`
- 运行方式：Terminal 命令行
- 推理环境：CPU
- Python：建议 3.8 或以上

CPU 环境推理 7B 级模型会比较慢，甚至可能因内存不足失败。若 CPU 资源不足，可以只运行较短问题、降低 `--max_new_tokens`，并在报告中如实说明。

## 测试模型

| 模型 | 默认本地路径 | 脚本 |
| --- | --- | --- |
| Qwen-7B-Chat | `/mnt/data/Qwen-7B-Chat` | `scripts/run_qwen_cpu.py` |
| ChatGLM3-6B | `/mnt/data/chatglm3-6b` | `scripts/run_chatglm3_cpu.py` |
| Baichuan2-7B-Chat/Base | `/mnt/data/Baichuan2-7B-Chat` | `scripts/run_baichuan_cpu.py` |

## 仓库结构

```text
LLM-Deployment-and-Comparison/
├── README.md
├── requirements.txt
├── .gitignore
├── scripts/
│   ├── run_qwen_cpu.py
│   ├── run_chatglm3_cpu.py
│   └── run_baichuan_cpu.py
├── prompts/
│   └── test_questions.md
├── results/
│   ├── qwen_results.md
│   ├── chatglm3_results.md
│   ├── baichuan_results.md
│   └── comparison_table.md
├── screenshots/
│   └── README.md
├── report/
│   └── hw3_学号_姓名.md
└── docs/
    ├── setup_modelscope.md
    ├── run_commands.md
    └── screenshot_checklist.md
```

## 快速开始

在 ModelScope Notebook 的 Terminal 中执行：

```bash
cd /mnt/workspace
git clone https://github.com/你的用户名/LLM-Deployment-and-Comparison.git
cd LLM-Deployment-and-Comparison

pip install -U pip setuptools wheel
pip install torch==2.3.0+cpu torchvision==0.18.0+cpu --index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt
```

## 模型下载命令

模型权重不要提交到 GitHub。请在云平台中下载到 `/mnt/data/`：

```bash
cd /mnt/data
git clone https://www.modelscope.cn/qwen/Qwen-7B-Chat.git
git clone https://www.modelscope.cn/ZhipuAI/chatglm3-6b.git
git clone https://www.modelscope.cn/baichuan-inc/Baichuan2-7B-Chat.git
```

如果 Baichuan2-7B-Chat 下载失败，也可以根据课程要求改用 Baichuan2-7B-Base，并在运行时指定：

```bash
python scripts/run_baichuan_cpu.py --model_path /mnt/data/Baichuan2-7B-Base --prompt "你好，请介绍你自己。"
```

## 运行脚本命令

```bash
python scripts/run_qwen_cpu.py --prompt "请说出以下两句话区别在哪里？1、冬天：能穿多少穿多少 2、夏天：能穿多少穿多少"

python scripts/run_chatglm3_cpu.py --prompt "他知道我知道你知道他不知道吗？这句话里，到底谁不知道？"

python scripts/run_baichuan_cpu.py --prompt "请解释“意思”一词在不同对话中的不同含义。"
```

可以通过 `--max_new_tokens` 控制回答长度：

```bash
python scripts/run_qwen_cpu.py --max_new_tokens 128 --prompt "明明明明明白白白喜欢他，可她就是不说。明明和白白谁喜欢谁？"
```

## 测试问题说明

统一测试问题放在 [prompts/test_questions.md](prompts/test_questions.md)。每个模型都应尽量回答同一组问题，便于横向比较。

测试重点包括：

- 中文表达流畅度
- 语义歧义理解
- 多层逻辑推理
- 指代关系理解
- 一词多义和语境理解
- 回答稳定性

## 横向对比总结

横向对比模板见 [results/comparison_table.md](results/comparison_table.md)。实际运行后，需要把三个模型的真实输出和截图补充到 `results/` 与 `report/` 中，不要虚构结果。

## 截图和报告位置

- 截图建议保存到 `screenshots/`，命名方式见 [docs/screenshot_checklist.md](docs/screenshot_checklist.md)。
- 单模型结果填写到 `results/qwen_results.md`、`results/chatglm3_results.md`、`results/baichuan_results.md`。
- 最终报告模板位于 [report/hw3_学号_姓名.md](report/hw3_学号_姓名.md)，提交前请改成自己的学号和姓名。
