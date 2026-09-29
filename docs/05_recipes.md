# 05 · 参数配方与项目 API

以下代码均在 `setup` 之后执行。先使用 `sm.generate(p)` 在内存中验证；需要保存完整实验时用 `generate_waveform(p)`。

## A. 用统一接口生成

```matlab
p = sm.defaultConfig('basic');
p.Modulation = '64QAM';
p.SymbolRateHz = 2e6;
p.SamplesPerSymbol = 8;
p.Rolloff = 0.25;
w = generate_waveform(p);
```

结果采样率 16 MS/s，理想 RRC 支撑约 2.5 MHz。改变 Rs 改变时间和带宽；只增大 SPS 在相同 Rs 下提高采样密度。

严格参数合并可捕获拼写错误：

```matlab
p = sm.configure('wifi_he',struct('MCS',4,'PayloadBytes',1024));
w = generate_waveform(p);
```

## B. Wi-Fi 配方

```matlab
p = sm.defaultConfig('wifi_vht');
p.BandwidthMHz = 80;
p.MCS = 5;
p.PayloadBytes = 1024;
p.CenterFrequencyHz = 5.21e9;
w = generate_waveform(p);
```

中心频率仅是实验计划。具体信道/带宽组合必须与接收仪器设置相符。

```matlab
% 两路发射波形，保留各路相对幅度
p = sm.defaultConfig('wifi_vht');
p.NumTransmitAntennas = 2;
p.NumSpaceTimeStreams = 2;
w = generate_waveform(p);
size(w.iq)
```

```matlab
% Wi-Fi 7 的 4096QAM 实验：需要 EHT 支持和合法 MCS 配置
p = sm.defaultConfig('wifi_eht');
p.BandwidthMHz = 80;
p.MCS = 12;
p.PayloadBytes = 1500;
w = generate_waveform(p);
```

高阶 MCS 是可选扩展配方；先通过 EHT 默认预设测试，再使用本机文档核对支持范围。320 MHz 会显著提高内存需求。

## C. BLE 四种模式

```matlab
p = sm.defaultConfig('ble');
p.ChannelIndex = 38;
p.CenterFrequencyHz = sm.bleFrequency(38);
w = generate_waveform(p); % LE1M 默认有效广播
```

```matlab
p = sm.defaultConfig('ble');
p.Mode = 'LE125K';
p.PayloadKind = 'phy-test';
p.ChannelIndex = 0;
p.CenterFrequencyHz = sm.bleFrequency(0);
p.TestMessageBits = 512;
w = generate_waveform(p);
```

第二例只适合 PHY 波形测试，不含有效链路层语义。LE2M 和 LE500K 用相同方法修改 Mode。

## D. 经典蓝牙

```matlab
p = sm.defaultConfig('bt_classic');
p.Mode = 'EDR3M';
p.PacketType = 'DH1';
p.PayloadBytes = 20;
w = generate_waveform(p);
```

使用不同包类型前查看 `doc bluetoothWaveformConfig`。不要假定任意载荷长度对所有包类型都合法。

## E. Thread PHY

```matlab
p = sm.defaultConfig('thread');
p.Channel = 20;
p.CenterFrequencyHz = (2405+5*(p.Channel-11))*1e6;
p.PayloadBytes = 64;
w = generate_waveform(p);
disp(w.details.PHYConfig)
```

需要自己的裸 MAC 载荷时，编辑/复制 `sm.generateThread` 的 `payload` 部分，仍让 `sm.mac802154` 计算 FCS；不要把包含 FCS 的完整帧再作为 payload 套一层头。若已有抓取的完整 PSDU，应直接用 `sm.bytesToBits` 与 `lrwpanWaveformGenerator`，并设置真实 PSDULength。

## F. LTE 和 5G NR

```matlab
p = sm.defaultConfig('lte_dl');
p.NumSubframes = 10;
w = generate_waveform(p);
```

```matlab
p = sm.defaultConfig('nr_dl');
p.Modulation = '64QAM';
p.TargetCodeRate = 0.5;
p.PRBSet = 10:39;
w = generate_waveform(p);
```

这只改变 PDSCH 调制/分配，不代表某个指定 MCS 索引。如果实验必须对应标准 MCS 表，需要同步设置调制阶数和目标码率。

```matlab
p = sm.defaultConfig('nr_ul');
p.TransformPrecoding = true;
p.PRBSet = 0:47; % 连续 48 PRB，避免 51 PRB 含不支持的变换因子
w = generate_waveform(p);
```

带宽、SCS、NSizeGrid 必须成套设置。FR1 常见起步组合可选 20 MHz/30 kHz/51 PRB；本版对这些组合不内置完整 3GPP 表，非法组合由官方生成器明确报错。不要只把 BandwidthMHz 改为 100 而继续沿用其他默认值并称为满带宽波形。

## G. 添加失真

```matlab
p = sm.defaultConfig('basic');
w = sm.generate(p);
[w.iq,info] = sm.impair(w.iq,w.fs,struct( ...
    'AddNoise',true,'SNRdB',25,'CFOHz',5000, ...
    'IQGainImbalanceDB',1,'IQPhaseErrorDeg',3));
w.details.Impairments = info;
w.meta.Scope = [w.meta.Scope '; deliberately impaired'];
folder = tempname(fullfile(sm.root(),'generated'));
sm.exportBundle(w,folder,0.8);
sm.plotWaveform(w,fullfile(folder,'overview.png'));
```

sm.impair 的 SNR 是全记录平均功率相对复噪声功率，包含空闲区，不是自动换算的 Eb/N0。多径模型接受离散 FIR 抽头，例如 `Taps=[1 zeros(1,7) 0.3]`，这表示第二径延迟 8 样点。尾部被截断并记录在 info 中；对尾部敏感时先补零。

## H. 仪器采样率适配

```matlab
w = sm.generate(sm.defaultConfig('ble'));
u = sm.resampleWaveform(w,20e6);
folder = tempname(fullfile(sm.root(),'generated'));
sm.exportBundle(u,folder,0.8);
```

需要 Signal Processing Toolbox。只修改 fs 数字会把时频轴一起改错，必须真正重采样。降采样前确认占用频谱不会被抗混叠滤波器切掉；重采样后的 `details` 中原始 PacketSamples/PHYPacket 仍是原始生成参考，不适合直接切割新采样序列。

## I. JSON 配方

```matlab
w = generate_waveform(fullfile(sm.root(),'configs','wifi_he_20mhz.json'));
```

JSON 只列出覆盖参数，其余使用默认值。不接受拼错的未知字段。使用新协议或未知字段时会明确报错。可用 `sm.writeJSON` 保存自己的完整配置。

## J. 对象结构与单位

| 字段 | 含义 |
|---|---|
| w.iq | Nsample × Nchannel 复数 double，生成器原始幅度 |
| w.fs | Hz，真实采样率 |
| w.config | 用户可复现参数 |
| w.meta | 通用元数据及作用范围 |
| w.details | 协议配置对象、已知比特、资源格等参考 |
| w.metrics | 顶层 generate_waveform 添加的原始波形测量 |

`SubcarrierSpacingKHz` 单位 kHz、`BandwidthMHz` 单位 MHz，其他带 Hz/Sec 的字段按名称。MATLAB 资源数组通常从 1 开始索引，而协议 PRB、slot、ChannelIndex 多从 0 开始；不要互换。

## K. 函数查阅

在 MATLAB 中使用 `help sm.generate`、`edit sm.generateNR`、`doc nrWaveformGenerator`。先读小的适配器，再进入工具箱内部。研究代码时始终保留一个未修改的默认测试作为对照。
