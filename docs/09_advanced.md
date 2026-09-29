# 09 · 进阶实验与扩展边界

## 1. 使用真正的应用数据

PHY 生成器的输入层次不同：WLAN 输入 PSDU，BLE 输入包含 PDU/CRC 的位序列，LTE/NR 生成器处理传输块/测试源，802.15.4 输入 PSDU。

如果从文件读取 payload，先明确字节到比特顺序，再交给正确层次。不要将包含 MAC 头的完整帧再作为应用载荷重复封装，也不要假定所有系统都 LSB-first。项目的 `sm.bytesToBits` 专用于明确需要八位组 LSB-first 的场景。

WLAN 有效 MAC 构造可从 `wlanMACFrameConfig` 与 `wlanMACFrame` 学起；具体聚合、FCS、地址和 PSDU 长度还需配合 PHY 配置。先使用官方示例完成 MAC 生成/解析回环，再集成到本项目。

## 2. 从 MATLAB 波形到真实 Thread 网络

需要 OpenThread 或等效协议栈处理 6LoWPAN、IPv6、MLE、路由、帧计数器、加密和密钥，以及符合时序的 802.15.4 收发器。建议先用真实 Thread 开发板和抓包工具建立两个节点，再将捕获的完整 PHY/MAC 数据引入波形分析。

本项目的裸 MAC 数据帧没有这些网络语义；不能通过更换 PANID 或 RF 频道获得入网功能。Thread 网络模拟和 MATLAB PHY 实验可以相互辅助，但二者验证目标不同。[OpenThread 移植入口](https://openthread.io/guides/porting)

## 3. 接收器能力逐级增加

推荐顺序：已知开始时刻的无信道回环 → AWGN → 固定复增益 → 已知 FIR → 导频信道估计 → 未知包时刻 → CFO → 采样时钟偏差 → 时变多径 → RF 捕获。

每一级只引入一个未知量。例如 CFO 和定时都未知时直接调 EVM，很难定位错误。NR 可以沿官方 PDSCH throughput 示例加入 DL-SCH/LDPC、信道估计和 HARQ；WLAN 可以沿 packet recovery 示例加入包检测、频偏估计和字段恢复。保留官方示例原始版本作对照。

## 4. 信道模型

项目的 FIR 是可解释的确定性起点。更真实的实验可使用 nrTDLChannel/nrCDLChannel、WLAN TGax/TGac channel、Rayleigh/Rician 对象。每次加入对象都要保存路径延迟、平均路径增益、Doppler、随机种子、天线布局和归一化选项。

不能只把一个信道名称写成“室内”就认为所有室内实验都被代表。尤其要检查离散采样率、信道滤波延迟、输出尾部与接收端对齐。

## 5. 功放与失真

sm.impair 的限幅是最简单的硬削顶。更真实的功放实验需要 AM/AM、AM/PM、记忆效应、工作点、输入回退与测量带宽。可以先做无记忆多项式，再比较功率谱再生和 EVM。把同一原始波形按不同回退导出时，记录设备是否再次自动归一化。

## 6. 多天线与空间层

先生成两天线 VHT 波形，验证文件数与列数，再准备两路相干输出硬件。不要将两个独立 USB SDR 的默认本振相位视为可控。若实验只测单天线功放，可单独取一列，但这不再是完整 MIMO 系统验证。

## 7. 训练数据集

可用同一接口批量扫描 modulation/SNR/CFO/seed。为避免标签泄漏，训练/验证/测试应在随机种子、信道实例、设备或生成条件层面分离，不能只将同一长波形相邻切片随机打散。

给每条记录保存参数、波形长度、采样率、是否含空闲、功率归一化策略。分类器可能学到带宽、包长或采样率，而不是调制机理；应设计控制变量实验验证。

## 8. 本版尚未实现的族群

| 方向 | 下一步 | 为什么未用简化信号冒充 |
|---|---|---|
| NB-IoT | LTE Toolbox 的 NB-IoT PHY 示例 | 不同帧/子载波/重复结构 |
| NR FR2 | 5G Toolbox 的 FR2 载波和测试模型 | SCS、RB、SSB pattern、射频带宽约束不同 |
| 2G/3G | 对应 GSM/WCDMA 标准与支持接口 | 不能直接由 LTE 配置推出 |
| Wi-Fi 802.11b | WLAN non-HT DSSS/CCK 专用配置 | 不是当前 OFDM non-HT 路线 |
| UWB | lrwpanHRPConfig / lrwpanWaveformGenerator | 脉冲/采样率/测距字段与 OQPSK 不同 |
| 完整 LoRa | 符号映射、编码、交织、前导与接收链 | 单个 chirp 不等于 LoRa 帧 |
| 网络/应用仿真 | 协议栈或系统级网络仿真工具 | 离线 IQ 无法独立建立通信会话 |

## 9. 添加一个新的协议适配器

1. 在 `sm.defaultConfig` 定义参数与单位，选择低资源默认值。
2. 新建 `sm.generateX`，用 `sm.require` 检查入口。
3. 使用官方 API，取真实采样率，不依靠猜测。
4. 用 `sm.pack` 返回统一结构，Scope 写清实现到哪一层。
5. 在 `sm.generate` 添加分支，在 tests 添加生成与接收/结构测试。
6. 增加一个 JSON 配方、一个教程例子和官方资料条目。
7. 重新运行核心及协议测试，重新生成离线 HTML 手册。
