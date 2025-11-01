# 完整 ReactOS 系统构建脚本
# 编译整个 ReactOS 操作系统

param(
    [Parameter(Mandatory=$false)]
    [string]$BuildDir = "build\reactos-amd64-clang-cl",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Debug", "Release", "RelWithDebInfo")]
    [string]$BuildType = "Debug",
    
    [Parameter(Mandatory=$false)]
    [int]$Jobs = 8,
    
    [switch]$CleanFirst,
    [switch]$ContinueOnError
)

$ErrorActionPreference = if ($ContinueOnError) { "Continue" } else { "Stop" }

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FreeWindows 完整系统构建" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 记录开始时间
$startTime = Get-Date

# 检查构建目录
if (-not (Test-Path $BuildDir)) {
    Write-Host "错误：构建目录不存在: $BuildDir" -ForegroundColor Red
    Write-Host "请先运行配置脚本" -ForegroundColor Yellow
    exit 1
}

# 清理构建（如果需要）
if ($CleanFirst) {
    Write-Host "清理构建目录..." -ForegroundColor Yellow
    cmake --build $BuildDir --target clean
    Write-Host ""
}

# 显示构建信息
Write-Host "构建配置：" -ForegroundColor Cyan
Write-Host "  构建目录: $BuildDir" -ForegroundColor White
Write-Host "  构建类型: $BuildType" -ForegroundColor White
Write-Host "  并行任务: $Jobs" -ForegroundColor White
Write-Host ""

# 阶段 1：编译 SDK 工具
Write-Host "[阶段 1/5] 编译 SDK 工具" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$sdkStartTime = Get-Date

Write-Host "正在编译 SDK 工具..." -ForegroundColor Cyan
cmake --build $BuildDir --target host_tools --parallel $Jobs 2>&1 | Tee-Object -FilePath "$BuildDir\sdk-build.log"

if ($LASTEXITCODE -eq 0) {
    $sdkEndTime = Get-Date
    $sdkDuration = ($sdkEndTime - $sdkStartTime).TotalSeconds
    Write-Host "✓ SDK 工具编译完成 ($([math]::Round($sdkDuration, 2)) 秒)" -ForegroundColor Green
} else {
    Write-Host "✗ SDK 工具编译失败" -ForegroundColor Red
    if (-not $ContinueOnError) {
        exit 1
    }
}

Write-Host ""

# 阶段 2：编译运行时库
Write-Host "[阶段 2/5] 编译运行时库" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$runtimeStartTime = Get-Date

Write-Host "正在编译运行时库..." -ForegroundColor Cyan

# 尝试编译常见的运行时库目标
$runtimeTargets = @(
    "ntdll",
    "kernel32",
    "msvcrt",
    "user32",
    "gdi32"
)

$runtimeSuccess = 0
$runtimeFail = 0

foreach ($target in $runtimeTargets) {
    Write-Host "  编译 $target..." -NoNewline
    
    cmake --build $BuildDir --target $target --parallel $Jobs 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✓" -ForegroundColor Green
        $runtimeSuccess++
    } else {
        Write-Host " ✗" -ForegroundColor Red
        $runtimeFail++
    }
}

$runtimeEndTime = Get-Date
$runtimeDuration = ($runtimeEndTime - $runtimeStartTime).TotalSeconds

Write-Host ""
Write-Host "运行时库编译结果: $runtimeSuccess 成功, $runtimeFail 失败 ($([math]::Round($runtimeDuration, 2)) 秒)" -ForegroundColor $(if ($runtimeFail -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

# 阶段 3：编译内核
Write-Host "[阶段 3/5] 编译内核" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$kernelStartTime = Get-Date

Write-Host "正在编译内核..." -ForegroundColor Cyan

cmake --build $BuildDir --target ntoskrnl --parallel $Jobs 2>&1 | Tee-Object -FilePath "$BuildDir\kernel-build.log"

if ($LASTEXITCODE -eq 0) {
    $kernelEndTime = Get-Date
    $kernelDuration = ($kernelEndTime - $kernelStartTime).TotalSeconds
    Write-Host "✓ 内核编译完成 ($([math]::Round($kernelDuration, 2)) 秒)" -ForegroundColor Green
} else {
    Write-Host "✗ 内核编译失败" -ForegroundColor Red
    Write-Host "这是预期的 - 内核编译可能需要额外的修复" -ForegroundColor Yellow
    if (-not $ContinueOnError) {
        Write-Host ""
        Write-Host "提示：使用 -ContinueOnError 继续构建其他组件" -ForegroundColor Cyan
    }
}

Write-Host ""

# 阶段 4：编译驱动程序
Write-Host "[阶段 4/5] 编译驱动程序" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$driverStartTime = Get-Date

Write-Host "正在编译驱动程序..." -ForegroundColor Cyan

# 尝试编译一些基础驱动
$driverTargets = @(
    "beep",
    "null",
    "serial"
)

$driverSuccess = 0
$driverFail = 0

foreach ($target in $driverTargets) {
    Write-Host "  编译 $target..." -NoNewline
    
    cmake --build $BuildDir --target $target --parallel $Jobs 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✓" -ForegroundColor Green
        $driverSuccess++
    } else {
        Write-Host " ✗" -ForegroundColor Red
        $driverFail++
    }
}

$driverEndTime = Get-Date
$driverDuration = ($driverEndTime - $driverStartTime).TotalSeconds

Write-Host ""
Write-Host "驱动程序编译结果: $driverSuccess 成功, $driverFail 失败 ($([math]::Round($driverDuration, 2)) 秒)" -ForegroundColor $(if ($driverFail -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

# 阶段 5：尝试完整构建
Write-Host "[阶段 5/5] 尝试完整构建" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$fullStartTime = Get-Date

Write-Host "正在执行完整构建..." -ForegroundColor Cyan
Write-Host "（这可能需要 30-60 分钟）" -ForegroundColor Yellow
Write-Host ""

cmake --build $BuildDir --parallel $Jobs 2>&1 | Tee-Object -FilePath "$BuildDir\full-build.log"

$fullExitCode = $LASTEXITCODE

$fullEndTime = Get-Date
$fullDuration = ($fullEndTime - $fullStartTime).TotalSeconds

if ($fullExitCode -eq 0) {
    Write-Host "✓ 完整构建成功！" -ForegroundColor Green
} else {
    Write-Host "⚠ 完整构建部分失败" -ForegroundColor Yellow
    Write-Host "请查看日志文件: $BuildDir\full-build.log" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "完整构建用时: $([math]::Round($fullDuration, 2)) 秒 ($([math]::Round($fullDuration / 60, 2)) 分钟)" -ForegroundColor Cyan
Write-Host ""

# 总结
$endTime = Get-Date
$totalDuration = ($endTime - $startTime).TotalSeconds

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "构建总结" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "总用时: $([math]::Round($totalDuration, 2)) 秒 ($([math]::Round($totalDuration / 60, 2)) 分钟)" -ForegroundColor Cyan
Write-Host ""

# 统计生成的文件
Write-Host "生成的文件统计：" -ForegroundColor Cyan

$exeFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue
$dllFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.dll" -ErrorAction SilentlyContinue
$sysFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.sys" -ErrorAction SilentlyContinue
$libFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.lib" -ErrorAction SilentlyContinue

Write-Host "  可执行文件 (.exe): $($exeFiles.Count)" -ForegroundColor White
Write-Host "  动态库 (.dll): $($dllFiles.Count)" -ForegroundColor White
Write-Host "  驱动程序 (.sys): $($sysFiles.Count)" -ForegroundColor White
Write-Host "  静态库 (.lib): $($libFiles.Count)" -ForegroundColor White
Write-Host ""

# 检查构建日志中的错误
Write-Host "错误分析：" -ForegroundColor Cyan

if (Test-Path "$BuildDir\full-build.log") {
    $logContent = Get-Content "$BuildDir\full-build.log" -Raw
    
    $errorCount = ([regex]::Matches($logContent, "error:")).Count
    $warningCount = ([regex]::Matches($logContent, "warning:")).Count
    
    Write-Host "  错误数: $errorCount" -ForegroundColor $(if ($errorCount -eq 0) { "Green" } else { "Red" })
    Write-Host "  警告数: $warningCount" -ForegroundColor $(if ($warningCount -eq 0) { "Green" } else { "Yellow" })
}

Write-Host ""

# 下一步建议
if ($fullExitCode -eq 0) {
    Write-Host "✓ 构建成功！" -ForegroundColor Green
    Write-Host ""
    Write-Host "下一步：" -ForegroundColor Cyan
    Write-Host "  1. 生成 ISO 镜像：" -ForegroundColor White
    Write-Host "     cmake --build $BuildDir --target bootcd" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. 虚拟机测试：" -ForegroundColor White
    Write-Host "     qemu-system-x86_64 -cdrom ReactOS.iso -m 512" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "⚠ 构建部分失败" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "建议：" -ForegroundColor Cyan
    Write-Host "  1. 查看构建日志：" -ForegroundColor White
    Write-Host "     Get-Content $BuildDir\full-build.log | Select-String 'error:'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. 分析错误类型并创建修复补丁" -ForegroundColor White
    Write-Host ""
    Write-Host "  3. 继续构建其他组件：" -ForegroundColor White
    Write-Host "     .\scripts\build-full-system.ps1 -ContinueOnError" -ForegroundColor Gray
    Write-Host ""
}

exit $fullExitCode

