# 可选工具

运行 MATLAB 项目不需要 Python。

- `python3 tools/inspect_iq.py <IQ文件> --manifest <manifest.json>`：只用 Python 标准库核对浮点 IQ。整数文件增加 `--format ci16_le`。
- `python3 tools/reference_checks.py`：NumPy 独立数学复核；不会执行 MATLAB/工具箱。
- `python3 tools/build_handbook.py`：将 Markdown 重建为离线 HTML，需要 markdown 包。
- `python3 tools/reference_figures.py`：生成有明确来源标注的独立参考图，需要 NumPy/matplotlib。
- `python3 tools/audit_project.py`：本地链接、配置结构、文件名与项目完整性检查。

如果需要重建工具，可在自己的虚拟环境安装 requirements-optional.txt。交付报告记录的是实际使用版本；宽松版本范围便于之后重建，但不能代替固定环境记录。
