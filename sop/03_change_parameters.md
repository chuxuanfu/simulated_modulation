# SOP-03 · 修改参数与受控扫描

## 每次修改前

写下假设，例如“保持 Rs，16QAM 改为 64QAM：谱宽大致不变，但相同 Eb/N0 下 BER 通常恶化”。明确保持不变的是样点 SNR、Es/N0、Eb/N0、平均功率还是峰值功率。

## 最小扫描示例

```matlab
setup
records = cell(1,3);
mods = {'QPSK','16QAM','64QAM'};
for k = 1:numel(mods)
    p = sm.defaultConfig('basic');
    p.Modulation = mods{k};
    p.Seed = 100 + k;
    w = generate_waveform(p);
    records{k} = struct('Modulation',mods{k},'Metrics',w.metrics);
end
sm.writeJSON(fullfile(sm.root(),'reports','modulation_scan.json'),records);
```

此扫描用于观察波形指标；不同种子意味着不同载荷。如果要严格控制同一比特源，应在低层映射实验中显式共享比特，并按各调制 k 值处理长度。

## 必须联动的参数

- NR：带宽、SCS、NSizeGrid、BWP、PRB 范围；UL DFT 预编码还限制连续资源和变换长度。
- Wi-Fi：带宽、MCS、空间流、天线数、编码方式、RU；APEP 更改后重新计算 PSDU。
- BLE：Mode 与包类型；ChannelIndex 与白化/RF 中心频率；SPS 与真实符号率。
- Thread：信道与 RF 频率、PSDU 总长度与应用载荷、FCS。
- 重采样：实际滤波重采样、时长、样点数与新的字段索引。

## 结果比较

统一画图的频率轴、功率单位、窗函数和统计区间。峰值归一化的两条波形并不保证平均功率相同；相同平均功率也不保证相同削顶风险。

## 验收

只在基线通过后解释变化；如果某个组合非法，保留错误并调整配置，不把失败样本从报告中悄悄删除。
