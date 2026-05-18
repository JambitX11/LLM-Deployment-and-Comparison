# 第三次作业：ModelScope 开源大语言模型部署与横向对比

姓名：蒋昊沄 
学号：2450333  
课程：人工智能导论  
GitHub 项目链接：[https://github.com/JambitX11/LLM-Deployment-and-Comparison](https://github.com/JambitX11/LLM-Deployment-and-Comparison)

## 1. 实验目的

本次实验的目的是在 ModelScope/魔搭平台上部署并测试开源大语言模型，了解大语言模型在云端 Notebook 环境中的基本部署流程，并通过统一的中文测试问题比较不同模型在中文表达、语义理解、逻辑推理和上下文理解方面的表现差异。

## 2. 实验平台与环境

- 实验平台：ModelScope/魔搭 Notebook
- 运行环境：CPU Notebook
- 代码目录：`/mnt/workspace/LLM-Deployment-and-Comparison`
- 模型目录：`/mnt/data/`
- Python 版本：待填写
- 主要依赖：`transformers`、`modelscope`、`torch`、`sentencepiece`、`accelerate` 等

【此处插入截图：ModelScope 登录或资源页面】

【此处插入截图：CPU Notebook 启动页面】

## 3. 模型选择

本次实验计划测试以下模型：

| 模型 | 参数规模 | 模型目录 | 选择原因 |
| --- | --- | --- | --- |
| Qwen-7B-Chat | 7B | `/mnt/data/Qwen-7B-Chat` | 中文能力较强，适合中文问答测试。 |
| ChatGLM3-6B | 6B | `/mnt/data/chatglm3-6b` | 常见中文对话模型，适合与 Qwen 对比。 |
| Baichuan2-7B-Chat/Base | 7B | `/mnt/data/Baichuan2-7B-Chat` | 中文开源模型，可用于横向比较。 |

说明：若 CPU 资源不足导致某个模型无法完整运行，需要在本节或第 8 节中如实说明。

## 4. 部署流程

### 4.1 打开 Terminal

在 ModelScope Notebook 中打开 Terminal，用于安装依赖、下载模型、克隆项目和运行测试脚本。

【此处插入截图：Terminal 打开页面】

### 4.2 克隆 GitHub 项目

先把本项目克隆到 `/mnt/workspace/`，后续 `pip install -r requirements.txt` 和脚本运行都在项目目录中执行。

```bash
cd /mnt/workspace
git clone https://github.com/JambitX11/LLM-Deployment-and-Comparison.git
cd LLM-Deployment-and-Comparison
```

【此处插入截图：git clone 本 GitHub 仓库成功页面】

### 4.3 安装依赖

进入项目目录后，执行以下命令安装 CPU 版本 PyTorch 和项目依赖：

```bash
pip install -U pip setuptools wheel
pip install torch==2.3.0+cpu torchvision==0.18.0+cpu --index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt
```
![1779101623202](image/hw3_学号_姓名/pip1.png)

【此处插入截图：pip install 依赖成功页面】

### 4.4 下载模型

模型下载到 `/mnt/data/`，不提交到 GitHub：

```bash
cd /mnt/data
git clone https://www.modelscope.cn/qwen/Qwen-7B-Chat.git
git clone https://www.modelscope.cn/ZhipuAI/chatglm3-6b.git
git clone https://www.modelscope.cn/baichuan-inc/Baichuan2-7B-Chat.git
```
![1779099606105](image/hw3_学号_姓名/gitQwen.png)

![1779099837456](image/hw3_学号_姓名/gitChat.png)

![1779100551210](image/hw3_学号_姓名/gitBaichuan.png)

【此处插入截图：git clone 模型成功页面】

### 4.5 运行测试脚本

示例：

```bash
python scripts/run_qwen_cpu.py --prompt "请说出以下两句话区别在哪里？1、冬天：能穿多少穿多少 2、夏天：能穿多少穿多少"
python scripts/run_chatglm3_cpu.py --prompt "他知道我知道你知道他不知道吗？这句话里，到底谁不知道？"
python scripts/run_baichuan_cpu.py --prompt "请解释下面对话中每个“意思”的不同含义：甲：你这是什么意思？乙：没什么意思，就是意思意思。甲：你这就不够意思了。乙：小意思，小意思。"
```

## 5. 测试问题设计

本次实验使用 5 个中文问题，覆盖语境反差、歧义句、嵌套逻辑、指代关系和一词多义。

| 编号 | 测试问题 | 测试能力 |
| --- | --- | --- |
| 1 | 冬天和夏天“能穿多少穿多少”的区别 | 季节语境、反讽和常识理解 |
| 2 | 两个“谁都看不上”的区别 | 歧义句和幽默理解 |
| 3 | “他知道我知道你知道他不知道吗？” | 多层逻辑推理 |
| 4 | “明明明明明白白白喜欢他...” | 断句和指代关系理解 |
| 5 | “意思”在对话中的不同含义 | 一词多义和语境理解 |

## 6. 问答测试结果

### 6.1 Qwen-7B-Chat

【此处插入截图：Qwen 运行结果】

模型输出：待填写，将实际运行结果粘贴在此处。

简短分析：待填写。

### 6.2 ChatGLM3-6B

【此处插入截图：ChatGLM3 运行结果】

模型输出：待填写，将实际运行结果粘贴在此处。

简短分析：待填写。

### 6.3 Baichuan2-7B

【此处插入截图：Baichuan 运行结果】

模型输出：待填写，将实际运行结果粘贴在此处。

简短分析：待填写。

## 7. 横向对比分析

请根据实际运行结果填写下表。

| 对比维度 | Qwen-7B-Chat | ChatGLM3-6B | Baichuan2-7B | 分析说明 |
| --- | --- | --- | --- | --- |
| 中文表达流畅度 | 待填写 | 待填写 | 待填写 | 待填写 |
| 语义歧义理解 | 待填写 | 待填写 | 待填写 | 待填写 |
| 多层逻辑推理 | 待填写 | 待填写 | 待填写 | 待填写 |
| 指代关系理解 | 待填写 | 待填写 | 待填写 | 待填写 |
| 一词多义和语境理解 | 待填写 | 待填写 | 待填写 | 待填写 |
| 回答稳定性 | 待填写 | 待填写 | 待填写 | 待填写 |
| 综合表现 | 待填写 | 待填写 | 待填写 | 待填写 |

综合分析：待填写。请结合具体模型输出说明差异，不要只写主观结论。

## 8. 实验中遇到的问题与解决方法

| 问题 | 原因分析 | 解决方法 |
| --- | --- | --- |
| CPU 推理速度较慢 | 7B 模型参数量较大，CPU 计算资源有限 | 降低 `--max_new_tokens`，只测试必要问题，并等待模型输出 |
| 模型加载失败 | 模型文件未下载完整或路径错误 | 检查 `/mnt/data/` 下模型目录，并使用 `--model_path` 指定正确路径 |
| 依赖版本冲突 | 不同模型依赖的 `transformers` 或 `pydantic` 版本不同 | 按 `requirements.txt` 和文档命令重新安装依赖 |
| 内存不足 | CPU Notebook 内存不足以加载 7B 模型 | 尝试重启环境、减少同时加载的模型，或在报告中说明限制 |

实际问题记录：待填写。

## 9. 总结

本次实验完成了 ModelScope 平台上的开源大语言模型部署流程，并使用统一中文测试问题对不同模型进行了横向比较。通过实验可以观察到，不同模型在中文表达、歧义理解、逻辑推理和语境理解方面存在差异。

最终结论：待填写。请根据真实实验结果总结哪个模型综合表现更好，以及原因。

## 10. GitHub 项目链接

GitHub 仓库链接：待填写

【此处插入截图：GitHub 仓库首页】

【此处插入截图：results 或 report 页面】
