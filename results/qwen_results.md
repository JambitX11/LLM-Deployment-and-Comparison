# Qwen-7B-Chat 测试结果

原始输出文件：[results/raw_outputs/qwen_all_questions.md](raw_outputs/qwen_all_questions.md)

Qwen-7B-Chat 的模型加载耗时为 3.37 秒，5 题生成总耗时为 192.79 秒，运行总耗时为 196.16 秒。在本次 CPU 环境中，Qwen 的整体运行较稳定，回答格式清楚，中文表达自然。

| 问题 | 截图 | 生成耗时 | 简短分析 |
| --- | --- | --- | --- |
| 问题 1 | `screenshots/qwen1.png` | 45.43 秒 | 能识别冬天多穿保暖，但没有准确指出夏天语境中通常是尽量少穿。 |
| 问题 2 | `screenshots/qwen2.png` | 27.53 秒 | 没有抓住“自己看不上别人/别人看不上自己”的双关。 |
| 问题 3 | `screenshots/qwen3.png` | 35.27 秒 | 多层逻辑解释混乱，结论不稳定。 |
| 问题 4 | `screenshots/qwen4.png` | 19.64 秒 | 未能完成断句和指代解析，回答为上下文不足。 |
| 问题 5 | `screenshots/qwen5.png` | 64.92 秒 | 对“意思”的多义解释较完整，是 Qwen 表现最好的一题。 |

总体来看，Qwen 在运行效率和一词多义理解方面表现较好，但对双关、特殊断句和嵌套逻辑的处理仍有明显不足。
