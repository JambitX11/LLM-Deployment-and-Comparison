# 可复制运行命令

以下命令主要用于 ModelScope Notebook 的 Terminal。

## 1. 克隆本项目命令

```bash
cd /mnt/workspace
git clone https://github.com/JambitX11/LLM-Deployment-and-Comparison.git
cd LLM-Deployment-and-Comparison
```

## 2. 环境安装命令

```bash
pip install -U pip setuptools wheel
pip install torch==2.3.0+cpu torchvision==0.18.0+cpu --index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt
```

## 3. 下载模型命令

```bash
cd /mnt/data
git clone https://www.modelscope.cn/qwen/Qwen-7B-Chat.git
git clone https://www.modelscope.cn/ZhipuAI/chatglm3-6b.git
git clone https://www.modelscope.cn/baichuan-inc/Baichuan2-7B-Chat.git
```

可选 Baichuan Base 模型：

```bash
cd /mnt/data
git clone https://www.modelscope.cn/baichuan-inc/Baichuan2-7B-Base.git
```

## 4. 运行 Qwen

```bash
python scripts/run_qwen_cpu.py --prompt "请说出以下两句话区别在哪里？1、冬天：能穿多少穿多少 2、夏天：能穿多少穿多少"
```

指定模型路径：

```bash
python scripts/run_qwen_cpu.py --model_path /mnt/data/Qwen-7B-Chat --max_new_tokens 128 --prompt "你好，请简单介绍你自己。"
```

## 5. 运行 ChatGLM3

```bash
python scripts/run_chatglm3_cpu.py --prompt "他知道我知道你知道他不知道吗？这句话里，到底谁不知道？"
```

指定模型路径：

```bash
python scripts/run_chatglm3_cpu.py --model_path /mnt/data/chatglm3-6b --max_new_tokens 128 --prompt "你好，请简单介绍你自己。"
```

## 6. 运行 Baichuan

```bash
python scripts/run_baichuan_cpu.py --prompt "请解释下面对话中每个“意思”的不同含义：甲：你这是什么意思？乙：没什么意思，就是意思意思。甲：你这就不够意思了。乙：小意思，小意思。"
```

如果使用 Base 模型：

```bash
python scripts/run_baichuan_cpu.py --model_path /mnt/data/Baichuan2-7B-Base --prompt "你好，请简单介绍你自己。"
```

## 7. 每个测试问题的运行示例

### 问题 1

```bash
python scripts/run_qwen_cpu.py --prompt "请说出以下两句话区别在哪里？1、冬天：能穿多少穿多少 2、夏天：能穿多少穿多少"
python scripts/run_chatglm3_cpu.py --prompt "请说出以下两句话区别在哪里？1、冬天：能穿多少穿多少 2、夏天：能穿多少穿多少"
python scripts/run_baichuan_cpu.py --prompt "请说出以下两句话区别在哪里？1、冬天：能穿多少穿多少 2、夏天：能穿多少穿多少"
```

### 问题 2

```bash
python scripts/run_qwen_cpu.py --prompt "请解释这句话中两个“谁都看不上”的区别：单身狗产生的原因有两个，一是谁都看不上，二是谁都看不上。"
python scripts/run_chatglm3_cpu.py --prompt "请解释这句话中两个“谁都看不上”的区别：单身狗产生的原因有两个，一是谁都看不上，二是谁都看不上。"
python scripts/run_baichuan_cpu.py --prompt "请解释这句话中两个“谁都看不上”的区别：单身狗产生的原因有两个，一是谁都看不上，二是谁都看不上。"
```

### 问题 3

```bash
python scripts/run_qwen_cpu.py --prompt "他知道我知道你知道他不知道吗？这句话里，到底谁不知道？"
python scripts/run_chatglm3_cpu.py --prompt "他知道我知道你知道他不知道吗？这句话里，到底谁不知道？"
python scripts/run_baichuan_cpu.py --prompt "他知道我知道你知道他不知道吗？这句话里，到底谁不知道？"
```

### 问题 4

```bash
python scripts/run_qwen_cpu.py --prompt "明明明明明白白白喜欢他，可她就是不说。明明和白白谁喜欢谁？"
python scripts/run_chatglm3_cpu.py --prompt "明明明明明白白白喜欢他，可她就是不说。明明和白白谁喜欢谁？"
python scripts/run_baichuan_cpu.py --prompt "明明明明明白白白喜欢他，可她就是不说。明明和白白谁喜欢谁？"
```

### 问题 5

```bash
python scripts/run_qwen_cpu.py --prompt "请解释下面对话中每个“意思”的不同含义：甲：你这是什么意思？乙：没什么意思，就是意思意思。甲：你这就不够意思了。乙：小意思，小意思。"
python scripts/run_chatglm3_cpu.py --prompt "请解释下面对话中每个“意思”的不同含义：甲：你这是什么意思？乙：没什么意思，就是意思意思。甲：你这就不够意思了。乙：小意思，小意思。"
python scripts/run_baichuan_cpu.py --prompt "请解释下面对话中每个“意思”的不同含义：甲：你这是什么意思？乙：没什么意思，就是意思意思。甲：你这就不够意思了。乙：小意思，小意思。"
```
