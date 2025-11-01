# FreeWindows 构建脚本 (使用 Conan 包管理器)
# 该脚本使用 Conan 来管理依赖关系并构建项目

param(
    [Parameter(Mandatory=$false)]
    [string]$BuildType = "Debug",
    
    [Parameter(Mandatory=$false)]
    [string]$Arch = "amd64",
    
    [Parameter(Mandatory=$false)]
    [switch]$Clean,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# 获取脚本目录和项目根目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "=== FreeWindows 构建脚本 (Conan) ===" -ForegroundColor Cyan
Write-Host ""

# 检查 Conan 是否已安装
Write-Host "[1/5] 检查 Conan..." -ForegroundColor Yellow

function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

if (-not (Test-Command "conan")) {
    Write-Host "  ✗ Conan 未安装" -ForegroundColor Red
    Write-Host "  请从 https://conan.io/downloads.html 下载并安装 Conan" -ForegroundColor Yellow
    exit 1
} else {
    $ConanVersion = & conan --version 2>&1
    Write-Host "  ✓ Conan 已安装: $ConanVersion" -ForegroundColor Green
}

Write-Host ""

# 检查 CMake 和 Ninja
Write-Host "[2/5] 检查构建工具..." -ForegroundColor Yellow

if (-not (Test-Command "cmake")) {
    Write-Host "  ✗ CMake 未安装" -ForegroundColor Red
    Write-Host "  请从 https://cmake.org/download/ 下载并安装 CMake" -ForegroundColor Yellow
    exit 1
} else {
    $CMakeVersion = & cmake --version 2>&1 | Select-Object -First 1
    Write-Host "  ✓ CMake 已安装: $CMakeVersion" -ForegroundColor Green
}

if (-not (Test-Command "ninja")) {
    Write-Host "  ⚠ Ninja 未安装，将使用 Visual Studio 生成器" -ForegroundColor Yellow
    $Generator = "Visual Studio 17 2022"
} else {
    $NinjaVersion = & ninja --version 2>&1
    Write-Host "  ✓ Ninja 已安装: $NinjaVersion" -ForegroundColor Green
    $Generator = "Ninja"
}

Write-Host ""

# 安装 Conan 依赖
Write-Host "[3/5] 安装 Conan 依赖..." -ForegroundColor Yellow

$BuildDir = "build-conan"
$BuildFullPath = Join-Path $ProjectRoot $BuildDir

if ($Clean -and (Test-Path $BuildFullPath)) {
    Write-Host "  清理现有构建目录..." -ForegroundColor Yellow
    Remove-Item -Path $BuildFullPath -Recurse -Force
}

if (-not (Test-Path $BuildFullPath)) {
    New-Item -ItemType Directory -Path $BuildFullPath | Out-Null
    Write-Host "  ✓ 创建构建目录: $BuildFullPath" -ForegroundColor Green
} else {
    Write-Host "  ✓ 使用现有构建目录: $BuildFullPath" -ForegroundColor Green
}

Set-Location $BuildFullPath

# 使用 Conan 安装依赖
try {
    $ConanArgs = @(
        "install", 
        "..",
        "--build=missing",
        "-s", "build_type=$BuildType",
        "-s", "arch=$Arch"
    )
    
    if ($Verbose) {
        $ConanArgs += "-v"
    }
    
    Write-Host "  执行命令: conan $($ConanArgs -join ' ')" -ForegroundColor Gray
    & conan @ConanArgs
    
    if ($LASTEXITCODE -ne 0) {
        throw "Conan 安装依赖失败，退出码: $LASTEXITCODE"
    }
    
    Write-Host "  ✓ Conan 依赖安装完成" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "错误: Conan 安装依赖失败" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Set-Location $ProjectRoot
    exit 1
}

Write-Host ""

# 配置 CMake
Write-Host "[4/5] 配置 CMake..." -ForegroundColor Yellow

try {
    $CMakeArgs = @(
        "..",
        "-G", $Generator,
        "-DCMAKE_BUILD_TYPE=$BuildType"
    )
    
    # 如果使用 Ninja，设置编译器
    if ($Generator -eq "Ninja") {
        $CMakeArgs += "-DCMAKE_C_COMPILER=clang"
        $CMakeArgs += "-DCMAKE_CXX_COMPILER=clang++"
    }
    
    if ($Verbose) {
        $CMakeArgs += "--debug-output"
    }
    
    Write-Host "  执行命令: cmake $($CMakeArgs -join ' ')" -ForegroundColor Gray
    & cmake @CMakeArgs
    
    if ($LASTEXITCODE -ne 0) {
        throw "CMake 配置失败，退出码: $LASTEXITCODE"
    }
    
    Write-Host "  ✓ CMake 配置完成" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "错误: CMake 配置失败" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Set-Location $ProjectRoot
    exit 1
}

Write-Host ""

# 构建项目
Write-Host "[5/5] 构建项目..." -ForegroundColor Yellow

$StartTime = Get-Date

try {
    if ($Generator -eq "Ninja") {
        & cmake --build . --parallel
    } else {
        & cmake --build . --config $BuildType
    }
    
    if ($LASTEXITCODE -ne 0) {
        throw "构建失败，退出码: $LASTEXITCODE"
    }
    
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    
    Write-Host "  ✓ 构建完成! 耗时: $($Duration.ToString('mm\:ss'))" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "错误: 构建失败" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Set-Location $ProjectRoot
    exit 1
}

Write-Host ""

# 完成
Write-Host "=== 构建完成 ===" -ForegroundColor Green
Write-Host ""
Write-Host "构建目录: $BuildFullPath" -ForegroundColor Cyan
Write-Host "构建类型: $BuildType" -ForegroundColor Cyan
Write-Host "架构: $Arch" -ForegroundColor Cyan
Write-Host ""

Set-Location $ProjectRoot