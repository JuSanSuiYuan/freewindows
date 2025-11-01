# 应用补丁脚本
# 用于将 FreeWindows 补丁应用到 ReactOS 源代码

param(
    [Parameter(Mandatory=$false)]
    [string]$ReactOSPath = "..\reactos",
    
    [Parameter(Mandatory=$false)]
    [string]$PatchDir = "patches",
    
    [switch]$DryRun,
    [switch]$Reverse
)

$ErrorActionPreference = "Stop"

Write-Host "FreeWindows 补丁应用工具" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""

# 检查 ReactOS 路径
if (-not (Test-Path $ReactOSPath)) {
    Write-Host "错误：找不到 ReactOS 源代码目录: $ReactOSPath" -ForegroundColor Red
    exit 1
}

# 检查补丁目录
if (-not (Test-Path $PatchDir)) {
    Write-Host "错误：找不到补丁目录: $PatchDir" -ForegroundColor Red
    exit 1
}

# 获取所有补丁文件
$patches = Get-ChildItem -Path $PatchDir -Filter "*.patch" | Sort-Object Name

if ($patches.Count -eq 0) {
    Write-Host "警告：没有找到补丁文件" -ForegroundColor Yellow
    exit 0
}

Write-Host "找到 $($patches.Count) 个补丁文件" -ForegroundColor Green
Write-Host ""

# 应用每个补丁
$successCount = 0
$failCount = 0

foreach ($patch in $patches) {
    Write-Host "处理补丁: $($patch.Name)" -ForegroundColor Cyan
    
    if ($DryRun) {
        Write-Host "  [模拟模式] 检查补丁..." -ForegroundColor Yellow
        $result = git -C $ReactOSPath apply --check $patch.FullName 2>&1
    }
    elseif ($Reverse) {
        Write-Host "  [回退模式] 撤销补丁..." -ForegroundColor Yellow
        $result = git -C $ReactOSPath apply --reverse $patch.FullName 2>&1
    }
    else {
        Write-Host "  应用补丁..." -ForegroundColor Green
        $result = git -C $ReactOSPath apply $patch.FullName 2>&1
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ 成功" -ForegroundColor Green
        $successCount++
    }
    else {
        Write-Host "  ✗ 失败" -ForegroundColor Red
        Write-Host "  错误信息: $result" -ForegroundColor Red
        $failCount++
    }
    
    Write-Host ""
}

# 总结
Write-Host "=========================" -ForegroundColor Cyan
Write-Host "补丁应用完成" -ForegroundColor Cyan
Write-Host "成功: $successCount" -ForegroundColor Green
Write-Host "失败: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })

if ($failCount -gt 0) {
    exit 1
}
