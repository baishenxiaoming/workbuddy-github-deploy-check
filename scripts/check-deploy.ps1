# WorkBuddy GitHub 连接器部署自检（只读，不联网，不读取凭据）
$PASS = 0
$WARN = 0
$FAIL = 0

function Ok($m)   { Write-Host "  [PASS] $m" -ForegroundColor Green;  $script:PASS++ }
function Warn($m) { Write-Host "  [WARN] $m" -ForegroundColor Yellow; $script:WARN++ }
function Bad($m)  { Write-Host "  [FAIL] $m" -ForegroundColor Red;    $script:FAIL++ }
function Info($m) { Write-Host "  [INFO] $m" -ForegroundColor Gray }

Write-Host "WorkBuddy GitHub 部署自检"
Write-Host "目录: $(Get-Location)`n"

Write-Host "[1] 本地 git 环境"
if (Get-Command git -ErrorAction SilentlyContinue) { Ok "git 已安装: $(git --version)" } else { Bad "未找到 git" }

$name  = git config --global --get user.name  2>$null
$email = git config --global --get user.email 2>$null
if ($name)  { Ok "user.name = $name" }   else { Bad "user.name 未配置" }
if ($email) { Ok "user.email = $email" } else { Bad "user.email 未配置" }

$helper = git config --get-all credential.helper 2>$null
if ($helper) { Ok "凭据助手 = $($helper | Select-Object -Last 1)" } else { Warn "未配置凭据助手" }

Write-Host "`n[2] 写通路兜底"
if (Get-Command gh -ErrorAction SilentlyContinue) { Ok "gh CLI 已安装: $((gh --version)[0])" }
else { Warn "gh CLI 未安装 —— 用户级写操作（建仓/推送）将缺少兜底链路" }

Write-Host "`n[3] 当前仓库状态"
git rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) {
  Ok "当前目录是 git 仓库"
  Info "当前分支: $(git symbolic-ref --short HEAD 2>$null)"
  $remotes = git remote 2>$null
  if ($remotes) { Ok "已配置 remote: $($remotes -join ' ')" } else { Warn "未配置 remote —— 尚不能推送" }
  if (-not (git status --porcelain 2>$null)) { Ok "工作区干净" } else { Info "存在未提交更改" }
} else { Bad "当前目录不是 git 仓库" }

Write-Host "`n[4] 说明文件"
foreach ($f in @("README.md", "LICENSE", "CONTRIBUTING.md", "CHANGELOG.md", ".gitignore")) {
  if (Test-Path $f) { Ok $f } else { Warn "缺少 $f" }
}

Write-Host "`n汇总: PASS=$PASS WARN=$WARN FAIL=$FAIL"
Write-Host '提示: GitHub 侧认证与仓库权限请在 WorkBuddy 中输入「检查GitHub连接状态，双向认证是否通过？仓库权限是否获取？」'

if ($FAIL -gt 0) { exit 1 }
