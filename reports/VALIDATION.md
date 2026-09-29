# 交付验证报告 · 2026-09-29

## 已执行

| 检查 | 实际结果 | 证据 |
|---|---|---|
| MATLAB 源码静态语法/语义检查 | 59 个 .m 文件通过 MISS_HIT 0.9.44；无报告问题 | [matlab_static_lint.txt](matlab_static_lint.txt) |
| 独立数学与格式参考检查 | Python/NumPy 14 项通过，0 失败 | [reference_checks.json](reference_checks.json) |
| Python 检查器的已知 IQ 读回 | 3 个复样点，浮点/整数格式已核对 | resources/fixtures 与 tools/inspect_iq.py |
| 官方 API 核对 | MathWorks 和官方标准/项目资料，记录访问日期 | [资料索引](../resources/REFERENCES.md) |
| 项目完整性 | MATLAB 文件名/函数名、包内调用、23 个配方、文档本地链接 | [project_audit.json](project_audit.json) |
| 离线手册浏览器检查 | 桌面 1440px / 手机 390px 无页面横向溢出；章节图片正常加载；已人工查看截图 | 本地 Chrome 无头预览 |
| 原创参考图 | 4 张 NumPy/matplotlib 理论图，明确标注来源 | resources/reference_figures |

独立数学检查的重要观测：RRC 匹配滤波残余 EVM 约 0.202%；足够 CP 的 OFDM 还原误差接近浮点精度；CP=32、延迟=48 的样例 EVM 约 12.65%；BPSK 在 Eb/N0=0 dB 的独立仿真 BER 约 0.07893；CRC 已知向量 123456789 为 0x2189；量化误差落在设定容差内。这些数值来自 Python 参考实现，**不是 MATLAB 输出**。

## 尚未执行

交付环境的 PATH 与 /Applications 常见位置未发现 MATLAB/Octave 可执行程序，因此无法在这里执行 MATLAB、专有工具箱、许可证 checkout、Simulink 或实际射频仪器测试。

- 未声称 run_tests('core') 或 run_tests('all') 已运行通过。
- 未声称任何工具箱协议 IQ 已在本机实际生成。
- 未声称生成波形通过独立标准认证、真实设备互操作、网络接入或 RF 功率标定。
- Python 参考实现和静态检查不能替代 MATLAB 运行，尤其不能验证专有 API 默认值、许可证和版本差异。

## 在你的 MATLAB 中完成验收

```matlab
cd(fullfile(getenv('HOME'),'simulated_modulation'))
setup
check_environment
run_tests('core')
run_tests('all')
run_all('core')
```

如果本机没有某项工具箱，相关测试将 SKIP；已存在入口但执行失败会 FAIL 并保留堆栈。请先解决 FAIL，再生成正式实验波形。实际测试结果保存在 tests_core.json、tests_all.json；它们是新的运行证据，不会反向改变此交付报告的历史状态。

## 接收验证深度

WLAN non-HT：已提供已知定时 PHY 回环；BLE：四 PHY 的理想接收测试和默认广播 LL/CRC 测试；NR：低层 PDSCH/DM-RS/OFDM 映射回环；Thread：CRC/时长结构检查。LTE、经典蓝牙与其余 Wi-Fi 代际提供生成/参数检查，但本版没有完整接收器。详见 [验证 SOP](../sop/05_validate.md)。

## 版本边界

项目设计基线 R2023b+，建议 R2024b 或更新；支持范围仍以本机函数与配置对象为准。最新在线文档可能显示 R2026b，项目没有因此承诺旧 MATLAB 具备所有新增功能。本版不依赖 Wi-Fi 8 等最新接口。
