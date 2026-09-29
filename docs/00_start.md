# 00 · 从这里开始

## 你最后会得到什么

你将能解释一份 IQ 数据表示什么、改变调制参数会改变什么、如何选择实验波形，以及如何把 MATLAB 的结果可靠交给仪器。学习顺序不要求你先读完通信原理教材。

一个完整实验的最小闭环是：确定问题 → 固定参数 → 生成已知数据 → 画图 → 接收或核对结构 → 导出 → 读回 → 记录结论。不要只凭“频谱看起来像”判断生成正确。

## 第一次运行：约 30–60 分钟

1. 安装/打开 MATLAB。在 Home → Add-Ons 或 MathWorks 安装器中查看已装产品。有 MATLAB 使用权限不代表每个工具箱也已授权。
2. 在 MATLAB 当前文件夹定位到 `~/simulated_modulation`。`~` 在操作系统文件路径中表示家目录；MATLAB 脚本里优先使用 `fullfile(getenv('HOME'),...)`。
3. 运行 `setup`。它只添加本会话路径，不修改全局 `startup.m` 或永久搜索路径。
4. 运行 `check_environment`，打开 `reports/environment.json`。Present=true 只表示入口存在，实际调用才验证许可证可用。
5. 运行 `run_tests('core')`。必须没有 FAIL。如果报错，先读 [排错](08_troubleshooting.md)。
6. 运行 `lab01_iq_sampling` 和 `lab02_constellation_rrc`。查看 `reports/figures/`。
7. 运行下面的 QPSK 实验，找到新建的 `generated/basic_...` 目录。

```matlab
p = sm.defaultConfig('basic');
p.Modulation = 'QPSK';
p.SymbolRateHz = 1e6;
p.SamplesPerSymbol = 8;
w = generate_waveform(p);
```

应该得到 8 MS/s 的复数基带。基带中心是 0 Hz；现在没有向空气或设备发射任何信号。

## 第二次运行：得到你的目标协议

先检查对应工具箱，再选一项：

```matlab
w = generate_waveform(sm.defaultConfig('wifi_he'));
w = generate_waveform(sm.defaultConfig('ble'));
w = generate_waveform(sm.defaultConfig('thread'));
w = generate_waveform(sm.defaultConfig('lte_dl'));
w = generate_waveform(sm.defaultConfig('nr_dl'));
```

每次只运行你需要的一行。要一次生成全部已支持预设，使用 `run_all('all')`，但先做 `run_tests('all')`。完整测试中 SKIP 表示功能缺失，FAIL 表示已有入口但运行出错，需要解决。

## 怎样打开输出

- `overview.png`：时域 I/Q、包络、PSD、时间样点散点、瞬时频率、时频图。
- `waveform.mat`：`w.iq` 是生成器原始幅度；`iqExport` 是统一缩放到峰值 0.8 的导出数据；`exportGain` 是乘数。
- `manifest.json`：采样率、RF 中心频率意图、通道数、持续时间、种子、作用范围、导出增益和读回误差。
- `channel_01.sigmf-data`：复数 float32，小端，每个样点先 I 后 Q，无文件头。
- `channel_01.sigmf-meta`：配套 SigMF 元数据。
- `channel_01.ci16`：复数 int16，小端，反量化除以 32767。

普通音频播放器无法正确播放 IQ。不要把它当立体声音频 WAV 导入设备。

## 最低验收

- 核对生成的 `fs` 与 manifest 一致。
- 核对采样点数：`size(w.iq,1)`；时长是点数除以采样率。
- 检查复数数据非全零、没有 NaN/Inf。
- 确认读回误差落在导出脚本的阈值内。
- 对 Wi-Fi non-HT、BLE、NR 原理链路分别运行 lab07、lab08、lab10；Thread 运行 lab09 检查 FCS 与时长。
- 读 Scope。不要把物理层测试包当成可以连接手机、基站或 Thread 边界路由器的完整系统。

## 学习节奏

| 阶段 | 内容 | 产出 |
|---|---|---|
| 1 | lab01–03，IQ、星座、RRC、噪声 | 能说清 sample/symbol/bit 的区别 |
| 2 | lab04–06，OFDM、恒包络、失真 | 能解释星座和频谱为什么变化 |
| 3 | lab07–10，协议帧与接收 | 能核对实际 PHY 包与资源格 |
| 4 | lab11–13，PAPR、文件格式、扩频 | 能准备可复现实验文件 |
| 5 | lab14–15，混合信号、OFDMA，仪器 SOP | 能设计具体实验并记录限制 |

不要把阅读速度当进度：每一阶段至少自己修改一个参数，并在运行前写下预期变化。
