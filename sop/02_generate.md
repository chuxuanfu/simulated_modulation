# SOP-02 · 生成一份可交付实验的 IQ

**输入：** 协议、实验目的、带宽/速率、调制、长度、RF 中心频率意图、种子。

## 操作

1. 复制最接近的 `configs/*.json` 或 `examples/custom_experiment.m`。
2. 先用默认配置生成一份基线，确认工具箱可用。
3. 一次只改一个主要维度：例如 MCS 或载荷长度；记录预测。
4. 调用 `w=generate_waveform(p)`。保存打印的输出目录。
5. 打开 manifest：检查 Protocol、Scope、Fs、点数、通道数、时长、Seed、ExportGain。
6. 打开 overview：时域不能全零；频谱不能意外越界；不把时间样点图当解调星座。
7. 运行该协议对应的回环实验或结构检查。
8. 检查每路 float/int16 的 RoundTripMaxError。
9. 将参数和结论写入实验记录；保留 waveform.mat，不仅保留图片。

## 输出包清单

- waveform.mat
- manifest.json
- overview.png
- 每路 channel_XX.sigmf-data、channel_XX.sigmf-meta、channel_XX.ci16
- 实验记录（由你填写设备与实际测量结果）

## 验收阈值

float32 导出读回最大误差<1e-6；int16 最大复数误差≤sqrt(2)/32767。所有 IQ 样点有限，通道数正确。导出峰值默认 0.8；未经标定不填写实际 RF dBm。

## 禁止的快捷方式

不要只改采样率标签适配仪器；不要把矩阵所有列展平成一条信号；不要忽略 CRC/Scope；不要为了图好看而删除原始包头/尾部后继续称其为完整包。
