# SOP-06 · 复现、归档与版本控制

## 需要保存

- 本项目版本与源码快照，最好记录 Git commit 或 `PROJECT_SHA256.json`。
- MATLAB release、工具箱版本、操作系统；保存 environment.json。
- 完整参数、种子、原始 w.iq、导出增益和实际导出 IQ。
- 接收原始 IQ 与接收机设置；不能只保存截屏。
- 对齐/裁剪/归一化/重采样/滤波步骤；每步保留输入输出的关系。
- 实验记录中的测量定义、阈值和失败样本。

## 目录建议

```text
experiment_20260929_wifi_evm/
  intent.md
  source_config.json
  tx_bundle/
  rx_capture/
  instrument_settings/
  analysis/
  conclusion.md
```

项目 `generate_waveform` 自动生成独立目录；`reports/` 中同名课程图可能被重跑更新，重要结果请复制到独立实验归档。

## 内存与文件大小预算

N=Fs*T，复数 double 每样点每通道约 16 字节；cf32 为 8 字节；ci16 为 4 字节。生成器还会保留资源格、编码缓存和数组副本，峰值内存可能明显高于最终文件大小。

例如 100 MS/s、1 秒、2 通道，仅 double IQ 就约 3.2 GB。初次调参优先几毫秒/少量包，不直接生成长时间宽带 MIMO 波形。

## 重现判断

同软件版本与参数首先追求逐样点一致；跨版本时记录差异来源，并以帧结构、频谱、已知数据恢复和实验指标复核。硬件采集由于噪声和时钟状态通常不会逐样点一致。

官方网页和 API 会变化。项目保存引用标题、URL、访问日期与用途；原始标准全文从官方渠道获取，并按实验使用的 release/edition 固定版本。
