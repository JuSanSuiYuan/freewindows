# ReactOS LLVM/Clang 配置脚本
# 专门用于配置 ReactOS 的 Clang 构建

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("clang-cl", "clang-gnu")]
    [string]$Toolchain = "clang-cl",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("i386", "amd64")]
    [string]$Arch = "amd64",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Debug", "Release", "RelWithDebInfo", "MinSizeRel")]
    [string]$BuildType = "Debug",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Ninja", "Unix Makefiles")]
    [string]$Generator = "Ninja",
    
    [Parameter(Mandatory=$false)]
    [string]$ReactOSPath = "..\reactos",
    
    [Parameter(Mandatory=$false)]
    [string]$BuildDir = "build\reactos-$Arch-$Toolchain",
    
    [Parameter(Mandatory=$false)]
    [switch]$Clean,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose,
    
    [Parameter(Mandatory=$false)]
    [switch]$EnableLTO
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "=== ReactOS LLVM/Clang 配置脚本 ===" -ForegroundColor Cyan
Write-Host ""

# 检查工具
Write-Host "[1/7] 检查工具链..." -ForegroundColor Yellow

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
    $RequiredTools = @("clang-cl", "lld-link", "llvm-lib", "llvm-rc")
} else {
    $RequiredTools = @("clang", "clang++", "ld.lld", "llvm-ar", "llvm-rc")
}

$MissingTools = @()
foreach ($Tool in $RequiredTools) {
    if (-not (Test-Command $Tool)) {
        $MissingTools += $Tool
        Write-Host "  ✗ $Tool 未找到" -ForegroundColor Red
    } else {
        $Version = & $Tool --version 2>&1 | Select-Object -First 1
        Write-Host "  ✓ $Tool" -ForegroundColor Green
        if ($Verbose) {
            Write-Host "    $Version" -ForegroundColor Gray
        }
    }
}

if ($MissingTools.Count -gt 0) {
    Write-Host ""
    Write-Host "错误：缺少必需的工具：$($MissingTools -join ', ')" -ForegroundColor Red
    Write-Host "请安装 LLVM：https://github.com/llvm/llvm-project/releases" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Command "cmake")) {
    Write-Host ""
    Write-Host "错误：CMake 未安装" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ CMake" -ForegroundColor Green

if ($Generator -eq "Ninja" -and -not (Test-Command "ninja")) {
    Write-Host "  ⚠ Ninja 未安装，切换到 Unix Makefiles" -ForegroundColor Yellow
    $Generator = "Unix Makefiles"
} else {
    Write-Host "  ✓ $Generator" -ForegroundColor Green
}

Write-Host ""

# 检查 ReactOS 源代码
Write-Host "[2/7] 检查 ReactOS 源代码..." -ForegroundColor Yellow

$ReactOSFullPath = Join-Path $ProjectRoot $ReactOSPath
if (-not (Test-Path $ReactOSFullPath)) {
    Write-Host "  ✗ ReactOS 源代码未找到：$ReactOSFullPath" -ForegroundColor Red
    exit 1
}

$CMakeFile = Join-Path $ReactOSFullPath "CMakeLists.txt"
if (-not (Test-Path $CMakeFile)) {
    Write-Host "  ✗ CMakeLists.txt 未找到" -ForegroundColor Red
    exit 1
}

Write-Host "  ✓ ReactOS 源代码：$ReactOSFullPath" -ForegroundColor Green
Write-Host ""

# 准备构建目录
Write-Host "[3/7] 准备构建目录..." -ForegroundColor Yellow

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

# 配置编译器
Write-Host "[4/7] 配置编译器..." -ForegroundColor Yellow

$CMakeArgs = @(
    "-S", $ReactOSFullPath,
    "-B", $BuildFullPath,
    "-G", $Generator,
    "-DARCH=$Arch",
    "-DCMAKE_BUILD_TYPE=$BuildType"
)

if ($Toolchain -eq "clang-cl") {
    Write-Host "  使用 Clang-CL (MSVC 兼容模式)" -ForegroundColor Cyan
    $CMakeArgs += "-DCMAKE_C_COMPILER=clang-cl"
    $CMakeArgs += "-DCMAKE_CXX_COMPILER=clang-cl"
    $CMakeArgs += "-DCMAKE_LINKER=lld-link"
} else {
    Write-Host "  使用 Clang (GCC 兼容模式)" -ForegroundColor Cyan
    $CMakeArgs += "-DCMAKE_C_COMPILER=clang"
    $CMakeArgs += "-DCMAKE_CXX_COMPILER=clang++"
    $CMakeArgs += "-DCMAKE_LINKER=ld.lld"
}

Write-Host "  架构：$Arch" -ForegroundColor Cyan
Write-Host "  构建类型：$BuildType" -ForegroundColor Cyan
Write-Host "  生成器：$Generator" -ForegroundColor Cyan

Write-Host ""

# 配置 ReactOS 特定选项
Write-Host "[5/7] 配置 ReactOS 选项..." -ForegroundColor Yellow

# 优化级别
if ($BuildType -eq "Debug") {
    $CMakeArgs += "-DOPTIMIZE=4"  # -O1
    $CMakeArgs += "-DDBG=1"
    Write-Host "  优化级别：4 (-O1, 调试)" -ForegroundColor Cyan
} elseif ($BuildType -eq "Release") {
    $CMakeArgs += "-DOPTIMIZE=5"  # -O2
    $CMakeArgs += "-DDBG=0"
    Write-Host "  优化级别：5 (-O2, 发布)" -ForegroundColor Cyan
}

# LTO
if ($EnableLTO) {
    $CMakeArgs += "-DLTCG=TRUE"
    Write-Host "  链接时优化：启用" -ForegroundColor Cyan
} else {
    Write-Host "  链接时优化：禁用" -ForegroundColor Cyan
}

# 预编译头（Clang 支持）
$CMakeArgs += "-DPCH=ON"
Write-Host "  预编译头：启用" -ForegroundColor Cyan

# 导出编译命令（用于 Clang-Tidy）
$CMakeArgs += "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
Write-Host "  导出编译命令：启用" -ForegroundColor Cyan

Write-Host ""

# 运行 CMake
Write-Host "[6/7] 运行 CMake 配置..." -ForegroundColor Yellow

if ($Verbose) {
    $CMakeArgs += "--debug-output"
}

Write-Host "  执行命令：" -ForegroundColor Gray
Write-Host "    cmake $($CMakeArgs -join ' ')" -ForegroundColor Gray
Write-Host ""

$StartTime = Get-Date

try {
    & cmake @CMakeArgs
    if ($LASTEXITCODE -ne 0) {
        throw "CMake 配置失败，退出码：$LASTEXITCODE"
    }
} catch {
    Write-Host ""
    Write-Host "错误：CMake 配置失败" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "可能的原因：" -ForegroundColor Yellow
    Write-Host "  1. Clang 版本不兼容（需要 10.0.0+）" -ForegroundColor White
    Write-Host "  2. 缺少必需的工具" -ForegroundColor White
    Write-Host "  3. ReactOS 源代码不完整" -ForegroundColor White
    Write-Host ""
    Write-Host "请查看上面的错误信息，并更新 docs/migration-notes.md" -ForegroundColor Yellow
    exit 1
}

$EndTime = Get-Date
$Duration = $EndTime - $StartTime

Write-Host ""

# 完成
Write-Host "[7/7] 配置完成！" -ForegroundColor Green
Write-Host ""
Write-Host "配置时间：$($Duration.ToString('mm\:ss'))" -ForegroundColor Cyan
Write-Host "构建目录：$BuildFullPath" -ForegroundColor Cyan
Write-Host "工具链：$Toolchain" -ForegroundColor Cyan
Write-Host "架构：$Arch" -ForegroundColor Cyan
Write-Host "构建类型：$BuildType" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步：" -ForegroundColor Yellow
Write-Host "  构建 ReactOS：" -ForegroundColor White
Write-Host "    cmake --build `"$BuildFullPath`" --parallel" -ForegroundColor Gray
Write-Host ""
Write-Host "  或使用构建脚本：" -ForegroundColor White
Write-Host "    .\scripts\build.ps1 -BuildDir `"$BuildDir`"" -ForegroundColor Gray
Write-Host ""
