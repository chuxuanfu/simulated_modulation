# SOP-01 · 环境安装与首次验收

**目的：** 确认软件版本、可用工具箱和基础代码可用。预计首次 30–60 分钟，不含软件下载安装。

## 准备

- 项目路径：`~/simulated_modulation`。
- MATLAB：设计基线 R2023b+，建议 R2024b 或更新。
- 核心必需：MATLAB。
- 协议按需：Communications Toolbox、WLAN Toolbox、Bluetooth Toolbox、LTE Toolbox、5G Toolbox。
- 可选：Signal Processing Toolbox（重采样）；Simulink（图形仿真）；仪器/SDR 支持包仅在确定具体硬件后安装。

某些产品还会依赖 DSP System Toolbox 等组件，以安装器自动列出的依赖为准。无需为了学习本项目购买所有可选产品，也不必安装 Python。

## 操作

1. 使用 MathWorks 账户确认授权产品。在官方安装器中选与 MATLAB release 匹配的产品，不手动混合不同 release 的目录。
2. 启动 MATLAB，执行 `version`、`ver`，确认安装列表。
3. 进入项目根目录，执行 `setup`、`check_environment`。
4. 运行 `run_tests('core')`。查看 PASS/FAIL/SKIP 和 `reports/tests_core.json`。
5. 运行 `run_tests('all')`。若只是缺失工具箱，会列 SKIP；已有函数但许可证或配置异常会列 FAIL。
6. 运行 `lab01_iq_sampling`，确认图像生成且频率峰方向正确。
7. 复制 `sop/07_record_template.md` 到新实验文件，填写环境版本。

## 验收

- 核心测试没有 FAIL。
- 所需协议入口存在且该协议生成测试 PASS。
- 不需要的模块可以 SKIP，但在实验记录中注明。
- 如果全部工具箱测试尚未运行，不标注“全部通过”。

## 故障路径

先读环境 JSON 和错误信息；对工具箱许可证问题，使用 MATLAB 的许可管理/MathWorks 支持路径处理。代码不会代替你下载 MATLAB 安装器、输入账号或更改许可证设置。

如果使用 MATLAB Online，将项目上传并切换到实际目录后同样执行上述命令；具体可用产品由在线许可决定。
