# 08 · 排错手册

## 首先保存证据

在 MATLAB 中运行 `check_environment`，保存 `reports/environment.json`、出错文本、完整参数和触发问题的最小脚本。把错误标识符与行号一起记录。不要在未理解原因时用 try/catch 把所有错误变成“成功”。

| 现象 | 可能原因 | 检查与处理 |
|---|---|---|
| 找不到 sm.defaultConfig | 没有添加 src 路径 | 在项目根目录运行 setup |
| 找不到 nrWaveformGenerator | 未安装 5G Toolbox 或路径异常 | check_environment；which nrWaveformGenerator -all；安装匹配版本 |
| 函数存在但 License checkout failed | 许可证不可用、并发限制、登录问题 | 用 MathWorks 账号/管理员处理，不把它当代码错误 |
| Unknown parameter | 拼写错或把其他协议参数用于当前协议 | disp(sm.defaultConfig('...')) 查看字段 |
| 工具箱说某属性不支持 | MATLAB/工具箱版本差异 | doc 对应本机版本；先用默认预设；保留错误 |
| EHT 不可用 | WLAN 版本太旧 | 先运行 HE；EHT 入口需要支持该对象的版本 |
| lrwpanWaveformGenerator 不存在 | Communications Toolbox 版本不包含该入口 | R2023a 起提供；本项目建议 R2023b+ |
| Thread 信号时长差一倍 | SamplesPerChip 约定套错 | 读 cfg.SampleRate，运行 lab09，不手算错误采样率 |
| BLE 125K 采样率设置为 1 MS/s | 把净信息速率当符号速率 | SPS=8 时 coded PHY 是 8 MS/s |
| EDR3M 采样率设置为 24 MS/s | 把 3 bit/symbol 当 3 Msym/s | 默认 SPS=8 时是 8 MS/s |
| 频谱镜像 | Q 符号/IQ 顺序/设备约定错 | 用 +125 kHz 单音检查，参考 lab01 |
| 播放频谱宽两倍 | 仪器 Fs 与文件 Fs 不一致 | 按 manifest 设置真实采样率 |
| 星座成一团 | 画的是时域过采样点或 OFDM 时域 | 匹配滤波/FFT/均衡后再画符号 |
| RRC 首尾符号错 | 忘了滤波群延迟/丢了尾巴 | 使用 full 卷积，保留两级延迟 |
| OFDM CP 足够仍星座歪 | 未补偿 H[k] | 先用已知信道验证，再加估计器 |
| 改 MCS 后不支持 | 带宽/流数/编码/RU 组合非法 | 查看该对象本机 MCS 表，回退默认再逐项改 |
| 修改 APEP 后比特数不匹配 | APEP≠实际 PSDU 长度 | 使用对象 PSDULength/getPSDULength/psduLength |
| BLE 频谱正常但 CRC 错 | phy-test 随机位、白化信道错、重复 CRC | 默认 advertising 路径；运行 lab08 |
| Thread 波形不能入网 | 没有 Thread 网络栈/安全载荷 | 本项目是 PHY/裸 MAC 实验；参看高级路线 |
| 手机看不到 NR 小区 | 默认未发 SSB/PDCCH，也无完整基站 | 这是 PDSCH 测试波形；按官方完整例程扩展 |
| int16 大幅失真 | 溢出、端序、缩放除数、I/Q 交织错误 | 使用项目导出器及 readIQ 回读 |
| MIMO 看起来丢一路 | 把矩阵展开/误认为两列是 I 与 Q | 一列一发射通道，每列自身为复数 |
| 图中的 PSD 不是 dBm | IQ 未物理标定 | 通过仪器电平和链路损耗校准 |
| OBW 加噪后很大 | 噪声铺满带宽 | 分别测干净信号和接收信号 |
| 每个循环边界出现宽带毛刺 | 首尾相位/幅度不连续 | 包含空闲、保持包完整；明确需要的周期边界 |
| 程序内存不足 | 过大 BW、时长、天线数、double 中间副本 | 缩短 NumSubframes/NumPackets；估算样本量 |
| 输出目录已有 MAT | 防覆盖机制生效 | 使用新目录，不覆盖唯一实验记录 |
| resample 后 receiver 切包错误 | 仍使用旧 PacketSamples 索引 | 重新计算索引/重新同步；原 details 是源参考 |

## 版本问题的正确修复顺序

1. 记录 `version('-release')`、`ver` 和目标函数 `which` 结果。
2. 单独创建官方对象，例如 `c=lrwpanOQPSKConfig`，观察属性。
3. 运行本机 doc 中最小示例，确认安装/许可证。
4. 对比项目适配器的参数。如果是版本接口差异，在对应 `generate*.m` 中修复，保留一个回归测试。
5. 运行相关实验和 `run_tests('all')`，不要因为某个不相关模块被 SKIP 就说全功能测试通过。

## 可以接受的差异

不同工具箱版本、默认窗函数或随机源实现可能让波形不逐样点相同。关键是：同一环境内可复现、协议配置合法、采样率准确、帧结构可验证、期望的接收结果成立。不能仅凭与网上图片“不完全一样”判断错误。
