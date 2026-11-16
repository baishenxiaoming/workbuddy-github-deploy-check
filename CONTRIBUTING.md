# 贡献指南

## 原则

- 检查项必须**可验证**：每条都要写清「判定标准」，避免主观描述。
- 脚本必须**只读**：不得读取、打印或上传凭据，不得发起网络请求。
- 结论要区分「已实证」与「待人工核对」，不要把推测写成通过。

## 提交流程

1. Fork 本仓库并创建分支：`git checkout -b feat/your-change`
2. 修改后本地自检：`bash scripts/check-deploy.sh`
3. 提交信息使用约定式格式，例如 `feat: 增加 gh CLI 版本检查`
4. 发起 Pull Request，说明改动对应的检查项与验证方式

## 新增检查项

在 `scripts/check-deploy.sh` 与 `scripts/check-deploy.ps1` 中**同步**添加，并更新 `docs/DEPLOY-CHECKLIST.md` 的对应条目。两个脚本的判定口径必须一致。

## 实测记录

更新 `README.md` 的实测记录时，请标注日期与环境，并保留失败项——失败信息比绿灯更有诊断价值。
