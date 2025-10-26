# FreeWindows 优化配置脚本
# CMake + Ninja + ccache 性能优化方案

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
    [string]$ReactOSPath = "..\reactos",
    
    [Parameter(Mandatory=$false)]
    [string]$BuildDir = "build\reactos-$Arch-$Toolchain-optimized",
    
    [Parameter(Mandatory=$false)]
    [switch]$EnableCCache,
    
    [Parameter(Mandatory=$false)]
    [switch]$EnableLTO,
    
    [Parameter(Mandatory=$false)]
    [switch]$EnableUnityBuild,
    
    [Parameter(Mandatory=$false)]
    [int]$Jobs = 0,
    
    [Parameter(Mandatory=$false)]
    [switch]$Clean,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "=== FreeWindows 优化配置脚本 ===" -ForegroundColor Cyan
Write-Host "CMake + Ninja + ccache 性能优化方案" -ForegroundColor Cyan
Write-Host ""

# 检查工具
Write-Host "[1/8] 检查工具链..." -ForegroundColor Yellow

function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

# 检查必需工具
$RequiredTools = @{
    "cmake" = @{Required=$true; Description="CMake 构建系统"}
    "ninja" = @{Required=$true; Description="Ninja 构建工具"}
}

if ($Toolchain -eq "clang-cl") {
    $RequiredTools["clang-cl"] = @{Required=$true; Description="Clang-CL 编译器"}
    $RequiredTools["lld-link"] = @{Required=$true; Description="LLD 链接器"}
} else {
    $RequiredTools["clang"] = @{Required=$true; Description="Clang 编译器"}
    $RequiredTools["clang++"] = @{Required=$true; Description="Clang++ 编译器"}
    $RequiredTools["ld.lld"] = @{Required=$true; Description="LLD 链接器"}
}

# 检查可选工具
$OptionalTools = @{
    "ccache" = @{Required=$false; Description="编译缓存"}
    "sccache" = @{Required=$false; Description="编译缓存（替代 ccache）"}
}

$AllFound = $true
$CacheFound = $false

Write-Host "  必需工具：" -ForegroundColor Cyan
foreach ($Tool in $RequiredTools.Keys) {
    if (Test-Command $Tool) {
        Write-Host "    ✓ $Tool" -ForegroundColor Green -NoNewline
        Write-Host " - $($RequiredTools[$Tool].Description)" -ForegroundColor Gray
    } else {
        Write-Host "    ✗ $Tool" -ForegroundColor Red -NoNewline
        Write-Host " - $($RequiredTools[$Tool].Description)" -ForegroundColor Gray
        $AllFound = $false
    }
}

Write-Host ""
Write-Host "  可选工具：" -ForegroundColor Cyan
foreach ($Tool in $OptionalTools.Keys) {
    if (Test-Command $Tool) {
        Write-Host "    ✓ $Tool" -ForegroundColor Green -NoNewline
        Write-Host " - $($OptionalTools[$Tool].Description)" -ForegroundColor Gray
        if ($Tool -eq "ccache" -or $Tool -eq "sccache") {
            $CacheFound = $true
        }
    } else {
        Write-Host "    ⚠ $Tool" -ForegroundColor Yellow -NoNewline
        Write-Host " - $($OptionalTools[$Tool].Description) [可选]" -ForegroundColor Gray
    }
}

if (-not $AllFound) {
    Write-Host ""
    Write-Host "错误：缺少必需的工具" -ForegroundColor Red
    Write-Host ""
    Write-Host "安装方法：" -ForegroundColor Yellow
    Write-Host "  choco install cmake ninja llvm" -ForegroundColor White
    Write-Host "  # 或" -ForegroundColor Gray
    Write-Host "  scoop install cmake ninja llvm" -ForegroundColor White
    exit 1
}

Write-Host ""

# 检查 ReactOS 源代码
Write-Host "[2/8] 检查 ReactOS 源代码..." -ForegroundColor Yellow

$ReactOSFullPath = Join-Path $ProjectRoot $ReactOSPath
if (-not (Test-Path $ReactOSFullPath)) {
    Write-Host "  ✗ ReactOS 源代码未找到：$ReactOSFullPath" -ForegroundColor Red
    exit 1
}

Write-Host "  ✓ ReactOS 源代码：$ReactOSFullPath" -ForegroundColor Green
Write-Host ""

# 准备构建目录
Write-Host "[3/8] 准备构建目录..." -ForegroundColor Yellow

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
Write-Host "[4/8] 配置编译器..." -ForegroundColor Yellow

$CMakeArgs = @(
    "-S", $ReactOSFullPath,
    "-B", $BuildFullPath,
    "-G", "Ninja",
    "-DARCH=$Arch",
    "-DCMAKE_BUILD_TYPE=$BuildType"
)

if ($Toolchain -eq "clang-cl") {
    Write-Host "  工具链：Clang-CL (MSVC 兼容模式)" -ForegroundColor Cyan
    $CMakeArgs += "-DCMAKE_C_COMPILER=clang-cl"
    $CMakeArgs += "-DCMAKE_CXX_COMPILER=clang-cl"
    $CMakeArgs += "-DCMAKE_LINKER=lld-link"
} else {
    Write-Host "  工具链：Clang (GCC 兼容模式)" -ForegroundColor Cyan
    $CMakeArgs += "-DCMAKE_C_COMPILER=clang"
    $CMakeArgs += "-DCMAKE_CXX_COMPILER=clang++"
    $CMakeArgs += "-DCMAKE_LINKER=ld.lld"
}

Write-Host "  架构：$Arch" -ForegroundColor Cyan
Write-Host "  构建类型：$BuildType" -ForegroundColor Cyan
Write-Host "  生成器：Ninja" -ForegroundColor Cyan

Write-Host ""

# 配置性能优化
Write-Host "[5/8] 配置性能优化..." -ForegroundColor Yellow

# ccache 配置
if ($EnableCCache -or $CacheFound) {
    if (Test-Command "ccache") {
        Write-Host "  ✓ 启用 ccache 编译缓存" -ForegroundColor Green
        $CMakeArgs += "-DCMAKE_C_COMPILER_LAUNCHER=ccache"
        $CMakeArgs += "-DCMAKE_CXX_COMPILER_LAUNCHER=ccache"
        
        # 配置 ccache
        $env:CCACHE_DIR = Join-Path $ProjectRoot ".ccache"
        $env:CCACHE_MAXSIZE = "10G"
        $env:CCACHE_COMPRESS = "true"
        $env:CCACHE_COMPRESSLEVEL = "6"
        
        Write-Host "    缓存目录：$env:CCACHE_DIR" -ForegroundColor Gray
        Write-Host "    最大大小：$env:CCACHE_MAXSIZE" -ForegroundColor Gray
        
    } elseif (Test-Command "sccache") {
        Write-Host "  ✓ 启用 sccache 编译缓存" -ForegroundColor Green
        $CMakeArgs += "-DCMAKE_C_COMPILER_LAUNCHER=sccache"
        $CMakeArgs += "-DCMAKE_CXX_COMPILER_LAUNCHER=sccache"
    } else {
        Write-Host "  ⚠ 未找到 ccache 或 sccache，跳过缓存配置" -ForegroundColor Yellow
        Write-Host "    安装方法：choco install ccache" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⊘ 未启用编译缓存（使用 -EnableCCache 启用）" -ForegroundColor Gray
}

# LTO 配置
if ($EnableLTO) {
    Write-Host "  ✓ 启用 LTO（链接时优化）" -ForegroundColor Green
    $CMakeArgs += "-DLTCG=TRUE"
    $CMakeArgs += "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=TRUE"
} else {
    Write-Host "  ⊘ 未启用 LTO（使用 -EnableLTO 启用）" -ForegroundColor Gray
}

# Unity Build 配置
if ($EnableUnityBuild) {
    Write-Host "  ✓ 启用 Unity Build（合并编译单元）" -ForegroundColor Green
    $CMakeArgs += "-DCMAKE_UNITY_BUILD=TRUE"
    $CMakeArgs += "-DCMAKE_UNITY_BUILD_BATCH_SIZE=16"
} else {
    Write-Host "  ⊘ 未启用 Unity Build（使用 -EnableUnityBuild 启用）" -ForegroundColor Gray
}

# 并行任务数
if ($Jobs -eq 0) {
    $Jobs = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
}
Write-Host "  并行任务数：$Jobs" -ForegroundColor Cyan

# 导出编译命令
$CMakeArgs += "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
Write-Host "  ✓ 导出编译命令（compile_commands.json）" -ForegroundColor Green

Write-Host ""

# 配置 ReactOS 选项
Write-Host "[6/8] 配置 ReactOS 选项..." -ForegroundColor Yellow

if ($BuildType -eq "Debug") {
    $CMakeArgs += "-DOPTIMIZE=4"  # -O1
    $CMakeArgs += "-DDBG=1"
    Write-Host "  优化级别：4 (-O1, 调试)" -ForegroundColor Cyan
} elseif ($BuildType -eq "Release") {
    $CMakeArgs += "-DOPTIMIZE=5"  # -O2
    $CMakeArgs += "-DDBG=0"
    Write-Host "  优化级别：5 (-O2, 发布)" -ForegroundColor Cyan
}

# 预编译头
$CMakeArgs += "-DPCH=ON"
Write-Host "  ✓ 启用预编译头" -ForegroundColor Green

Write-Host ""

# 运行 CMake
Write-Host "[7/8] 运行 CMake 配置..." -ForegroundColor Yellow

if ($Verbose) {
    $CMakeArgs += "--debug-output"
}

Write-Host "  执行命令：" -ForegroundColor Gray
Write-Host "    cmake $($CMakeArgs -join ' ')" -ForegroundColor DarkGray
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
    exit 1
}

$EndTime = Get-Date
$Duration = $EndTime - $StartTime

Write-Host ""

# 完成
Write-Host "[8/8] 配置完成！" -ForegroundColor Green
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "配置摘要" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "  构建目录：$BuildFullPath" -ForegroundColor White
Write-Host "  工具链：$Toolchain" -ForegroundColor White
Write-Host "  架构：$Arch" -ForegroundColor White
Write-Host "  构建类型：$BuildType" -ForegroundColor White
Write-Host "  生成器：Ninja" -ForegroundColor White
Write-Host ""
Write-Host "  性能优化：" -ForegroundColor White
if ($EnableCCache -or $CacheFound) {
    Write-Host "    ✓ 编译缓存（ccache/sccache）" -ForegroundColor Green
} else {
    Write-Host "    ✗ 编译缓存" -ForegroundColor Red
}
if ($EnableLTO) {
    Write-Host "    ✓ LTO（链接时优化）" -ForegroundColor Green
} else {
    Write-Host "    ✗ LTO" -ForegroundColor Red
}
if ($EnableUnityBuild) {
    Write-Host "    ✓ Unity Build" -ForegroundColor Green
} else {
    Write-Host "    ✗ Unity Build" -ForegroundColor Red
}
Write-Host "    ✓ 预编译头（PCH）" -ForegroundColor Green
Write-Host "    ✓ 并行编译（$Jobs 任务）" -ForegroundColor Green
Write-Host ""
Write-Host "  配置时间：$($Duration.ToString('mm\:ss'))" -ForegroundColor White
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步：开始构建" -ForegroundColor Yellow
Write-Host ""
Write-Host "  快速构建：" -ForegroundColor White
Write-Host "    ninja -C `"$BuildFullPath`" -j$Jobs" -ForegroundColor Cyan
Write-Host ""
Write-Host "  或使用构建脚本：" -ForegroundColor White
Write-Host "    .\scripts\build.ps1 -BuildDir `"$BuildDir`" -Jobs $Jobs" -ForegroundColor Cyan
Write-Host ""
Write-Host "  查看缓存统计（如果启用 ccache）：" -ForegroundColor White
Write-Host "    ccache -s" -ForegroundColor Cyan
Write-Host ""
