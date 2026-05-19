# ModelScope 云平台部署步骤

本文档记录在 ModelScope/魔搭 Notebook 中完成本作业的推荐流程。所有命令默认在 Notebook 的 Terminal 中运行。

## 1. 登录 ModelScope

1. 打开 ModelScope 官网。
2. 使用账号登录。
3. 进入 Notebook 或云端开发环境页面。
4. 选择合适的 CPU 资源启动 Notebook。

建议截图：登录或资源页面、CPU Notebook 启动页面。

## 2. 打开 Terminal

进入 Notebook 后，打开 Terminal。后续安装依赖、下载模型、克隆项目和运行脚本都在 Terminal 中完成。

建议截图：Terminal 打开页面。

## 3. 在 `/mnt/workspace` 克隆 GitHub 仓库

以下命令使用本作业的 GitHub 仓库地址。

```bash
cd /mnt/workspace
git clone https://github.com/JambitX11/LLM-Deployment-and-Comparison.git
cd LLM-Deployment-and-Comparison
```

建议截图：本项目 `git clone` 成功页面。

## 4. 安装 Python 依赖

克隆项目并进入项目目录后，先升级基础工具：

```bash
pip install -U pip setuptools wheel
```

CPU 版本 PyTorch 单独安装，不写入 `requirements.txt`：

```bash
pip install torch==2.3.0+cpu torchvision==0.18.0+cpu --index-url https://download.pytorch.org/whl/cpu
```

然后安装项目依赖：

```bash
pip install -r requirements.txt
```

如果 Qwen 报错 `cannot import name 'DisjunctiveConstraint' from 'transformers'`，说明依赖版本不兼容，重新执行：

```bash
bash scripts/install_deps_cpu.sh
```

建议截图：`pip install` 成功页面。

## 5. 在 `/mnt/data` 下载模型

模型文件较大，只保存在云平台 `/mnt/data/`，不要提交到 GitHub。

```bash
cd /mnt/data
git clone https://www.modelscope.cn/qwen/Qwen-7B-Chat.git
```

测试完 Qwen 后，如果空间不足，可以删除 Qwen，再下载 ChatGLM3：

```bash
rm -rf /mnt/data/Qwen-7B-Chat
cd /mnt/data
git clone https://www.modelscope.cn/ZhipuAI/chatglm3-6b.git
```

测试完 ChatGLM3 后，如果空间不足，可以删除 ChatGLM3，再下载 Baichuan：

```bash
rm -rf /mnt/data/chatglm3-6b
cd /mnt/data
git clone https://www.modelscope.cn/baichuan-inc/Baichuan2-7B-Chat.git
```

如果需要使用 Baichuan2-7B-Base：

```bash
cd /mnt/data
git clone https://www.modelscope.cn/baichuan-inc/Baichuan2-7B-Base.git
```

建议截图：模型 `git clone` 成功页面。

## 6. 运行测试脚本

如果不想逐条复制命令，可以直接使用仓库中的批量脚本：

```bash
bash scripts/install_deps_cpu.sh
bash scripts/download_models.sh qwen
bash scripts/run_all_tests.sh qwen
```

其中 `qwen` 可以替换为 `chatglm3` 或 `baichuan`。云平台空间有限时，推荐下载一个模型、测试一个模型、必要时删除后再下载下一个模型。

5 个测试问题保存在 `prompts/test_questions.json`。批量测试脚本会读取这个文件，单个模型只加载一次，然后按顺序输出 5 个问题的结果。

Qwen 示例：

```bash
python scripts/run_qwen_cpu.py --prompt "请说出以下两句话区别在哪里？1、冬天：能穿多少穿多少 2、夏天：能穿多少穿多少"
```

ChatGLM3 示例：

```bash
python scripts/run_chatglm3_cpu.py --prompt "他知道我知道你知道他不知道吗？这句话里，到底谁不知道？"
```

Baichuan 示例：

```bash
python scripts/run_baichuan_cpu.py --prompt "请解释下面对话中每个“意思”的不同含义：甲：你这是什么意思？乙：没什么意思，就是意思意思。甲：你这就不够意思了。乙：小意思，小意思。"
```

如果 CPU 推理速度过慢，可以降低回答长度：

```bash
python scripts/run_qwen_cpu.py --max_new_tokens 128 --prompt "请说出以下两句话区别在哪里？1、冬天：能穿多少穿多少 2、夏天：能穿多少穿多少"
```

建议截图：每个模型至少一张运行结果截图。若时间允许，每个问题都保存截图。

## 7. 保存结果和截图

1. 将 Terminal 中的模型输出复制到 `results/` 对应文件。
2. 将截图保存到 `screenshots/`。
3. 将对比分析填写到 `results/comparison_table.md`。
4. 将最终报告填写到 `report/hw3_学号_姓名.md`，并把文件名改成自己的学号和姓名。
5. 把更新后的 `results/`、`screenshots/`、`report/` 提交到 GitHub。

提交示例：

```bash
git status
git add README.md requirements.txt .gitignore scripts prompts results screenshots report docs
git commit -m "Add LLM deployment homework framework"
git push
```
