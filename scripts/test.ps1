# FreeWindows 测试脚本
# 用于测试 ReactOS 构建

param(
    [Parameter(Mandatory=$false)]
    [string]$BuildDir = "build",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("all", "unit", "integration", "boot")]
    [string]$TestSuite = "all",
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

# 设置错误处理
$ErrorActionPreference = "Stop"

# 脚本目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "=== FreeWindows 测试脚本 ===" -ForegroundColor Cyan
Write-Host ""

# 检查构建目录
$BuildFullPath = Join-Path $ProjectRoot $BuildDir
if (-not (Test-Path $BuildFullPath)) {
    Write-Host "错误：构建目录不存在：$BuildFullPath" -ForegroundColor Red
    Write-Host "请先运行构建脚本：.\scripts\build.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/2] 测试配置" -ForegroundColor Yellow
Write-Host "  构建目录：$BuildFullPath" -ForegroundColor Cyan
Write-Host "  测试套件：$TestSuite" -ForegroundColor Cyan
Write-Host ""

# 运行测试
Write-Host "[2/2] 运行测试..." -ForegroundColor Yellow

$CTestArgs = @(
    "--test-dir", $BuildFullPath
)

if ($TestSuite -ne "all") {
    $CTestArgs += "-L", $TestSuite
}

if ($Verbose) {
    $CTestArgs += "--verbose"
} else {
    $CTestArgs += "--output-on-failure"
}

Write-Host "  执行命令：ctest $($CTestArgs -join ' ')" -ForegroundColor Cyan
Write-Host ""

$StartTime = Get-Date

try {
    & ctest @CTestArgs
    $TestResult = $LASTEXITCODE
} catch {
    Write-Host ""
    Write-Host "错误：测试执行失败" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

$EndTime = Get-Date
$Duration = $EndTime - $StartTime

Write-Host ""

# 显示结果
if ($TestResult -eq 0) {
    Write-Host "✓ 所有测试通过！" -ForegroundColor Green
} else {
    Write-Host "✗ 部分测试失败" -ForegroundColor Red
}

Write-Host ""
Write-Host "测试时间：$($Duration.ToString('mm\:ss'))" -ForegroundColor Cyan
Write-Host ""

exit $TestResult
