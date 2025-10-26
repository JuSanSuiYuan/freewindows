# FreeWindows 构建脚本
# 用于构建 ReactOS（使用 LLVM 工具链）

param(
    [Parameter(Mandatory=$false)]
    [string]$BuildDir = "build",
    
    [Parameter(Mandatory=$false)]
    [string]$Target = "all",
    
    [Parameter(Mandatory=$false)]
    [int]$Jobs = 0,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose,
    
    [Parameter(Mandatory=$false)]
    [switch]$Clean
)

# 设置错误处理
$ErrorActionPreference = "Stop"

# 脚本目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "=== FreeWindows 构建脚本 ===" -ForegroundColor Cyan
Write-Host ""

# 检查构建目录
$BuildFullPath = Join-Path $ProjectRoot $BuildDir
if (-not (Test-Path $BuildFullPath)) {
    Write-Host "错误：构建目录不存在：$BuildFullPath" -ForegroundColor Red
    Write-Host "请先运行配置脚本：.\scripts\configure.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/3] 构建配置" -ForegroundColor Yellow
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

# 清理构建（如果需要）
if ($Clean) {
    Write-Host "[2/3] 清理构建..." -ForegroundColor Yellow
    
    $CMakeArgs = @(
        "--build", $BuildFullPath,
        "--target", "clean"
    )
    
    try {
        & cmake @CMakeArgs
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
Write-Host "[2/3] 开始构建..." -ForegroundColor Yellow

$CMakeArgs = @(
    "--build", $BuildFullPath,
    "--target", $Target,
    "--parallel", $Jobs
)

if ($Verbose) {
    $CMakeArgs += "--verbose"
}

Write-Host "  执行命令：cmake $($CMakeArgs -join ' ')" -ForegroundColor Cyan
Write-Host ""

$StartTime = Get-Date

try {
    & cmake @CMakeArgs
    if ($LASTEXITCODE -ne 0) {
        throw "构建失败，退出码：$LASTEXITCODE"
    }
} catch {
    Write-Host ""
    Write-Host "错误：构建失败" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

$EndTime = Get-Date
$Duration = $EndTime - $StartTime

Write-Host ""

# 完成
Write-Host "[3/3] 构建完成！" -ForegroundColor Green
Write-Host ""
Write-Host "构建时间：$($Duration.ToString('mm\:ss'))" -ForegroundColor Cyan
Write-Host "构建目录：$BuildFullPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步：" -ForegroundColor Yellow
Write-Host "  运行测试：.\scripts\test.ps1" -ForegroundColor White
Write-Host "  查看输出：$BuildFullPath" -ForegroundColor White
Write-Host ""
