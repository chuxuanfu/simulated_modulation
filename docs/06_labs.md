# 06 · 15 个循序实验

所有命令在项目根目录运行 `setup` 后执行。图像通常在 `reports/figures/`，部分完整波形图在 `reports/`，IQ 包在 `generated/`。下面的数值是理论预期或程序验收条件；交付并未把它们标成 MATLAB 实测结果。

## Lab 01 · IQ 与采样（MATLAB）

**问题：** 为什么一个复数信号可以区分正负频率？

运行 `r=lab01_iq_sampling`。I 是余弦，Q 是正弦；峰应在 +125 kHz。fs=1 MHz 时，+1.125 MHz 的离散样点与 +125 kHz 相同。

验收：PeakHz=125000，AliasingMaxError<1e-8。练习：给 Q 加负号，峰应镜像到 −125 kHz。记录改变的是频率方向，而非带宽。

## Lab 02 · 从 16QAM 波形恢复星座（MATLAB）

运行 `r=lab02_constellation_rrc`。左图画全部时间样点，右图画发射+匹配滤波后按正确时刻采样的点。

验收：无噪声 BER=0，EVM 很小但有限长 RRC 不保证精确为零。代码默认 12-symbol span、SPS=8，因此合计滤波延迟 96 样点。

练习：把抽样索引移动 1、2、4 点；EVM 如何变化？把 rolloff 改为 0.1 时，需要更长滤波器才能接近理想。不要把 BER=0 解读为模拟波形完全无误差。

## Lab 03 · BER 与 Eb/N0（MATLAB）

运行 `r=lab03_ber_awgn`。比较 BPSK、QPSK、16QAM。BPSK 和 Gray QPSK 的比特误码率理论曲线重合：`Pb=0.5*erfc(sqrt(Eb/N0))`。

验收：Eb/N0=0 dB 时 BPSK/QPSK BER 应在约 0.07865 附近；程序容差 0.003。低误码区可能观察到 0 个错误，不能称 BER=0；报告给出近似 95% 上界 3/Nbit。

练习：分别固定 Es/N0 与 Eb/N0 比较 QPSK。解释为什么两种比较看起来不同。本实验在符号域加噪声，不涉及过采样修正。

## Lab 04 · CP 足够与不足（MATLAB）

运行 `r=lab04_ofdm_cp`。CP=32 样点，对照最大延迟 8 与 48 样点的双径信道；使用已知 H 做均衡。

验收：短延迟 EVM 接近浮点误差（<1e-9%），长延迟 EVM>1%。练习：将 Ncp 增至 64，应改善第二种情况，但有效传输效率降低；解释速率损失。

## Lab 05 · GFSK 和半正弦 OQPSK（MATLAB）

运行 `r=lab05_gfsk_oqpsk`，看包络和瞬时频率。GFSK 包络误差应<1e-12；OQPSK 去除首尾后也接近单位包络。

练习：GFSK 的 BT 从 0.5 改到 0.3/0.8，h 从 0.5 改到 0.32。记录频谱与频率过渡的变化。此时生成的仍是教学波形，不能声称变成了完整蓝牙 BR 包。

## Lab 06 · 四种常见失真（MATLAB）

运行 `r=lab06_impairments`。四幅图分别为 AWGN、CFO、IQ 不平衡和削顶后的判决样点。

验收：AWGN 产生点云；CFO 随时间旋转；IQ 不平衡拉伸/倾斜；削顶导致非线性偏差和频谱外溢。默认 EVM 不消除增益/相位，方便看见全部人为失真。

练习：仅加固定 PhaseDeg，与 CFO 比较。单个复增益可以消除固定旋转，却不能消除整段随时间变化的频偏。

## Lab 07 · Wi-Fi 物理层回环（WLAN Toolbox）

运行 `r=lab07_wifi_receive`。生成一个 non-HT 包 → 用已知字段索引取 L-LTF → 估计信道 → 取 Data → 恢复 PSDU。

验收：BitErrors=0；图中恢复出数据子载波星座。此示例已知包开始时刻，没有模拟搜索未知 RF 包的同步过程。

练习：MCS=0 改为 4/6，观察星座；再加少量噪声。添加 CFO 之前，先实现/理解频偏估计，否则失效并不是调制映射器错了。

## Lab 08 · BLE 物理层和广播 PDU（Bluetooth Toolbox）

运行 `r=lab08_ble_receive`。读取默认广播包，经过理想接收器恢复位，再经过 LL 解码校验。

验收：BitErrors=0，LLStatus=Success。只把 PHY 比特恢复成功不能验证随机 CRC 有效，所以本课同时检查 LL 解码。

练习：改广播名称，对比包长；改 ChannelIndex 时同步改 fc；尝试接收端白化信道故意配错，说明为什么频谱仍正常但解码会错。

## Lab 09 · Thread 所用 802.15.4 帧（Communications Toolbox）

运行 `r=lab09_thread_frame`。查看 PSDU 字节、FCS 和包长。默认 PSDU=43 字节，名义发送时长 1.568 ms，加短成形尾部。

验收：CRC 的检查残余为 0；实际波形时长与名义值差<10 μs。该测试只检查 MAC/FCS/时长，没有独立的 802.15.4 无线接收解码器，因此仍需仪器/接收机完成互操作验证。

练习：PayloadBytes=16/64/116，画时长随载荷的关系；每增加一字节名义增加 32 μs。信道间隔 5 MHz 与实际信号带宽不是一回事。

## Lab 10 · 5G 资源格到比特（5G Toolbox）

运行 `r=lab10_nr_resource_grid`。该课以低层 API 显式建立 PDSCH 和 DM-RS，做 OFDM 调制、解调和解扰恢复。

验收：CodewordBitErrors=0、EVM<1e-8%。本课输入是未经过传输块信道编码的 codeword 测试位；不同于默认 `nr_dl` 完整生成器中启用的 DL-SCH 编码。这里检验的是映射链，不是 LDPC 解码性能。

练习：改变调制阶数和 PRB 分配，观察资源格；加一个已知复增益，补偿后恢复。下一步才能引入 DM-RS 信道估计和真实未知信道。

## Lab 11 · PAPR 与 DFT 预编码（MATLAB）

运行 `r=lab11_papr_dftspread`。比较同一块 QPSK 数据的 OFDM/DFT-s-OFDM，查看经验 CCDF。

验收：能解释 CCDF 表示功率超过阈值的比例；不把单次峰值当所有配置的理论界。此图按现有样点计算，连续时间峰值需要适当过采样才能更准确估计。

练习：改变激活子载波数、数据长度和调制，记录 PAPR 随机波动；讨论为了减少削顶要留下多少输出回退。

## Lab 12 · IQ 文件格式闭环（MATLAB）

运行 `r=lab12_export_import`。导出 float32/int16、元数据并读回；用 exportGain 恢复原始幅度。

验收：误差在量化容差内，float 文件为每复样点 8 字节，int16 文件为每复样点 4 字节。I/Q 交织为 I0,Q0,I1,Q1。

练习：若把样本率故意设成两倍，播放时长和所有频偏分别怎样变化？答案：时长减半、频率尺度翻倍。

## Lab 13 · 扩频、跳频和扫频（MATLAB）

运行 `r=lab13_dsss_fhss_chirp`。三张时频图分别表现较宽的 DSSS、阶梯跳频 FHSS、连续扫频 chirp。

验收：无噪声 DSSS 解扩误差为 0；31-chip 码的理想处理增益约 14.91 dB。代码并未使用 IEEE 标准码表、Bluetooth 跳频调度或完整 LoRa PHY。

练习：在解扩前加窄带单音，比较正确码与错误码相关结果。不要把处理增益直接当任何实际接收机的抗干扰保证。

## Lab 14 · 多协议共存混合（WLAN + Bluetooth + Communications + Signal Processing）

运行 `w=lab14_coexistence`。统一到 40 MS/s，Wi-Fi 在 DC，BLE 在 +12 MHz，802.15.4 在 −12 MHz，分量相对功率 0/−10/−15 dB。

验收：频谱中能分辨三部分，没有搬出 Nyquist 区间。当前放置是合成场景，不是自动匹配各标准信道表；分量功率按各自包含空闲的完整记录平均定义。

练习：让 BLE 向 Wi-Fi 内移动；另接一个受害者接收器测 PER/BER，再下结论。仅看到频谱重叠不能量化接收损失。

## Lab 15 · Wi-Fi OFDMA（WLAN Toolbox）

运行 `w=lab15_wlan_ofdma`。HE MU 20 MHz 配成九个 26-tone RU，每个用户独立载荷。

验收：生成器接受配置并输出非零波形；查看 `w.details.PHYConfig`。可以运行 `showAllocation(w.details.PHYConfig)` 检查资源分配。

练习：每次只修改一个用户 MCS/APEP；解释为什么物理包总时长与每个用户载荷之间要协调。

## 每课的实验记录格式

复制 [实验记录模板](../sop/07_record_template.md)。最少填写：问题、预测、输入参数、软件版本、输出目录、观察图、测量口径、结论、失败现象、下一步。优先写“在此配置和测量口径下观察到什么”，而不是“某技术永远更好”。
