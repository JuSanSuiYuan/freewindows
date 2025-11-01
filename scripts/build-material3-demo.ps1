# 构建 Material 3 演示项目
# 自动检测 Qt 并构建

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectDir = "demos\Material3Demo"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "构建 Material 3 演示" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查项目目录
if (-not (Test-Path $ProjectDir)) {
    Write-Host "错误：项目目录不存在: $ProjectDir" -ForegroundColor Red
    Write-Host "请先运行: .\scripts\create-material3-demo.ps1" -ForegroundColor Yellow
    exit 1
}

# 查找 Qt 安装
Write-Host "[1/4] 查找 Qt 安装..." -ForegroundColor Yellow

$qtPaths = @(
    "D:\QT\6.9.3\mingw_64",
    "D:\QT\6.8.0\mingw_64",
    "D:\QT\6.7.0\mingw_64",
    "C:\Qt\6.9.3\mingw_64",
    "C:\Qt\6.8.0\mingw_64"
)

$qtPath = $null
foreach ($path in $qtPaths) {
    if (Test-Path $path) {
        $qtPath = $path
        break
    }
}

if (-not $qtPath) {
    Write-Host "错误：未找到 Qt 安装" -ForegroundColor Red
    Write-Host "请手动指定 Qt 路径" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ 找到 Qt: $qtPath" -ForegroundColor Green

# 设置环境变量
$env:PATH = "$qtPath\bin;$env:PATH"
$env:CMAKE_PREFIX_PATH = $qtPath

# 查找 CMake
Write-Host ""
Write-Host "[2/4] 检查 CMake..." -ForegroundColor Yellow

$cmake = Get-Command cmake -ErrorAction SilentlyContinue
if (-not $cmake) {
    # 尝试使用 Qt 自带的 CMake
    $qtCMake = "D:\QT\Tools\CMake_64\bin\cmake.exe"
    if (Test-Path $qtCMake) {
        $env:PATH = "D:\QT\Tools\CMake_64\bin;$env:PATH"
        Write-Host "✓ 使用 Qt 自带的 CMake" -ForegroundColor Green
    } else {
        Write-Host "错误：未找到 CMake" -ForegroundColor Red
        Write-Host "请安装 CMake 或使用 Qt Creator" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "✓ 找到 CMake: $($cmake.Source)" -ForegroundColor Green
}

# 配置项目
Write-Host ""
Write-Host "[3/4] 配置项目..." -ForegroundColor Yellow

$buildDir = Join-Path $ProjectDir "build"

try {
    cmake -S $ProjectDir -B $buildDir `
          -G "MinGW Makefiles" `
          -DCMAKE_PREFIX_PATH=$qtPath `
          -DCMAKE_BUILD_TYPE=Release 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ 配置成功" -ForegroundColor Green
    } else {
        throw "配置失败"
    }
} catch {
    Write-Host "✗ 配置失败" -ForegroundColor Red
    Write-Host "错误信息: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "建议：使用 Qt Creator 打开项目" -ForegroundColor Yellow
    Write-Host "  1. 打开 Qt Creator" -ForegroundColor White
    Write-Host "  2. 文件 → 打开文件或项目" -ForegroundColor White
    Write-Host "  3. 选择: $ProjectDir\CMakeLists.txt" -ForegroundColor White
    exit 1
}

# 构建项目
Write-Host ""
Write-Host "[4/4] 构建项目..." -ForegroundColor Yellow

try {
    cmake --build $buildDir --config Release 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ 构建成功" -ForegroundColor Green
    } else {
        throw "构建失败"
    }
} catch {
    Write-Host "✗ 构建失败" -ForegroundColor Red
    Write-Host "错误信息: $_" -ForegroundColor Red
    exit 1
}

# 查找可执行文件
$exePath = Get-ChildItem -Path $buildDir -Filter "*.exe" -Recurse | Select-Object -First 1

if ($exePath) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "构建完成！" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "可执行文件: $($exePath.FullName)" -ForegroundColor Green
    Write-Host ""
    Write-Host "运行程序：" -ForegroundColor Yellow
    Write-Host "  $($exePath.FullName)" -ForegroundColor White
    Write-Host ""
    
    # 询问是否运行
    $response = Read-Host "是否立即运行？(Y/N)"
    if ($response -eq "Y" -or $response -eq "y") {
        Write-Host ""
        Write-Host "启动程序..." -ForegroundColor Cyan
        Start-Process $exePath.FullName
    }
} else {
    Write-Host "警告：未找到可执行文件" -ForegroundColor Yellow
}

