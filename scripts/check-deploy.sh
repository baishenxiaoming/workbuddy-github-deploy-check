#!/usr/bin/env bash
# WorkBuddy GitHub 连接器部署自检（只读，不联网，不读取凭据）
set -u

PASS=0
WARN=0
FAIL=0

ok()   { printf '  [PASS] %s\n' "$1"; PASS=$((PASS + 1)); }
warn() { printf '  [WARN] %s\n' "$1"; WARN=$((WARN + 1)); }
bad()  { printf '  [FAIL] %s\n' "$1"; FAIL=$((FAIL + 1)); }
info() { printf '  [INFO] %s\n' "$1"; }

printf 'WorkBuddy GitHub 部署自检\n'
printf '目录: %s\n\n' "$(pwd)"

printf '[1] 本地 git 环境\n'
if command -v git >/dev/null 2>&1; then
  ok "git 已安装: $(git --version)"
else
  bad "未找到 git"
fi

name=$(git config --global --get user.name 2>/dev/null || true)
email=$(git config --global --get user.email 2>/dev/null || true)
[ -n "$name" ]  && ok "user.name = $name"  || bad "user.name 未配置"
[ -n "$email" ] && ok "user.email = $email" || bad "user.email 未配置"

helper=$(git config --get-all credential.helper 2>/dev/null | tail -1 || true)
[ -n "$helper" ] && ok "凭据助手 = $helper" || warn "未配置凭据助手"

printf '\n[2] 写通路兜底\n'
GH_BIN=""
if command -v gh >/dev/null 2>&1; then
  GH_BIN="gh"
elif [ -x "/c/Program Files/GitHub CLI/gh.exe" ]; then
  GH_BIN="/c/Program Files/GitHub CLI/gh.exe"
fi
if [ -n "$GH_BIN" ]; then
  ok "gh CLI 已安装: $("$GH_BIN" --version | head -1)"
else
  warn "gh CLI 未安装 —— 用户级写操作（建仓/推送）将缺少兜底链路"
fi

printf '\n[3] 当前仓库状态\n'
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  ok "当前目录是 git 仓库"
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")
  info "当前分支: $branch"
  if [ -n "$(git remote 2>/dev/null)" ]; then
    ok "已配置 remote: $(git remote | tr '\n' ' ')"
  else
    warn "未配置 remote —— 尚不能推送"
  fi
  if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
    ok "工作区干净"
  else
    info "存在未提交更改"
  fi
else
  bad "当前目录不是 git 仓库"
fi

printf '\n[4] 说明文件\n'
for f in README.md LICENSE CONTRIBUTING.md CHANGELOG.md .gitignore; do
  [ -f "$f" ] && ok "$f" || warn "缺少 $f"
done

printf '\n汇总: PASS=%s WARN=%s FAIL=%s\n' "$PASS" "$WARN" "$FAIL"
printf '提示: GitHub 侧认证与仓库权限请在 WorkBuddy 中输入「检查GitHub连接状态，双向认证是否通过？仓库权限是否获取？」\n'

[ "$FAIL" -eq 0 ] || exit 1
