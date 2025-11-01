# 分析当前构建状态
# 检查已编译的组件和待编译的组件

param(
    [Parameter(Mandatory=$false)]
    [string]$BuildDir = "build\reactos-amd64-clang-cl"
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FreeWindows 构建状态分析" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查构建目录
if (-not (Test-Path $BuildDir)) {
    Write-Host "错误：构建目录不存在: $BuildDir" -ForegroundColor Red
    exit 1
}

# 统计已生成的文件
Write-Host "[1/4] 统计已生成的文件" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$exeFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue
$dllFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.dll" -ErrorAction SilentlyContinue
$sysFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.sys" -ErrorAction SilentlyContinue
$libFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.lib" -ErrorAction SilentlyContinue
$objFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.obj" -ErrorAction SilentlyContinue

Write-Host "  可执行文件 (.exe): $($exeFiles.Count)" -ForegroundColor Cyan
Write-Host "  动态库 (.dll): $($dllFiles.Count)" -ForegroundColor Cyan
Write-Host "  驱动程序 (.sys): $($sysFiles.Count)" -ForegroundColor Cyan
Write-Host "  静态库 (.lib): $($libFiles.Count)" -ForegroundColor Cyan
Write-Host "  目标文件 (.obj): $($objFiles.Count)" -ForegroundColor Cyan

Write-Host ""

# 列出可执行文件
if ($exeFiles.Count -gt 0) {
    Write-Host "已编译的可执行文件：" -ForegroundColor Yellow
    $exeFiles | ForEach-Object {
        $size = [math]::Round($_.Length / 1KB, 2)
        Write-Host "  $($_.Name) ($size KB)" -ForegroundColor White
    }
    Write-Host ""
}

# 检查构建日志
Write-Host "[2/4] 检查构建日志" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$logFiles = Get-ChildItem -Path $BuildDir -Filter "*.log" -ErrorAction SilentlyContinue

if ($logFiles.Count -gt 0) {
    Write-Host "找到 $($logFiles.Count) 个日志文件：" -ForegroundColor Cyan
    
    foreach ($log in $logFiles) {
        Write-Host "  $($log.Name)" -ForegroundColor White
        
        if (Test-Path $log.FullName) {
            $content = Get-Content $log.FullName -Raw -ErrorAction SilentlyContinue
            
            if ($content) {
                $errors = ([regex]::Matches($content, "error:")).Count
                $warnings = ([regex]::Matches($content, "warning:")).Count
                
                Write-Host "    错误: $errors, 警告: $warnings" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })
            }
        }
    }
} else {
    Write-Host "  未找到构建日志" -ForegroundColor Yellow
}

Write-Host ""

# 检查 CMake 缓存
Write-Host "[3/4] 检查 CMake 配置" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$cmakeCache = "$BuildDir\CMakeCache.txt"

if (Test-Path $cmakeCache) {
    $cacheContent = Get-Content $cmakeCache
    
    # 提取关键配置
    $compiler = $cacheContent | Select-String "CMAKE_C_COMPILER:FILEPATH=" | ForEach-Object { $_ -replace ".*=", "" }
    $buildType = $cacheContent | Select-String "CMAKE_BUILD_TYPE:STRING=" | ForEach-Object { $_ -replace ".*=", "" }
    $generator = $cacheContent | Select-String "CMAKE_GENERATOR:INTERNAL=" | ForEach-Object { $_ -replace ".*=", "" }
    
    Write-Host "  编译器: $compiler" -ForegroundColor Cyan
    Write-Host "  构建类型: $buildType" -ForegroundColor Cyan
    Write-Host "  生成器: $generator" -ForegroundColor Cyan
} else {
    Write-Host "  未找到 CMake 缓存" -ForegroundColor Yellow
}

Write-Host ""

# 检查可用目标
Write-Host "[4/4] 检查可用构建目标" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

Write-Host "正在查询可用目标..." -ForegroundColor Cyan

$targets = cmake --build $BuildDir --target help 2>&1 | Out-String

# 提取目标名称
$targetList = $targets -split "`n" | Where-Object { $_ -match "^\w+" -and $_ -notmatch "phony|edit_cache|rebuild_cache|install" } | ForEach-Object { $_.Trim() }

if ($targetList.Count -gt 0) {
    Write-Host "找到 $($targetList.Count) 个构建目标" -ForegroundColor Cyan
    Write-Host ""
    
    # 显示前 20 个目标
    Write-Host "前 20 个目标：" -ForegroundColor Yellow
    $targetList | Select-Object -First 20 | ForEach-Object {
        Write-Host "  $_" -ForegroundColor White
    }
    
    if ($targetList.Count -gt 20) {
        Write-Host "  ... 还有 $($targetList.Count - 20) 个目标" -ForegroundColor Gray
    }
} else {
    Write-Host "  未找到构建目标" -ForegroundColor Yellow
}

Write-Host ""

# 总结
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "构建状态总结" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalFiles = $exeFiles.Count + $dllFiles.Count + $sysFiles.Count + $libFiles.Count

if ($totalFiles -gt 0) {
    Write-Host "✓ 已成功编译 $totalFiles 个文件" -ForegroundColor Green
} else {
    Write-Host "⚠ 尚未编译任何文件" -ForegroundColor Yellow
}

Write-Host ""

# 建议
Write-Host "建议的下一步：" -ForegroundColor Cyan

if ($exeFiles.Count -gt 0 -and $dllFiles.Count -eq 0) {
    Write-Host "  1. 当前只编译了工具，尝试编译完整系统：" -ForegroundColor White
    Write-Host "     .\scripts\build-full-system.ps1" -ForegroundColor Gray
} elseif ($totalFiles -eq 0) {
    Write-Host "  1. 重新配置构建：" -ForegroundColor White
    Write-Host "     .\scripts\configure-reactos.ps1" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. 开始构建：" -ForegroundColor White
    Write-Host "     cmake --build $BuildDir --parallel" -ForegroundColor Gray
} else {
    Write-Host "  1. 继续完整构建：" -ForegroundColor White
    Write-Host "     cmake --build $BuildDir --parallel" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. 生成 ISO 镜像：" -ForegroundColor White
    Write-Host "     cmake --build $BuildDir --target bootcd" -ForegroundColor Gray
}

Write-Host ""

