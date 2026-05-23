#let accent = rgb("#2563eb")
#let soft = rgb("#eff6ff")
#let ink = rgb("#111827")
#let muted = rgb("#6b7280")

#set document(
  title: "ModelScope 开源大语言模型部署与横向对比实验报告",
  author: "蒋昊沄",
)

#set page(
  paper: "a4",
  margin: (top: 2.1cm, bottom: 2cm, left: 2.25cm, right: 2.25cm),
  numbering: "1",
)

#set text(
  font: ("SimSun", "Microsoft YaHei", "Times New Roman"),
  size: 10.5pt,
  fill: ink,
  lang: "zh",
)

#set par(justify: true, leading: 0.7em, first-line-indent: (amount: 2em, all: true))
#set heading(numbering: "1.")
#set table(inset: 5pt, stroke: rgb("#d1d5db"))
#show raw: set text(font: ("Consolas", "Courier New"), size: 9pt)

#let note(body) = block(
  fill: soft,
  stroke: (left: 4pt + accent),
  inset: 10pt,
  radius: 4pt,
  width: 100%,
)[#body]

#let img(path, cap, width: 92%) = figure(
  image(path, width: width),
  caption: cap,
)

#let shot(path, title) = block[
  #image(path, width: 100%)
  #align(center)[#text(size: 8pt, fill: muted)[#title]]
]

#let answer-shots(prefix, files) = figure(
  stack(
    dir: ttb,
    spacing: 10pt,
    grid(
      columns: (1fr, 1fr),
      gutter: 8pt,
      shot(files.at(0), [#prefix 问题 1]),
      shot(files.at(1), [#prefix 问题 2]),
      shot(files.at(2), [#prefix 问题 3]),
      shot(files.at(3), [#prefix 问题 4]),
    ),
    align(center)[
      #box(width: 50%)[#shot(files.at(4), [#prefix 问题 5])]
    ],
  ),
  caption: [#prefix 五个问题运行截图],
)

#let metric-table = table(
  columns: (1.2fr, 1.1fr, 1.2fr, 1.1fr),
  align: center,
  table.header([模型], [模型加载耗时], [5 题生成总耗时], [运行总耗时]),
  [Qwen-7B-Chat], [3.37 秒], [192.79 秒], [196.16 秒],
  [ChatGLM3-6B], [0.86 秒], [3853.97 秒], [3854.83 秒],
  [Baichuan2-7B-Chat], [100.20 秒], [200.43 秒], [300.63 秒],
)

#align(center)[
  #v(2.2cm)
  #text(size: 23pt, weight: "bold", fill: accent)[ModelScope 开源大语言模型部署与横向对比实验报告]

  #v(1.2cm)
  #text(size: 20pt)[《人工智能导论》第三次作业]

  #v(4cm)
  #block(
    fill: rgb("#f8fafc"),
    stroke: rgb("#dbeafe"),
    radius: 8pt,
    inset: (x: 24pt, y: 18pt),
    width: 78%,
  )[
  #set text(size: 14pt)
  #table(
    columns: (1fr, 2.4fr),
    align: (right, left),
    stroke: none,
    inset: (x: 7pt, y: 10pt),
    [#text(weight: "bold")[姓名：]], [蒋昊沄],
    [#text(weight: "bold")[学号：]], [2450333],
    [#text(weight: "bold")[课程：]], [人工智能导论],
    [#text(weight: "bold")[项目链接：]], [#text(size: 11pt)[#link("https://github.com/JambitX11/LLM-Deployment-and-Comparison")[github.com/JambitX11/LLM-Deployment-and-Comparison]]],
  )
  ]

  #v(2cm)
  // #text(fill: muted)[本仓库不保存模型权重文件。模型权重在 ModelScope 云平台下载到 #raw("/mnt/data/")，代码运行目录为 #raw("/mnt/workspace/LLM-Deployment-and-Comparison")。]
]

#pagebreak()
#outline(title: [目录], indent: 1.2em)
#pagebreak()

= 实验目的

本次实验围绕 ModelScope/魔搭平台上的开源大语言模型部署与测试展开。实验目标是在云端 Notebook 环境中完成模型仓库下载、Python 依赖安装和命令行推理，并使用同一组中文测试问题比较不同模型在中文表达、语义歧义理解、多层逻辑推理、指代关系理解以及一词多义理解方面的表现。通过横向对比，可以更直观地观察不同开源大语言模型在相同任务下的能力差异和运行代价。

本实验测试了 Qwen-7B-Chat、ChatGLM3-6B 和 Baichuan2-7B-Chat 三个模型。测试问题并不只考察回答是否通顺，更关注模型能否理解中文中的特殊语境。例如，“冬天能穿多少穿多少”和“夏天能穿多少穿多少”字面一致，但实际语境含义相反；“谁都看不上”也可能因为主客体不同而产生幽默效果。这类问题能够较集中地暴露模型在中文语义理解上的差异。

= 实验平台与环境

实验在 ModelScope/魔搭平台的 CPU Notebook 环境中完成。项目代码通过 GitHub 克隆到 #raw("/mnt/workspace/LLM-Deployment-and-Comparison")，模型文件下载到 #raw("/mnt/data/")。由于云平台磁盘空间有限，三个模型没有同时保存在 #raw("/mnt/data/") 中，而是采用“下载一个模型、测试一个模型、保存结果和截图、必要时删除后再下载下一个模型”的方式完成实验。

#img("image/start0.png", [ModelScope Notebook 页面], width: 88%)

#img("image/start.png", [Notebook Terminal 页面], width: 88%)

项目仓库克隆过程如下图所示。克隆完成后，后续安装依赖、下载模型和运行测试脚本都在该项目目录下完成。

#img("image/clone.png", [克隆 GitHub 项目], width: 86%)

依赖安装通过仓库中的 #raw("scripts/install_deps_cpu.sh") 完成。该脚本安装 CPU 版本 PyTorch，并安装 #raw("transformers")、#raw("modelscope")、#raw("sentencepiece")、#raw("accelerate") 等推理所需依赖。实验过程中曾遇到 Qwen 相关依赖版本兼容问题，因此最终在脚本中固定了 #raw("transformers==4.33.3") 和 #raw("transformers_stream_generator==0.0.4")。

#img("image/pip.png", [依赖安装过程], width: 88%)

#img("image/pip1.png", [依赖安装完成], width: 88%)

= 模型选择

本实验选择了三个中文开源大语言模型：Qwen-7B-Chat、ChatGLM3-6B 和 Baichuan2-7B-Chat。它们都属于中文场景中较常见的开源对话模型，参数规模接近，适合在同一组测试问题上进行横向比较。

#table(
  columns: (1.1fr, 1.6fr, 1.5fr, 2.3fr),
  align: (left, left, left, left),
  table.header([模型], [本地模型目录], [推理脚本], [说明]),
  [Qwen-7B-Chat], [#raw("/mnt/data/Qwen-7B-Chat")], [#raw("scripts/run_qwen_cpu.py")], [中文能力较强，支持 #raw("chat") / #raw("chat_stream") 接口。],
  [ChatGLM3-6B], [#raw("/mnt/data/chatglm3-6b")], [#raw("scripts/run_chatglm3_cpu.py")], [典型中文对话模型，模型加载较快，但本次 CPU 生成耗时较长。],
  [Baichuan2-7B-Chat], [#raw("/mnt/data/Baichuan2-7B-Chat")], [#raw("scripts/run_baichuan_cpu.py")], [中文开源对话模型，输出速度较快，但部分问题存在偏题。],
)

模型下载截图如下。

#img("image/gitQwen.png", [Qwen 模型下载], width: 88%)

#img("image/gitChat.png", [ChatGLM3 模型下载], width: 88%)

#img("image/gitBaichuan.png", [Baichuan 模型下载], width: 88%)

= 实验方法

测试问题保存在 #raw("prompts/test_questions.json") 中，人工阅读版说明保存在 #raw("prompts/test_questions.md") 中。为了避免 CPU 环境下重复加载模型造成额外耗时，实验使用 #raw("scripts/run_questions_cpu.py") 对单个模型进行批量测试。脚本每次只加载一个模型，然后按顺序运行 5 个测试问题，并将输出写入 #raw("results/raw_outputs/") 下的 Markdown 文件。

三个模型的主要运行命令如下：

```bash
python scripts/run_questions_cpu.py --model qwen --max_new_tokens 256 --dtype auto --num_threads 4
python scripts/run_questions_cpu.py --model chatglm3 --max_new_tokens 256 --dtype auto --num_threads 4
python scripts/run_questions_cpu.py --model baichuan --max_new_tokens 256 --dtype auto --num_threads 4
```

实验问题覆盖五类中文能力。第一题考察模型能否理解同一句话在冬天和夏天的相反语境；第二题考察“谁都看不上”的双向歧义；第三题考察“知道/不知道”的多层逻辑；第四题考察“明明、白白、他、她”的断句和指代关系；第五题考察“意思”一词在不同语境中的多义解释。

= 仓库结构

本仓库按“脚本、测试问题、结果、截图、报告、文档”组织。代码和实验材料都保存在 GitHub 中，模型权重不进入仓库，而是在云平台运行时下载到 #raw("/mnt/data/")。这样的组织方式既能满足作业提交中的公开仓库要求，也避免将大模型权重上传到 GitHub。

```text
LLM-Deployment-and-Comparison/
├── README.md
├── requirements.txt
├── scripts/
│   ├── install_deps_cpu.sh
│   ├── download_models.sh
│   ├── run_questions_cpu.py
│   ├── run_qwen_cpu.py
│   ├── run_chatglm3_cpu.py
│   └── run_baichuan_cpu.py
├── prompts/
│   ├── test_questions.md
│   └── test_questions.json
├── results/
│   ├── raw_outputs/
│   ├── qwen_results.md
│   ├── chatglm3_results.md
│   ├── baichuan_results.md
│   └── comparison_table.md
├── screenshots/
├── docs/
└── report/
    ├── 实验报告.md
    ├── 实验报告.typ
    └── 实验报告.pdf
```

#raw("scripts/") 目录保存依赖安装、模型下载和模型推理脚本。其中 #raw("run_questions_cpu.py") 是主要批量测试脚本，会读取 #raw("prompts/test_questions.json") 中的五个问题，并将输出写入 #raw("results/raw_outputs/")。#raw("results/") 目录保存整理后的单模型结果和横向对比表，#raw("screenshots/") 保存三组模型各五个问题的运行截图，#raw("report/") 保存 Markdown、Typst 和 PDF 形式的实验报告。

= 问答测试结果

从运行耗时看，三个模型差异明显。Qwen 加载和生成都比较稳定，Baichuan 加载较慢但生成速度较快，ChatGLM3 虽然加载最快，但生成阶段耗时远高于另外两个模型。

#metric-table

== Qwen-7B-Chat

Qwen-7B-Chat 的模型加载耗时为 3.37 秒，5 个问题生成总耗时为 192.79 秒，运行总耗时为 196.16 秒。从耗时看，Qwen 在本次 CPU 环境下运行相对顺利，五个问题中耗时最长的是“一词多义”问题，生成耗时为 64.92 秒。

#table(
  columns: (0.8fr, 1fr, 4.8fr),
  align: (center, center, left),
  table.header([问题], [生成耗时], [回答表现概述]),
  [问题 1], [45.43 秒], [能识别冬天应多穿，但对夏天解释为“多穿防晒和保持凉爽”，没有准确说出夏天语境中“能穿多少穿多少”常指尽量少穿。],
  [问题 2], [27.53 秒], [没有准确抓住两个“谁都看不上”分别表示“自己看不上别人”和“别人看不上自己”的幽默歧义。],
  [问题 3], [35.27 秒], [对多层“知道/不知道”关系解释混乱，没有给出稳定明确的逻辑结论。],
  [问题 4], [19.64 秒], [没能完成断句和指代解析，回答为上下文不足。],
  [问题 5], [64.92 秒], [对“意思”的多义解释较完整，能区分意图、敷衍、够朋友和小事等含义。],
)

#answer-shots(
  [Qwen],
  (
    "../screenshots/qwen1.png",
    "../screenshots/qwen2.png",
    "../screenshots/qwen3.png",
    "../screenshots/qwen4.png",
    "../screenshots/qwen5.png",
  ),
)

总体来看，Qwen 的中文表达比较自然，格式也较清楚，但在本组偏歧义、偏脑筋急转弯的问题上不够稳定。它对第五题的解释最好，能够较系统地列出“意思”的不同含义；但在第二题和第四题上没有抓住题目的关键语言现象，说明其对中文双关和非常规断句的鲁棒性仍有限。

== ChatGLM3-6B

ChatGLM3-6B 的模型加载耗时为 0.86 秒，5 个问题生成总耗时为 3853.97 秒，运行总耗时为 3854.83 秒。它加载很快，但生成极慢，尤其是第二题和第五题都超过 1000 秒。该现象说明在 CPU 环境下，模型加载速度和文本生成速度并不一定一致，生成阶段才是主要耗时来源。

#table(
  columns: (0.8fr, 1fr, 4.8fr),
  align: (center, center, left),
  table.header([问题], [生成耗时], [回答表现概述]),
  [问题 1], [446.52 秒], [能指出冬天多穿保暖，但夏天仍解释为“多穿散热”，没有准确理解夏天应尽量少穿。],
  [问题 2], [1169.42 秒], [回答很长，但没有抓住“自己看不上别人/别人看不上自己”的核心双关，解释偏向“要求过高”和“挑剔”。],
  [问题 3], [805.07 秒], [将问题解释成悖论，逻辑链条不够准确，没有直接回答谁不知道。],
  [问题 4], [397.53 秒], [识别到句子模糊，但对“明明”和“白白”的关系判断摇摆，结论不稳定。],
  [问题 5], [1035.43 秒], [能尝试解释不同“意思”，但部分角色和语义分配不够准确。],
)

#answer-shots(
  [ChatGLM3],
  (
    "../screenshots/glm1.png",
    "../screenshots/glm2.png",
    "../screenshots/glm3.png",
    "../screenshots/glm4.png",
    "../screenshots/glm5.png",
  ),
)

ChatGLM3 的回答风格偏解释型，常常会展开较长分析，但长回答没有必然带来更高准确率。第二题和第三题中，它给出了较多文字，却没有抓住题目真正考察的语言歧义和逻辑关系。在本次 CPU 环境中，ChatGLM3 的生成耗时远高于另外两个模型，因此从作业展示和实验效率角度看，它的运行成本较高。

== Baichuan2-7B-Chat

Baichuan2-7B-Chat 的模型加载耗时为 100.20 秒，5 个问题生成总耗时为 200.43 秒，运行总耗时为 300.63 秒。它的加载时间明显长于 Qwen 和 ChatGLM3，但生成速度较快，整体耗时接近 Qwen，远低于 ChatGLM3。

#table(
  columns: (0.8fr, 1fr, 4.8fr),
  align: (center, center, left),
  table.header([问题], [生成耗时], [回答表现概述]),
  [问题 1], [23.41 秒], [正确说明冬天多穿保暖、夏天少穿散热，是三者中对该题理解最准确的回答之一。],
  [问题 2], [88.46 秒], [能区分两个“谁都看不上”有不同侧重点，但仍没有明确说出“自己看不上别人”和“别人看不上自己”这一标准解释。],
  [问题 3], [11.78 秒], [直接回答“他不知道”，虽然解释较简略，但结论较接近题目核心。],
  [问题 4], [18.34 秒], [将关系判断为“明明喜欢白白”，与更合理的断句解释不一致。],
  [问题 5], [58.44 秒], [出现扩写和偏题，额外加入原问题没有出现的对话，导致解释准确性下降。],
)

#answer-shots(
  [Baichuan],
  (
    "../screenshots/baichuan1.png",
    "../screenshots/baichuan2.png",
    "../screenshots/baichuan3.png",
    "../screenshots/baichuan4.png",
    "../screenshots/baichuan5.png",
  ),
)

Baichuan 的优势在于回答速度较快，并且第一题和第三题的结论比较直接。但它在复杂语境中容易自行补充不存在的内容，第五题就是典型例子。对话中原本只有四句，它却额外生成“你真是太意思了”“谢谢你的意思”等内容，导致分析对象偏离原题。

= 横向对比分析

#table(
  columns: (1.2fr, 1.6fr, 1.7fr, 1.7fr),
  align: (left, left, left, left),
  table.header([对比维度], [Qwen-7B-Chat], [ChatGLM3-6B], [Baichuan2-7B-Chat]),
  [中文表达流畅度], [表达自然，条理清楚], [表达完整但偏冗长], [表达较流畅，但偶有偏题扩写],
  [语义歧义理解], [对双关题表现较弱], [长篇解释但未抓住核心双关], [能意识到含义不同，但解释不够精准],
  [多层逻辑推理], [逻辑链混乱], [将问题解释为悖论，未直接解决], [结论直接，但解释较简略],
  [指代关系理解], [未能完成断句], [判断摇摆，结论不清], [给出结论但方向错误],
  [一词多义理解], [表现最好，解释较全面], [能解释部分含义但角色分配不准], [出现额外扩写，偏离原对话],
  [运行效率], [加载快，生成较快], [加载快，生成极慢], [加载慢，生成较快],
)

从语言表达看，Qwen 和 ChatGLM3 都能生成比较完整的中文解释，Baichuan 的回答也通顺，但更容易偏离原题。若只看自然语言流畅度，三个模型都能达到基本可读水平；但本实验的问题并不只考察流畅度，更关注模型能否准确理解中文中的歧义和特殊句式。

在语义歧义理解方面，三个模型都没有完全答出第二题的标准双关解释。题目中的两个“谁都看不上”分别可以理解为“自己看不上别人”和“别人看不上自己”，这是中文幽默表达中的视角反转。Qwen 将其解释为“没有合适的人选”，ChatGLM3 解释为“要求过高”和“过于挑剔”，Baichuan 则解释为个人主观意愿和社会现实压力。它们都能感知两处表达可能不同，但没有准确抓住最核心的双向关系。

在多层逻辑推理方面，Baichuan 的回答最直接，指出“他不知道”；Qwen 和 ChatGLM3 都出现了较明显的逻辑混乱。Qwen 的回答中多次改变“知道”的对象，最后没有形成清楚结论。ChatGLM3 把问题解释为悖论，但题目更像嵌套认知关系解析，不一定需要上升为悖论。因此，该题反映出模型对嵌套逻辑的处理仍然容易受自然语言表面结构干扰。

在指代关系理解方面，三个模型表现都不理想。第四题需要先断句，再判断“白白喜欢他，可她就是不说”中的“她”更可能指白白。Qwen 直接表示上下文不足，ChatGLM3 的结论不稳定，Baichuan 则判断为明明喜欢白白。该题说明，当中文句子刻意去掉标点并重复使用相同汉字时，模型很容易无法正确还原句法结构。

在一词多义理解方面，Qwen 的表现最好，能够较准确地区分“意图”“敷衍表示”“不够朋友或不够诚意”“事情不大”等含义。ChatGLM3 也能解释部分含义，但对对话角色和具体语境的对应不够准确。Baichuan 则额外生成了原题没有出现的新对话，导致分析对象发生偏移。综合来看，一词多义题中 Qwen 的解释最贴近题目。

从运行效率看，Qwen 的综合体验最好，加载和生成都比较稳定。Baichuan 的加载耗时较长，但生成阶段较快，总体仍可接受。ChatGLM3 虽然加载最快，但生成阶段极慢，5 题总生成耗时超过 3800 秒，在 CPU Notebook 中使用成本最高。

= 实验中遇到的问题与解决方法

实验过程中最先遇到的是依赖版本兼容问题。Qwen-7B-Chat 在加载时曾出现 #raw("DisjunctiveConstraint") 无法从 #raw("transformers") 中导入的错误。这个问题并不是模型权重下载不完整，而是 #raw("transformers_stream_generator") 与 #raw("transformers") 的版本不匹配。最终通过固定 #raw("transformers==4.33.3")、#raw("transformers_stream_generator==0.0.4") 和 #raw("pydantic==1.10.13") 解决，并将这些依赖写入安装脚本，避免在云平台重复配置环境时再次出错。

第二个问题是 CPU 环境下模型推理容易给人“卡住”的感觉。模型加载完成后，终端会显示当前问题和 prompt，但普通 #raw("model.chat()") 通常要等完整回答生成完才返回，中间不会持续打印 token。因此终端长时间没有新输出，并不一定表示程序停止，也可能是模型正在逐 token 生成答案。为了解决这个观察困难，脚本加入了 #raw("--stream") 参数；当模型支持流式接口时，可以边生成边显示内容，更容易判断程序是在运行还是已经异常。

第三个问题是模型加载和文本生成的耗时差异很大。实验中出现过 checkpoint shards 很快加载到 100%，但真正生成回答仍然等待较久的情况。后来通过脚本记录模型加载耗时、每题生成耗时和总耗时，可以更清楚地区分到底是“加载慢”还是“生成慢”。同时，批量测试脚本改为单个模型只加载一次，然后连续回答五个问题，避免每个问题都重新加载模型造成额外开销。

第四个问题是精度和线程数对 CPU 推理速度的影响并不稳定。虽然低精度在 GPU 上通常能加速，但 CPU 是否支持 #raw("bfloat16") 或 #raw("float16") 加速取决于硬件本身；如果硬件支持不好，低精度反而可能更慢。实验中最终以 #raw("dtype auto") 作为主要设置，并根据模型尝试不同的 #raw("num_threads") 参数，用实际耗时而不是理论判断来选择运行配置。

最后一个问题是云平台磁盘空间有限。三个模型都属于 6B 到 7B 级别，模型文件较大，无法稳定地同时保存在 #raw("/mnt/data/") 中。因此实验采用单模型下载和测试流程：先下载一个模型，完成测试并保存输出和截图后，再删除该模型目录并下载下一个模型。这样既避免了空间不足，也使每个模型的测试过程更清晰。

总体来看，这些问题并没有阻止实验完成，但它们说明在 CPU Notebook 环境中部署大语言模型时，依赖版本、推理输出方式、硬件资源和模型文件管理都会影响实验体验。通过固定依赖、加入流式输出、记录耗时以及单模型下载测试，最终实验流程变得更稳定，也更便于复现和分析。

= 总结

本次实验完成了在 ModelScope 平台上部署并测试 Qwen-7B-Chat、ChatGLM3-6B 和 Baichuan2-7B-Chat 三个开源大语言模型的过程，并基于统一中文问题进行了横向比较。实验结果表明，三个模型都能进行基本中文问答，但在中文歧义、特殊断句、多层逻辑和指代关系问题上仍存在明显差异。

综合回答质量和运行效率看，Qwen-7B-Chat 在本次实验中整体表现较均衡。它的生成速度较快，一词多义解释较准确，但在歧义和指代题上仍会出错。Baichuan2-7B-Chat 的速度也较好，部分问题回答直接，但存在偏题和自行扩写现象。ChatGLM3-6B 的表达较完整，但 CPU 生成耗时过长，并且准确性没有明显优势。

因此，本实验的结论是：在当前 CPU Notebook 条件下，Qwen-7B-Chat 更适合作为作业展示模型；Baichuan2-7B-Chat 可以作为速度和回答风格的对照；ChatGLM3-6B 虽然能够运行，但在 CPU 环境中的生成效率较低。对于真实应用，如果希望获得更稳定和更快的大模型推理体验，仍然更适合使用 GPU 环境或更小规模的模型。
