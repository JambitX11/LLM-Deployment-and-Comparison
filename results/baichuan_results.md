# Baichuan2-7B-Chat 测试结果

原始输出文件：[results/raw_outputs/baichuan_all_questions.md](raw_outputs/baichuan_all_questions.md)

Baichuan2-7B-Chat 的模型加载耗时为 100.20 秒，5 题生成总耗时为 200.43 秒，运行总耗时为 300.63 秒。它加载较慢，但生成速度较快，整体耗时接近 Qwen。

| 问题 | 截图 | 生成耗时 | 简短分析 |
| --- | --- | --- | --- |
| 问题 1 | `screenshots/baichuan1.png` | 23.41 秒 | 正确说明冬天多穿保暖、夏天少穿散热，表现较好。 |
| 问题 2 | `screenshots/baichuan2.png` | 88.46 秒 | 能意识到两个“谁都看不上”有差别，但没有明确说出标准双关解释。 |
| 问题 3 | `screenshots/baichuan3.png` | 11.78 秒 | 直接回答“他不知道”，结论较接近核心，但解释较简略。 |
| 问题 4 | `screenshots/baichuan4.png` | 18.34 秒 | 判断为明明喜欢白白，与更合理断句不一致。 |
| 问题 5 | `screenshots/baichuan5.png` | 58.44 秒 | 出现原题没有的新对话，分析发生偏题。 |

总体来看，Baichuan 速度表现较好，部分问题回答直接，但在复杂语境中容易自行扩写或偏离原题。
