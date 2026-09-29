# 10 · MATLAB 图形界面与 Simulink

## 无线波形生成 App

如果你想先拖动参数观察变化，在 MATLAB 的 Apps 页面寻找 Wireless Waveform Generator。可生成的协议取决于已安装工具箱，较新的版本可能将 WLAN、5G、Bluetooth 分成专用 App。通过本机 `doc wirelessWaveformGenerator` 查看可用入口与界面。

推荐操作：

1. 选择通用 QPSK，设置符号率、采样率和成形滤波。
2. 生成并看频谱、星座/时域；确认视图的坐标与单位。
3. 切换为目标协议，使用保守默认参数。
4. 找到 Export to MATLAB Script / Generate MATLAB Code 一类导出功能；具体名称随版本变化。
5. 将导出的脚本保存到自己的实验目录，核对其配置对象与本项目对应适配器。
6. 保存 IQ 和配置。App 截图不足以复现实验，导出的代码更重要。

官方入口：[Wireless Waveform Generator](https://www.mathworks.com/help/comm/ref/wirelesswaveformgenerator-app.html)。

## 本项目提供的 Simulink 模型

```matlab
setup
modelPath = build_simulink_model;
open_system(modelPath)
```

函数创建并仿真 `generated/sm_iq_playback.slx`：

```text
From Workspace (complex IQ) ─┬─ Complex to Real-Imag ─ Scope (I,Q)
                            └─ To Workspace (capture)
```

它将波形和时间序列保存在模型工作区，采用离散固定步长 `1/Fs`。模型只是离线 IQ 播放与观察，不包含实时射频或完整协议栈。建立模型需要本机 Simulink；交付环境没有 Simulink，所以此构建器的运行待本机验收。

同名模型已经存在时脚本会停止，避免覆盖你修改的版本。若要重建，请另存旧模型或修改模型名称。

## 下一步如何加模块

先加一个增益块验证幅度变化，再加延迟或噪声模块。凡是改变采样率、引入滤波或帧化的模块，都要核对信号维度、Sample time、帧长度和延迟。

MATLAB Function 块不保证支持所有高级工具箱对象或动态配置；不要把任意离线脚本直接塞入代码生成环境。入门阶段以预生成 IQ 的 From Workspace 输入最容易定位问题。

## MATLAB Online

将项目上传到 MATLAB Drive，切换到该目录后运行 `setup`。生成器与核心教程可以沿同一路线进行，但可用工具箱、存储额度、浏览器下载和硬件访问能力由在线环境决定。导出 IQ 后再转移到本地仪器工作站；不要把云端文件路径当成本机路径。
