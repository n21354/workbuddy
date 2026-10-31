# 一键推送 cloud-checkin 到 GitHub
# 在你的本机（网络正常、有仓库写权限）运行：
#   powershell -ExecutionPolicy Bypass -File push.ps1
# 推送时会弹出 GitHub 登录框：用户名填 GitHub 账号，密码填 个人访问令牌(PAT)（需 repo 权限），不是登录密码。
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

Write-Host "==> 推送 cloud-checkin -> https://github.com/n21354/workbuddy.git" -ForegroundColor Cyan

# 第一次推送
git push -u origin main
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 推送成功！" -ForegroundColor Green
} else {
    Write-Host "⚠️ 直接推送被拒绝（目标仓库可能已有内容），尝试先拉取再推送..." -ForegroundColor Yellow
    git pull origin main --rebase --allow-unrelated-histories
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 拉取失败，可能需手动解决冲突后重试。" -ForegroundColor Red
        exit 1
    }
    git push -u origin main
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 推送失败，请检查 GitHub 凭据/仓库权限。" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ 拉取并推送成功！" -ForegroundColor Green
}

Write-Host ""
Write-Host "==> 下一步（在 GitHub 网页上操作）：" -ForegroundColor Cyan
Write-Host "   1. Settings -> Secrets and variables -> Actions -> New repository secret" -ForegroundColor White
Write-Host "      名称 WB_ACCESS_TOKEN（必填）= 本机运行 refresh_token.py / 双击 refresh_token.exe 导出的 token" -ForegroundColor White
Write-Host "      名称 FEISHU_WEBHOOK（可选）= 飞书自定义机器人 webhook 地址" -ForegroundColor White
Write-Host "   2. Actions 标签页 -> 手动 Run workflow 跑一次验证" -ForegroundColor White
