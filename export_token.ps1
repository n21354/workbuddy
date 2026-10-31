# 导出 WorkBuddy token 并复制到剪贴板（傻瓜版）
# 运行方式：双击同目录的 export_token.bat，或右键本文件“使用 PowerShell 运行”
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$exe = Join-Path $here 'refresh_token.exe'
if (-not (Test-Path $exe)) { $exe = Join-Path $here 'refresh_token.py' }

$tmp = Join-Path $env:TEMP ('wb_token_' + [guid]::NewGuid().ToString('N') + '.txt')
# stdin 重定向到 NUL，避免 exe 卡在“按回车退出”等待
Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', "`"$exe`" < NUL > `"$tmp`" 2>&1" -Wait -WindowStyle Hidden
$raw = Get-Content -Raw $tmp -ErrorAction SilentlyContinue
Remove-Item $tmp -Force -ErrorAction SilentlyContinue

if ($raw -match '----- 以下为 token -----\s*(.*?)\s*----- 以上为 token -----') {
    $token = $Matches[1].Trim()
} else {
    $m = [regex]::Match($raw, '[A-Za-z0-9._~+/-]{20,}={0,2}')
    $token = if ($m.Success) { $m.Value } else { '' }
}

if (-not $token) {
    Write-Host '❌ 未能提取到 token。请确认：' -ForegroundColor Red
    Write-Host '   1) 本机已登录 WorkBuddy（先看一眼 WorkBuddy 能否正常使用）' -ForegroundColor White
    Write-Host '   2) 用“已登录的同一个 Windows 用户”运行本脚本' -ForegroundColor White
    Write-Host '   3) WorkBuddy 装在默认位置，或设置 WORKBUDDY_EXE 环境变量指向 WorkBuddy.exe' -ForegroundColor White
    Write-Host '' ; Write-Host $raw -ForegroundColor DarkGray
    Read-Host -Prompt '按回车退出'
    exit 1
}

Set-Clipboard $token
Write-Host ''
Write-Host '✅ token 已复制到剪贴板！直接 Ctrl+V 粘到 GitHub 的 WB_ACCESS_TOKEN 即可。' -ForegroundColor Green
Write-Host ''
Write-Host ('token 预览（前20位）：' + $token.Substring(0, [math]::Min(20, $token.Length)) + '…') -ForegroundColor Cyan
Write-Host ''
Write-Host '[安全] token 等同登录态，请勿外泄；约28天失效后重跑本脚本。' -ForegroundColor Yellow
Read-Host -Prompt '按回车退出'
