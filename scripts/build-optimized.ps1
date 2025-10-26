# FreeWindows 优化构建脚本
# 使用 Ninja 进行快速构建

param(
    [Parameter(Mandatory=$false)]
    [string]$BuildDir = "build\reactos-amd64-clang-cl-optimized",
    
    [Parameter(Mandatory=$false)]
    [string]$Target = "all",
    
    [Parameter(Mandatory=$false)]
    [int]$Jobs = 0,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose,
    
    [Parameter(Mandatory=$false)]
    [switch]$Clean,
    
    [Parameter(Mandatory=$false)]
    [switch]$ShowStats
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "=== FreeWindows 优化构建脚本 ===" -ForegroundColor Cyan
Write-Host "使用 Ninja 进行快速构建" -ForegroundColor Cyan
Write-Host ""

# 检查构建目录
$BuildFullPath = Join-Path $ProjectRoot $BuildDir
if (-not (Test-Path $BuildFullPath)) {
    Write-Host "错误：构建目录不存在：$BuildFullPath" -ForegroundColor Red
    Write-Host "请先运行配置脚本：.\scripts\configure-optimized.ps1" -ForegroundColor Yellow
    exit 1
}

# 检查 Ninja
if (-not (Get-Command "ninja" -ErrorAction SilentlyContinue)) {
    Write-Host "错误：Ninja 未安装" -ForegroundColor Red
    Write-Host "安装方法：choco install ninja" -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/4] 构建配置" -ForegroundColor Yellow
Write-Host "  构建目录：$BuildFullPath" -ForegroundColor Cyan
Write-Host "  构建目标：$Target" -ForegroundColor Cyan

# 自动检测 CPU 核心数
if ($Jobs -eq 0) {
    $Jobs = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
    Write-Host "  并行任务：$Jobs (自动检测)" -ForegroundColor Cyan
} else {
    Write-Host "  并行任务：$Jobs" -ForegroundColor Cyan
}

Write-Host ""

# 显示 ccache 统计（构建前）
$UseCCache = $false
if (Get-Command "ccache" -ErrorAction SilentlyContinue) {
    $UseCCache = $true
    if ($ShowStats) {
        Write-Host "[2/4] ccache 统计（构建前）" -ForegroundColor Yellow
        & ccache -s
        Write-Host ""
    }
}

# 清理构建
if ($Clean) {
    Write-Host "[2/4] 清理构建..." -ForegroundColor Yellow
    
    try {
        & ninja -C $BuildFullPath -t clean
        if ($LASTEXITCODE -ne 0) {
            throw "清理失败，退出码：$LASTEXITCODE"
        }
        Write-Host "  ✓ 清理完成" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ 清理失败" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
}

# 执行构建
Write-Host "[3/4] 开始构建..." -ForegroundColor Yellow

$NinjaArgs = @(
    "-C", $BuildFullPath,
    "-j", $Jobs
)

if ($Target -ne "all") {
    $NinjaArgs += $Target
}

if ($Verbose) {
    $NinjaArgs += "-v"
}

Write-Host "  执行命令：ninja $($NinjaArgs -join ' ')" -ForegroundColor Cyan
Write-Host ""

$StartTime = Get-Date

try {
    & ninja @NinjaArgs
    if ($LASTEXITCODE -ne 0) {
        throw "构建失败，退出码：$LASTEXITCODE"
    }
} catch {
    Write-Host ""
    Write-Host "错误：构建失败" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    # 显示 ccache 统计（失败时）
    if ($UseCCache -and $ShowStats) {
        Write-Host ""
        Write-Host "ccache 统计（构建失败）：" -ForegroundColor Yellow
        & ccache -s
    }
    
    exit 1
}

$EndTime = Get-Date
$Duration = $EndTime - $StartTime

Write-Host ""

# 显示 ccache 统计（构建后）
if ($UseCCache -and $ShowStats) {
    Write-Host "[4/4] ccache 统计（构建后）" -ForegroundColor Yellow
    & ccache -s
    Write-Host ""
}

# 完成
Write-Host "[4/4] 构建完成！" -ForegroundColor Green
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "构建摘要" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "  构建时间：$($Duration.ToString('mm\:ss'))" -ForegroundColor White
Write-Host "  构建目录：$BuildFullPath" -ForegroundColor White
Write-Host "  并行任务：$Jobs" -ForegroundColor White
if ($UseCCache) {
    Write-Host "  编译缓存：✓ ccache" -ForegroundColor Green
} else {
    Write-Host "  编译缓存：✗ 未启用" -ForegroundColor Red
}
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步：" -ForegroundColor Yellow
Write-Host "  运行测试：.\scripts\test.ps1 -BuildDir `"$BuildDir`"" -ForegroundColor White
Write-Host "  查看输出：$BuildFullPath" -ForegroundColor White
if ($UseCCache) {
    Write-Host "  查看缓存：ccache -s" -ForegroundColor White
}
Write-Host ""
