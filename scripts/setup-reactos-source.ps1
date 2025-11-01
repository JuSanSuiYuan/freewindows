# 设置 ReactOS 源代码
# 克隆或更新 ReactOS 源代码

param(
    [Parameter(Mandatory=$false)]
    [string]$SourceDir = "src\reactos-full",
    
    [Parameter(Mandatory=$false)]
    [string]$Branch = "master",
    
    [switch]$Update
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FreeWindows ReactOS 源代码设置" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查 git
Write-Host "[1/3] 检查 Git..." -ForegroundColor Yellow

$git = Get-Command git -ErrorAction SilentlyContinue

if (-not $git) {
    Write-Host "错误：未找到 Git" -ForegroundColor Red
    Write-Host "请安装 Git: https://git-scm.com/" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Git 已安装: $($git.Version)" -ForegroundColor Green
Write-Host ""

# 检查源代码目录
Write-Host "[2/3] 检查源代码目录..." -ForegroundColor Yellow

if (Test-Path $SourceDir) {
    if ($Update) {
        Write-Host "更新现有源代码..." -ForegroundColor Cyan
        
        Push-Location $SourceDir
        
        Write-Host "  拉取最新更改..." -ForegroundColor White
        git pull origin $Branch
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ 源代码已更新" -ForegroundColor Green
        } else {
            Write-Host "✗ 更新失败" -ForegroundColor Red
            Pop-Location
            exit 1
        }
        
        Pop-Location
    } else {
        Write-Host "✓ 源代码目录已存在: $SourceDir" -ForegroundColor Green
        Write-Host "  使用 -Update 参数更新源代码" -ForegroundColor Cyan
    }
} else {
    Write-Host "克隆 ReactOS 源代码..." -ForegroundColor Cyan
    Write-Host "  仓库: https://github.com/reactos/reactos.git" -ForegroundColor White
    Write-Host "  分支: $Branch" -ForegroundColor White
    Write-Host "  目标: $SourceDir" -ForegroundColor White
    Write-Host ""
    Write-Host "  这可能需要 10-30 分钟，取决于网络速度..." -ForegroundColor Yellow
    Write-Host ""
    
    git clone --branch $Branch --depth 1 https://github.com/reactos/reactos.git $SourceDir
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ ReactOS 源代码克隆完成" -ForegroundColor Green
    } else {
        Write-Host "✗ 克隆失败" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""

# 验证源代码
Write-Host "[3/3] 验证源代码..." -ForegroundColor Yellow

$cmakeLists = Join-Path $SourceDir "CMakeLists.txt"

if (Test-Path $cmakeLists) {
    Write-Host "✓ 找到主 CMakeLists.txt" -ForegroundColor Green
    
    # 检查关键目录
    $keyDirs = @(
        "ntoskrnl",
        "dll",
        "drivers",
        "boot",
        "sdk"
    )
    
    $allFound = $true
    foreach ($dir in $keyDirs) {
        $path = Join-Path $SourceDir $dir
        if (Test-Path $path) {
            Write-Host "  ✓ $dir" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $dir (缺失)" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    if ($allFound) {
        Write-Host ""
        Write-Host "✓ ReactOS 源代码完整" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "⚠ ReactOS 源代码可能不完整" -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ 未找到主 CMakeLists.txt" -ForegroundColor Red
    Write-Host "  源代码可能不完整或损坏" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# 总结
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "设置完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "ReactOS 源代码位置: $SourceDir" -ForegroundColor Cyan
Write-Host ""

Write-Host "下一步：" -ForegroundColor Cyan
Write-Host "  1. 配置构建：" -ForegroundColor White
Write-Host "     .\scripts\configure-reactos.ps1 -ReactOSPath $SourceDir" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. 开始构建：" -ForegroundColor White
Write-Host "     cmake --build build\reactos-amd64-clang-cl --parallel" -ForegroundColor Gray
Write-Host ""

