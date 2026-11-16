# WorkBuddy GitHub 连接器部署自检

一套可复用的检查清单与本地脚本，用于确认 WorkBuddy 与 GitHub 之间的连接器是否**真正完成部署**——不只是"显示已连接"，而是读、写、发布三条链路都能跑通。

参考流程：《WorkBuddy 如何链接 GitHub 自动操作仓库》（5 大阶段 / 31 步）。本仓库把其中最容易被跳过、也最难自查的部分固化成可执行检查。

## 为什么需要它

连接器面板显示绿灯，只说明 OAuth 授权成功。实际部署还依赖三件独立的事：

1. GitHub 端 `CodeBuddy-Connector` App 是否已安装、仓库访问范围是否为「所有存储库」；
2. 当前令牌是否具备**写**权限（读接口正常不代表能建仓、能推送）；
3. 本地 git 身份、凭据与项目本身是否就绪。

这三点里任何一点缺失，都会出现"能查仓库、但发不出去"的状态。

## 快速开始

```bash
bash scripts/check-deploy.sh
```

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-deploy.ps1
```

脚本只检查**本地环境**，不读取、不存储、不上传任何凭据，也不发起网络请求。涉及 GitHub 侧的两项验证（认证身份、仓库读写）请在 WorkBuddy 对话框里用自然语言触发：

```
检查 GitHub 连接状态，双向认证是否通过？仓库权限是否获取？
```

## 五个阶段的验收口径

| 阶段 | 内容 | 判定标准 |
| --- | --- | --- |
| 1 | 安装连接器 + OAuth 授权 | 连接器状态 connected，用户信息接口能返回账号 |
| 2 | GitHub 端安装 App + 配置权限 | App 出现在已安装列表，Repository access = All repositories |
| 3 | 双重验证（认证 + 权限 + API） | 用户接口、仓库搜索、分支读取均正常 |
| 4 | 本地环境 | git 身份已配置，凭据助手可用 |
| 5 | 规范化发布 | 能创建 public 仓库并推送完整说明文件 |

完整逐条对照见 [`docs/DEPLOY-CHECKLIST.md`](docs/DEPLOY-CHECKLIST.md)。

## 实测记录（2026-11-16）

| 检查项 | 结果 |
| --- | --- |
| 连接器状态 | `bound` / `enabled` / `connected` 均为 true |
| OAuth 认证 | 通过，账号 `baishenxiaoming`（id 129289050） |
| API 访问 | 通过，仓库搜索返回 3662 条 |
| 仓库读取 | 通过，可读取分支列表 |
| App 令牌建仓 | 403 `Resource not accessible by integration` |
| gh CLI 建仓 | 成功，public 仓库 `baishenxiaoming/workbuddy-github-deploy-check` |
| gh CLI 登录 | v2.104.0，scopes：`repo` / `read:org` / `gist` |
| git 身份 | 已补齐（`baishenxiaoming@users.noreply.github.com`） |
| 规范化发布 | 完成，`main` 分支推送成功，本地与远程提交一致（`13b9975`） |

**关键结论**：读链路走 GitHub App 安装令牌，可正常工作；`POST /user/repos` 这类用户级写操作不能由 App 安装令牌完成，会返回 403。这正是官方说明中「写操作用 gh CLI 兜底」的原因——**gh CLI 不是可选项，而是写通路的必要环节**。

补齐 gh CLI 并完成一次浏览器授权后，建仓与 `git push` 均成功，五个阶段全部通过。

## 常见误判

- `user:<name>` 仓库搜索返回 `Validation Failed`：通常是该账号下没有任何可搜索仓库，不是认证失败。用全局搜索即可区分。
- `is:private` 返回 0：说明当前令牌可见的私有仓库为空，不能据此断定 App 权限范围配置正确。
- 连接器绿灯 ≠ 写权限：绿灯只覆盖 OAuth，写权限要单独实测。

## 目录结构

```
├── README.md                    项目说明与实测记录
├── LICENSE                      MIT 许可
├── CONTRIBUTING.md              贡献指南
├── CHANGELOG.md                 版本记录
├── .gitignore
├── docs/DEPLOY-CHECKLIST.md     31 步部署对照清单
└── scripts/
    ├── check-deploy.sh          Linux / macOS / Git Bash 自检
    └── check-deploy.ps1         Windows PowerShell 自检
```

## 许可

[MIT](LICENSE)
