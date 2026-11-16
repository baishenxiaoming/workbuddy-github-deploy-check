# 更新日志

本项目版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [0.1.1] - 2026-11-16

### 变更

- 补齐 gh CLI 授权与首次发布，README 实测记录更新为最终状态
- 明确 App 安装令牌与 OAuth 用户令牌在写操作上的权限边界
- 修复 PowerShell 5.1 中文编码（UTF-8 BOM）、`--version` 数组索引与仓库状态误判

## [0.1.0] - 2026-11-16

### 新增

- 五阶段部署验收口径与 31 步对照清单
- `scripts/check-deploy.sh`：Git Bash / Linux / macOS 本地自检
- `scripts/check-deploy.ps1`：Windows PowerShell 本地自检
- README 记录首次完整实测结果，包含写通路 403 的诊断结论
- MIT 许可、贡献指南与 .gitignore
