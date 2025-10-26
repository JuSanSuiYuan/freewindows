# FreeWindows 配置脚本
# 用于配置 ReactOS 的 LLVM 构建环境

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("clang-cl", "clang-gnu")]
    [string]$Toolchain = "clang-cl",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Debug", "Release", "RelWithDebInfo", "MinSizeRel")]
    [string]$BuildType = "Release",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Ninja", "Visual Studio 17 2022", "Unix Makefiles")]
    [string]$Generator = "Ninja",
    
    [Parameter(Mandatory=$false)]
    [string]$ReactOSPath = "..\reactos",
    
    [Parameter(Mandatory=$false)]
    [string]$BuildDir = "build",
    
    [Parameter(Mandatory=$false)]
    [switch]$Clean,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

# 设置错误处理
$ErrorActionPreference = "Stop"

# 脚本目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "=== FreeWindows 配置脚本 ===" -ForegroundColor Cyan
Write-Host ""

# 检查工具链
Write-Host "[1/6] 检查工具链..." -ForegroundColor Yellow

function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

$RequiredTools = @()
if ($Toolchain -eq "clang-cl") {
    $RequiredTools = @("clang-cl", "lld-link", "llvm-ar")
} else {
    $RequiredTools = @("clang", "clang++", "ld.lld", "llvm-ar")
}

$MissingTools = @()
foreach ($Tool in $RequiredTools) {
    if (-not (Test-Command $Tool)) {
        $MissingTools += $Tool
        Write-Host "  ✗ $Tool 未找到" -ForegroundColor Red
    } else {
        Write-Host "  ✓ $Tool 已安装" -ForegroundColor Green
    }
}

if ($MissingTools.Count -gt 0) {
    Write-Host ""
    Write-Host "错误：缺少必需的工具：$($MissingTools -join ', ')" -ForegroundColor Red
    Write-Host "请安装 LLVM 工具链：https://github.com/llvm/llvm-project/releases" -ForegroundColor Yellow
    exit 1
}

# 检查 CMake
if (-not (Test-Command "cmake")) {
    Write-Host ""
    Write-Host "错误：CMake 未安装" -ForegroundColor Red
    Write-Host "请安装 CMake：https://cmake.org/download/" -ForegroundColor Yellow
    exit 1
}
Write-Host "  ✓ CMake 已安装" -ForegroundColor Green

# 检查生成器
if ($Generator -eq "Ninja" -and -not (Test-Command "ninja")) {
    Write-Host ""
    Write-Host "警告：Ninja 未安装，切换到 'Unix Makefiles' 生成器" -ForegroundColor Yellow
    $Generator = "Unix Makefiles"
}

Write-Host ""

# 检查 ReactOS 路径
Write-Host "[2/6] 检查 ReactOS 源代码..." -ForegroundColor Yellow

$ReactOSFullPath = Join-Path $ProjectRoot $ReactOSPath | Resolve-Path -ErrorAction SilentlyContinue
if (-not $ReactOSFullPath -or -not (Test-Path $ReactOSFullPath)) {
    Write-Host "  ✗ ReactOS 源代码未找到：$ReactOSPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "请确保 ReactOS 源代码在正确的位置" -ForegroundColor Yellow
    Write-Host "或使用 -ReactOSPath 参数指定路径" -ForegroundColor Yellow
    exit 1
}
Write-Host "  ✓ ReactOS 源代码：$ReactOSFullPath" -ForegroundColor Green

Write-Host ""

# 创建构建目录
Write-Host "[3/6] 准备构建目录..." -ForegroundColor Yellow

$BuildFullPath = Join-Path $ProjectRoot $BuildDir
if ($Clean -and (Test-Path $BuildFullPath)) {
    Write-Host "  清理现有构建目录..." -ForegroundColor Yellow
    Remove-Item -Path $BuildFullPath -Recurse -Force
}

if (-not (Test-Path $BuildFullPath)) {
    New-Item -ItemType Directory -Path $BuildFullPath | Out-Null
    Write-Host "  ✓ 创建构建目录：$BuildFullPath" -ForegroundColor Green
} else {
    Write-Host "  ✓ 使用现有构建目录：$BuildFullPath" -ForegroundColor Green
}

Write-Host ""

# 设置工具链文件
Write-Host "[4/6] 配置工具链..." -ForegroundColor Yellow

$ToolchainFile = Join-Path $ProjectRoot "cmake\toolchains\$Toolchain.cmake"
if (-not (Test-Path $ToolchainFile)) {
    Write-Host "  ✗ 工具链文件未找到：$ToolchainFile" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ 工具链文件：$ToolchainFile" -ForegroundColor Green
Write-Host "  ✓ 工具链类型：$Toolchain" -ForegroundColor Green
Write-Host "  ✓ 构建类型：$BuildType" -ForegroundColor Green
Write-Host "  ✓ 生成器：$Generator" -ForegroundColor Green

Write-Host ""

# 运行 CMake 配置
Write-Host "[5/6] 运行 CMake 配置..." -ForegroundColor Yellow

$CMakeArgs = @(
    "-S", $ReactOSFullPath,
    "-B", $BuildFullPath,
    "-G", $Generator,
    "-DCMAKE_TOOLCHAIN_FILE=$ToolchainFile",
    "-DCMAKE_BUILD_TYPE=$BuildType",
    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
)

if ($Verbose) {
    $CMakeArgs += "--debug-output"
}

Write-Host "  执行命令：cmake $($CMakeArgs -join ' ')" -ForegroundColor Cyan
Write-Host ""

try {
    & cmake @CMakeArgs
    if ($LASTEXITCODE -ne 0) {
        throw "CMake 配置失败，退出码：$LASTEXITCODE"
    }
} catch {
    Write-Host ""
    Write-Host "错误：CMake 配置失败" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host ""

# 完成
Write-Host "[6/6] 配置完成！" -ForegroundColor Green
Write-Host ""
Write-Host "构建目录：$BuildFullPath" -ForegroundColor Cyan
Write-Host "工具链：$Toolchain" -ForegroundColor Cyan
Write-Host "构建类型：$BuildType" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步：" -ForegroundColor Yellow
Write-Host "  运行构建：.\scripts\build.ps1" -ForegroundColor White
Write-Host "  运行测试：.\scripts\test.ps1" -ForegroundColor White
Write-Host ""
