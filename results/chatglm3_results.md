# ChatGLM3-6B 测试结果

原始输出文件：[results/raw_outputs/chatglm3_all_questions.md](raw_outputs/chatglm3_all_questions.md)

ChatGLM3-6B 的模型加载耗时为 0.86 秒，5 题生成总耗时为 3853.97 秒，运行总耗时为 3854.83 秒。它加载很快，但 CPU 生成阶段非常慢，是本次实验中运行成本最高的模型。

| 问题 | 截图 | 生成耗时 | 简短分析 |
| --- | --- | --- | --- |
| 问题 1 | `screenshots/glm1.png` | 446.52 秒 | 能解释冬天多穿，但夏天仍解释为多穿散热，语境理解不准确。 |
| 问题 2 | `screenshots/glm2.png` | 1169.42 秒 | 回答很长，但没有抓住“谁看不上谁”的视角反转。 |
| 问题 3 | `screenshots/glm3.png` | 805.07 秒 | 将问题解释为悖论，没有直接解决嵌套逻辑关系。 |
| 问题 4 | `screenshots/glm4.png` | 397.53 秒 | 能意识到句子模糊，但判断摇摆。 |
| 问题 5 | `screenshots/glm5.png` | 1035.43 秒 | 能解释部分“意思”，但角色和语义对应不够准确。 |

总体来看，ChatGLM3 的中文表达完整，但回答冗长且推理准确性一般。在 CPU Notebook 中，它的生成耗时明显高于 Qwen 和 Baichuan。
