# 官方资料与阅读路径

核对日期：2026-09-29。以下以 MathWorks、标准组织、项目官方仓库为来源；在线文档可能滚动到新 release。代码以已存在多年的稳定接口为主，但**未在本机 MATLAB 实跑**，不能用网页存在代替运行验证。

## 先读什么

1. 先完成本项目基础教程和 lab01–06，不需要先读完整标准。
2. 目标 Wi-Fi：MW11/12 → MW13/14/15 → MW19 接收。
3. 目标 Bluetooth：ST03 → MW21/23/24 → MW22；经典蓝牙看 MW26/27。
4. 目标 Thread：ST04 → MW29/30 → ST05/06。
5. 目标 cellular：LTE 看 MW09/10；NR 看 MW01/04/05/08，再进入 ST01。
6. 导出和仪器：ST07 与本项目仪器 SOP。

## 已核对的主资料

| ID | 官方资料 | 具体用途 |
|---|---|---|
| MW01 | [nrWaveformGenerator](https://www.mathworks.com/help/5g/ref/nrwaveformgenerator.html) | NR 上/下行生成、输出资源格与实际采样率 |
| MW02 | [nrDLCarrierConfig](https://www.mathworks.com/help/5g/ref/nrdlcarrierconfig.html) | 下行载波/BWP/信道配置 |
| MW03 | [nrULCarrierConfig](https://www.mathworks.com/help/5g/ref/nrulcarrierconfig.html) | 上行载波配置 |
| MW04 | [nrWavegenPDSCHConfig](https://www.mathworks.com/help/5g/ref/nrwavegenpdschconfig.html) | PDSCH 调制、码率、资源分配和 DataSource |
| MW05 | [nrWavegenPUSCHConfig](https://www.mathworks.com/help/5g/ref/nrwavegenpuschconfig.html) | PUSCH 与 TransformPrecoding |
| MW06 | [5G NR Downlink Vector Waveform Generation](https://www.mathworks.com/help/5g/ug/downlink-carrier-waveform-generation.html) | 扩展到 SSB/PDCCH/多 BWP 的官方完整例程 |
| MW07 | [nrPDSCHDecode](https://www.mathworks.com/help/5g/ref/nrpdschdecode.html) | 符号解映射/解扰；不是 LDPC 传输块解码器 |
| MW08 | [nrOFDMDemodulate](https://www.mathworks.com/help/5g/ref/nrofdmdemodulate.html) | 资源格恢复与采样率设置 |
| MW09 | [lteRMCDLTool](https://www.mathworks.com/help/lte/ref/ltermcdltool.html) | LTE 下行参考波形 |
| MW10 | [lteRMCULTool](https://www.mathworks.com/help/lte/ref/ltermcultool.html) | LTE 上行参考波形与 SamplingRate |
| MW11 | [wlanWaveformGenerator](https://www.mathworks.com/help/wlan/ref/wlanwaveformgenerator.html) | PPDU 生成，包数/空闲/过采样 |
| MW12 | [WLAN Waveform Generation](https://www.mathworks.com/help/wlan/gs/waveform-generation.html) | 不同 Wi-Fi 代际的官方起步例程 |
| MW13 | [wlanHESUConfig](https://www.mathworks.com/help/wlan/ref/wlanhesuconfig.html) | HE SU 与 APEP/MCS |
| MW14 | [wlanVHTConfig](https://www.mathworks.com/help/wlan/ref/wlanvhtconfig.html) | VHT、空间流、PSDULength |
| MW15 | [wlanEHTMUConfig](https://www.mathworks.com/help/wlan/ref/wlanehtmuconfig.html) | EHT 单/多用户配置 |
| MW16 | [wlanEHTUser](https://www.mathworks.com/help/wlan/ref/wlanehtuser.html) | 每用户的 MCS/APEP/空间流 |
| MW17 | [802.11be Waveform Generation](https://www.mathworks.com/help/wlan/ug/802-11be-waveform-generation.html) | EHT RU/MRU 与 MIMO 示例，注意其引用标准版本 |
| MW18 | [getPSDULength](https://www.mathworks.com/help/wlan/ref/wlanhesuconfig.getpsdulength.html) | HE 实际 PSDU 长度 |
| MW19 | [wlanNonHTDataRecover](https://www.mathworks.com/help/wlan/ref/wlannonhtdatarecover.html) | non-HT 位恢复；第二个输出为均衡符号 |
| MW20 | [wlanHEMUConfig](https://www.mathworks.com/help/wlan/ref/wlanhemuconfig.html) | HE OFDMA 资源分配 |
| MW21 | [bleWaveformGenerator](https://www.mathworks.com/help/bluetooth/ref/blewaveformgenerator.html) | BLE PHY，输入包含 PDU 与 CRC；速率/白化参数 |
| MW22 | [bleIdealReceiver](https://www.mathworks.com/help/bluetooth/ref/bleidealreceiver.html) | 理想同步 BLE 接收 |
| MW23 | [bleLLAdvertisingChannelPDU](https://www.mathworks.com/help/bluetooth/ref/blelladvertisingchannelpdu.html) | 广播 PDU 生成 |
| MW24 | [Bluetooth LE Link Layer Packet Generation and Decoding](https://www.mathworks.com/help/bluetooth/ug/bluetooth-le-link-layer-packet-generation-and-decoding.html) | LL 生成/校验流程 |
| MW25 | [Bluetooth LE Waveform Generation and Transmission Using SDR](https://www.mathworks.com/help/bluetooth/ug/bluetooth-low-energy-transmitter.html) | 官方发送流程；采样率计算及 LL 输出接 PHY |
| MW26 | [bluetoothWaveformGenerator](https://www.mathworks.com/help/bluetooth/ref/bluetoothwaveformgenerator.html) | BR/EDR 包生成 |
| MW27 | [bluetoothWaveformConfig](https://www.mathworks.com/help/bluetooth/ref/bluetoothwaveformconfig.html) | BR/EDR 合法模式、包型与长度 |
| MW28 | [bluetoothIdealReceiver](https://www.mathworks.com/help/bluetooth/ref/bluetoothidealreceiver.html) | 后续经典蓝牙接收扩展入口 |
| MW29 | [lrwpanWaveformGenerator](https://www.mathworks.com/help/comm/ref/lrwpanwaveformgenerator.html) | IEEE 802.15.4 OQPSK/UWB 波形入口，R2023a 起 |
| MW30 | [lrwpanOQPSKConfig](https://www.mathworks.com/help/comm/ref/lrwpanoqpskconfig.html) | Band、SamplesPerChip、PSDULength、SampleRate |
| MW31 | [Wireless Waveform Generator](https://www.mathworks.com/help/comm/ref/wirelesswaveformgenerator-app.html) | 图形 App、协议工具箱依赖、导出 |
| MW32 | [Create Waveforms Using Wireless Waveform Generator App](https://www.mathworks.com/help/comm/ug/create-waveforms-using-wireless-waveform-generator-app.html) | App 操作路线 |
| ST01 | [3GPP TS 38.211 / ETSI 138 211 V18.4.0](https://www.etsi.org/deliver/etsi_ts/138200_138299/138211/18.04.00_60/) | 公开 NR 物理信道与调制规范目录；固定版本参考，非宣称最新版 |
| ST02 | [Bluetooth Core 6.2 LE Radio Physical Layer](https://www.bluetooth.com/wp-content/uploads/Files/Specification/HTML/Core-62/out/en/low-energy-controller/radio-physical-layer-specification.html) | LE 物理层参数；具体实验按目标 Core 版本固定 |
| ST03 | [Bluetooth LE Primer](https://www.bluetooth.com/bluetooth-le-primer/) | Bluetooth SIG 官方原理入门 |
| ST04 | [OpenThread Primer](https://openthread.io/guides/thread-primer) | Thread 网络与 PHY 的层次关系 |
| ST05 | [OpenThread radio.h](https://github.com/openthread/openthread/blob/main/include/openthread/platform/radio.h) | 250 kbit/s、信道 11–26 等实现常量 |
| ST06 | [OpenThread Porting Guide](https://openthread.io/guides/porting) | 从 PHY 实验扩展到真实协议栈 |
| ST07 | [SigMF Specification](https://sigmf.org/) | IQ 数据类型、端序和元数据结构 |

补充核对：[HT 配置对象](https://www.mathworks.com/help/wlan/ref/wlanhtconfig.html)、[WLAN 采样率](https://www.mathworks.com/help/wlan/ref/wlansamplerate.html)。

## 怎样得到本机版本资料

在 MATLAB 中执行 `doc wlanWaveformGenerator`、`doc nrWaveformGenerator` 等，读取与你安装版本匹配的参数和例程。在线页面出现 R2026b 等标签，不代表你的旧版本具备该页面所有新增属性。

## 标准全文与授权

IEEE 802.11 / IEEE 802.15.4 全文请通过 IEEE 官方标准平台、学校/企业图书馆或标准授权渠道获取。本项目不打包可能受访问许可限制的标准全文。3GPP 文档可从官方/ETSI 发布目录获取；Bluetooth Core 可从 Bluetooth SIG 入口按目标版本查阅；Thread 规范和 OpenThread 实现文档要区分。

本地中文教程是原创讲解，足以完成本版实验；官方链接用于确认标准细节、版本边界和扩展能力，不是用一串链接替代教程。没有把第三方下载站作为必需依赖。

## 接口核对中已特别处理的问题

- BLE 生成函数的 message 需包含 PDU/CRC；采用 LL 生成器输出时不重复追加 CRC。
- LE Coded 的信息速率标签不等于 GFSK 空口符号率；经典 EDR 也不能按 2/3 Mbit/s 直接算 SPS。
- lrwpanOQPSKConfig 的 SampleRate 从对象读取，不混用教学串行 chip SPS 约定。
- HE/EHT/VHT 的 APEP 与 PSDU 长度分别取正确接口。
- wlanNonHTDataRecover 的第二个输出才是均衡符号。
- NR 实际 Fs 从返回资源信息读取；下行测试预设明确关闭 SSB/PDCCH。
