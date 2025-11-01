# 运行 Material3 演示的脚本
# 自动处理 Qt DLL 依赖

param(
    [switch]$Rebuild = $false
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Material3 Demo 启动器" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$demoPath = "demos\Material3Demo"
$buildPath = "$demoPath\build"
$exePath = "$buildPath\Material3Demo.exe"

# 检查可执行文件是否存在
if (-not (Test-Path $exePath)) {
    Write-Host "❌ 找不到可执行文件: $exePath" -ForegroundColor Red
    Write-Host ""
    Write-Host "正在尝试构建..." -ForegroundColor Yellow
    $Rebuild = $true
}

# 重新构建（如果需要）
if ($Rebuild) {
    Write-Host "正在构建 Material3Demo..." -ForegroundColor Yellow
    
    # 查找 Qt
    $qtPaths = @(
        "D:\Qt\6.9.3\mingw_64\bin",
        "D:\Qt\6.8.0\mingw_64\bin",
        "D:\Qt\6.7.0\mingw_64\bin",
        "D:\Qt\6.6.0\mingw_64\bin",
        "D:\Qt\5.15.2\mingw81_64\bin",
        "C:\Qt\6.9.3\mingw_64\bin",
        "C:\Qt\6.8.0\mingw_64\bin"
    )
    
    $qtFound = $false
    foreach ($qtPath in $qtPaths) {
        if (Test-Path $qtPath) {
            Write-Host "✓ 找到 Qt: $qtPath" -ForegroundColor Green
            $env:PATH = "$qtPath;$env:PATH"
            $qtFound = $true
            break
        }
    }
    
    if (-not $qtFound) {
        Write-Host "❌ 找不到 Qt 安装" -ForegroundColor Red
        Write-Host "请确保 Qt 已安装在 D:\Qt 或 C:\Qt" -ForegroundColor Yellow
        exit 1
    }
    
    # 构建
    Push-Location $demoPath
    try {
        Write-Host "配置 CMake..." -ForegroundColor Yellow
        cmake -B build -G Ninja 2>&1 | Out-Null
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ CMake 配置失败" -ForegroundColor Red
            Pop-Location
            exit 1
        }
        
        Write-Host "编译..." -ForegroundColor Yellow
        cmake --build build 2>&1 | Out-Null
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ 编译失败" -ForegroundColor Red
            Pop-Location
            exit 1
        }
        
        Write-Host "✓ 构建成功" -ForegroundColor Green
    }
    finally {
        Pop-Location
    }
    Write-Host ""
}

# 查找 Qt DLL
Write-Host "检查 Qt 依赖..." -ForegroundColor Yellow

$qtPaths = @(
    "D:\Qt\6.9.3\mingw_64\bin",
    "D:\Qt\6.8.0\mingw_64\bin",
    "D:\Qt\6.7.0\mingw_64\bin",
    "D:\Qt\6.6.0\mingw_64\bin",
    "D:\Qt\5.15.2\mingw81_64\bin",
    "C:\Qt\6.9.3\mingw_64\bin",
    "C:\Qt\6.8.0\mingw_64\bin"
)

$qtBinPath = $null
foreach ($path in $qtPaths) {
    if (Test-Path $path) {
        $qtBinPath = $path
        Write-Host "✓ 找到 Qt bin 目录: $qtBinPath" -ForegroundColor Green
        break
    }
}

if (-not $qtBinPath) {
    Write-Host "⚠️  警告: 找不到 Qt bin 目录" -ForegroundColor Yellow
    Write-Host "程序可能因缺少 DLL 而无法启动" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "请确保 Qt 已安装，并且路径类似于:" -ForegroundColor Yellow
    Write-Host "  D:\Qt\6.x.x\mingw_64\bin" -ForegroundColor Gray
    Write-Host "  或" -ForegroundColor Gray
    Write-Host "  C:\Qt\6.x.x\mingw_64\bin" -ForegroundColor Gray
    Write-Host ""
    
    $response = Read-Host "是否继续尝试运行? (y/n)"
    if ($response -ne "y") {
        exit 1
    }
} else {
    # 添加 Qt bin 到 PATH
    $env:PATH = "$qtBinPath;$env:PATH"
}

# 运行程序
Write-Host ""
Write-Host "启动 Material3Demo..." -ForegroundColor Green
Write-Host "如果窗口没有出现，请检查任务栏或按 Alt+Tab" -ForegroundColor Yellow
Write-Host ""

try {
    # 使用 Start-Process 以便程序在独立窗口运行
    $process = Start-Process -FilePath $exePath -PassThru -WindowStyle Normal
    
    # 等待一下看程序是否立即退出
    Start-Sleep -Milliseconds 500
    
    if ($process.HasExited) {
        Write-Host "❌ 程序启动后立即退出" -ForegroundColor Red
        Write-Host "退出代码: $($process.ExitCode)" -ForegroundColor Red
        Write-Host ""
        Write-Host "可能的原因:" -ForegroundColor Yellow
        Write-Host "1. 缺少 Qt DLL 文件" -ForegroundColor Gray
        Write-Host "2. Qt 版本不匹配" -ForegroundColor Gray
        Write-Host "3. 缺少其他依赖库" -ForegroundColor Gray
        Write-Host ""
        Write-Host "建议:" -ForegroundColor Yellow
        Write-Host "1. 使用 -Rebuild 参数重新构建: .\scripts\run-material3-demo.ps1 -Rebuild" -ForegroundColor Gray
        Write-Host "2. 确保 Qt 已正确安装" -ForegroundColor Gray
        Write-Host "3. 尝试使用 Qt Creator 打开并运行项目" -ForegroundColor Gray
    } else {
        Write-Host "✓ 程序已启动 (PID: $($process.Id))" -ForegroundColor Green
        Write-Host ""
        Write-Host "窗口特性:" -ForegroundColor Cyan
        Write-Host "  • 天蓝色 → 草绿色 → 粉红色渐变背景" -ForegroundColor Gray
        Write-Host "  • 圆角窗口" -ForegroundColor Gray
        Write-Host "  • 三个彩色按钮" -ForegroundColor Gray
        Write-Host "  • 可拖动标题栏" -ForegroundColor Gray
        Write-Host "  • 按钮点击动画" -ForegroundColor Gray
        Write-Host ""
        Write-Host "按任意键关闭此窗口..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}
catch {
    Write-Host "❌ 启动失败: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "请尝试:" -ForegroundColor Yellow
    Write-Host "1. 使用 Qt Creator 打开项目" -ForegroundColor Gray
    Write-Host "2. 检查 Qt 安装" -ForegroundColor Gray
    Write-Host "3. 重新构建项目" -ForegroundColor Gray
}
