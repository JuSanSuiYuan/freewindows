# ReactOS 增量构建脚本
# 逐步构建 ReactOS 组件，记录进度

param(
    [Parameter(Mandatory=$false)]
    [string]$BuildDir = "build\reactos-full-amd64-clang-cl",
    
    [Parameter(Mandatory=$false)]
    [int]$Jobs = 8,
    
    [switch]$ContinueOnError
)

$ErrorActionPreference = if ($ContinueOnError) { "Continue" } else { "Stop" }

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FreeWindows ReactOS 增量构建" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date

# 定义构建阶段
$buildStages = @(
    @{
        Name = "SDK 工具"
        Targets = @("host_tools")
        Critical = $true
    },
    @{
        Name = "运行时库 (CRT)"
        Targets = @("crt", "msvcrt")
        Critical = $true
    },
    @{
        Name = "基础 DLL"
        Targets = @("ntdll", "kernel32")
        Critical = $true
    },
    @{
        Name = "用户界面 DLL"
        Targets = @("user32", "gdi32")
        Critical = $false
    },
    @{
        Name = "内核"
        Targets = @("ntoskrnl")
        Critical = $false
    }
)

$totalStages = $buildStages.Count
$currentStage = 0
$successStages = 0
$failedStages = 0

foreach ($stage in $buildStages) {
    $currentStage++
    
    Write-Host "[$currentStage/$totalStages] 构建：$($stage.Name)" -ForegroundColor Green
    Write-Host "----------------------------------------" -ForegroundColor Gray
    
    $stageStartTime = Get-Date
    $stageSuccess = $true
    
    foreach ($target in $stage.Targets) {
        Write-Host "  构建目标：$target..." -NoNewline
        
        $output = cmake --build $BuildDir --target $target --parallel $Jobs 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✓" -ForegroundColor Green
        } else {
            Write-Host " ✗" -ForegroundColor Red
            $stageSuccess = $false
            
            # 保存错误日志
            $errorLog = "$BuildDir\error-$target.log"
            $output | Out-File -FilePath $errorLog
            Write-Host "    错误日志：$errorLog" -ForegroundColor Yellow
            
            if ($stage.Critical -and -not $ContinueOnError) {
                Write-Host ""
                Write-Host "✗ 关键组件构建失败，停止构建" -ForegroundColor Red
                exit 1
            }
        }
    }
    
    $stageEndTime = Get-Date
    $stageDuration = ($stageEndTime - $stageStartTime).TotalSeconds
    
    if ($stageSuccess) {
        Write-Host "✓ $($stage.Name) 构建成功 ($([math]::Round($stageDuration, 2)) 秒)" -ForegroundColor Green
        $successStages++
    } else {
        Write-Host "⚠ $($stage.Name) 部分失败 ($([math]::Round($stageDuration, 2)) 秒)" -ForegroundColor Yellow
        $failedStages++
    }
    
    Write-Host ""
}

# 总结
$endTime = Get-Date
$totalDuration = ($endTime - $startTime).TotalSeconds

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "构建总结" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "总阶段数：$totalStages" -ForegroundColor Cyan
Write-Host "成功：$successStages" -ForegroundColor Green
Write-Host "失败：$failedStages" -ForegroundColor $(if ($failedStages -eq 0) { "Green" } else { "Red" })
Write-Host "总用时：$([math]::Round($totalDuration, 2)) 秒 ($([math]::Round($totalDuration / 60, 2)) 分钟)" -ForegroundColor Cyan
Write-Host ""

# 统计生成的文件
$exeFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue
$dllFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.dll" -ErrorAction SilentlyContinue
$sysFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.sys" -ErrorAction SilentlyContinue

Write-Host "生成的文件：" -ForegroundColor Cyan
Write-Host "  可执行文件：$($exeFiles.Count)" -ForegroundColor White
Write-Host "  动态库：$($dllFiles.Count)" -ForegroundColor White
Write-Host "  驱动程序：$($sysFiles.Count)" -ForegroundColor White
Write-Host ""

if ($failedStages -eq 0) {
    Write-Host "✓ 所有阶段构建成功！" -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠ 部分阶段构建失败" -ForegroundColor Yellow
    Write-Host "请查看错误日志以获取详细信息" -ForegroundColor Yellow
    exit 1
}

