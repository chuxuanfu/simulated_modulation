# 无线调制与波形实验室 · Simulated Modulation

本项目把**理解原理 → MATLAB 生成 → 接收验证 → IQ 导出 → 仪器实验**连成一条可复现的路径。教程为中文，代码中的物理量使用明确单位，图表使用英文轴名以避免字体兼容问题。

**先打开 `START_HERE.html`，或阅读 [快速开始](docs/00_start.md)。** HTML 手册完全离线可读；官方参考资料的外部链接需要联网。

## 第一遍只执行这些命令

在 MATLAB 的 Command Window 中执行，不是在 macOS 终端中执行：

```matlab
cd(fullfile(getenv('HOME'),'simulated_modulation'))
setup
check_environment
run_all('core')
```

Windows 或 MATLAB Online 请将第一行改成实际解压目录。基础课程仅需要 MATLAB；协议课程需要对应工具箱。确认基础测试通过后：

```matlab
run_tests('all')
p = sm.defaultConfig('wifi_he');
p.MCS = 4;
w = generate_waveform(p);
```

`generated/` 中会出现一个独立实验目录，包含原始 MATLAB 数据、每路浮点 IQ、整数 IQ、SigMF 元数据、参数清单和六联分析图。每次生成使用新目录。

## 覆盖范围

| 路线 | 已提供的生成能力 | 依赖 |
|---|---|---|
| 原理基础 | BPSK、QPSK、8PSK、16/64/256QAM、RRC、GFSK、半正弦 OQPSK | MATLAB |
| 多载波 | CP-OFDM、DFT-s-OFDM、循环前缀与均衡 | MATLAB |
| 扩频原理 | DSSS、FHSS、线性 chirp 教学实验 | MATLAB |
| Wi-Fi | non-HT OFDM、HT、VHT、HE SU、EHT 单用户、HE OFDMA、VHT 多天线 | WLAN Toolbox |
| 蓝牙 | BLE LE1M/LE2M/LE500K/LE125K；BR/EDR2M/EDR3M | Bluetooth Toolbox |
| Thread 所用物理层 | 2.4 GHz IEEE 802.15.4 OQPSK、MAC 头、FCS、信道 11–26 | Communications Toolbox |
| 蜂窝 | LTE 上/下行参考测量信道；NR FR1 上/下行，UL 可选 DFT 预编码 | LTE Toolbox、5G Toolbox |
| 实验支撑 | AWGN、频偏、IQ 失衡、多径 FIR、削顶、重采样、共存混合、导出读回 | 重采样另需 Signal Processing Toolbox |
| 可视化仿真 | 自动构建 Simulink IQ 播放模型 | Simulink，可选 |

**生成标准 PHY 波形不等于建立真实网络。** 默认 Wi-Fi PSDU 为随机数据，NR 下行是 PDSCH+DM-RS 测试波形，Thread 示例不包含 Thread 安全与组网。BLE 默认包含工具箱生成的广播 PDU/CRC；其他 BLE 模式的 `phy-test` 明确只作 PHY 测试。每份导出的 `Scope` 都标注这些边界。

这不是所有标准版本的完整协议栈，也不是认证测试系统。NB-IoT、2G/3G、NR FR2、Wi-Fi DSSS/CCK、UWB、完整 LoRa 和网络级调度没有在本版实现；扩展入口见 [高级路线](docs/09_advanced.md)。

## 阅读顺序

1. [快速开始](docs/00_start.md) 与 [安装 SOP](sop/01_install.md)
2. [IQ、采样和通信链路](docs/01_foundations.md)
3. [调制与脉冲成形](docs/02_modulations.md)
4. [OFDM、编码与资源分配](docs/03_ofdm_coding.md)
5. [四类协议的区别](docs/04_protocols.md)
6. [完整实验课程](docs/06_labs.md)：每课包含命令、观察、验收、练习
7. [参数配方与 API](docs/05_recipes.md)
8. [测量方法](docs/07_measurement.md) 与 [仪器导入 SOP](sop/04_instruments.md)
9. [排错](docs/08_troubleshooting.md)、[高级路线](docs/09_advanced.md)、[练习答案](docs/11_glossary_answers.md)
10. [官方资料索引](resources/REFERENCES.md) 与 [交付验证状态](reports/VALIDATION.md)

## 目录

- `src/+sm/`：生成器、基础算法、测量、导出工具，统一命名空间 `sm`。
- `examples/`：15 个实验、Simulink 模型构建器、自定义实验模板。
- `tests/`：有通过/失败/跳过区分的自动检查。
- `configs/`：可直接加载的 JSON 实验配方。
- `docs/`：原理、教程、参数、排错。
- `sop/`：执行顺序、验收表、仪器流程、实验记录模板。
- `resources/`：官方资料目录、独立参考图、已知向量。
- `reports/`：当前交付验证记录；MATLAB 执行后产生本机环境和测试报告。
- `generated/`：你运行 MATLAB 后生成的波形。交付时不会把未运行的协议结果冒充实际生成结果。
- `tools/`：可选的 Python IQ 检查、文档构建、独立数值复核。

## 版本与验证说明

项目 1.0.0；以 MATLAB R2023b+ 接口为设计基线，建议使用 R2024b 或更新版本并安装匹配的工具箱。在线 MathWorks 文档会滚动到新版本，请优先以本机 `doc` 对应版本为准。

交付机器未发现可执行的 MATLAB/Octave，**没有宣称 MATLAB 或专有工具箱运行测试通过**。已实施的静态语法检查、独立数学与格式验证记录在 `reports/VALIDATION.md`。首次在你的 MATLAB 中运行测试是实验验收的一部分；缺失依赖记为 SKIP，不算通过。

工程为原创教学代码；MathWorks、IEEE、3GPP、Bluetooth SIG 等官方资料保留原链接，不复制受限标准全文。项目运行不需要 Python；只有重建离线手册或执行附加检查才需要 Python。
