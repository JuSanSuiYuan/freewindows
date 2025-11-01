# 构建性能基准测试脚本
# 测试不同优化级别的构建性能

param(
    [Parameter(Mandatory=$false)]
    [string]$BuildDir = "build\reactos-full-amd64-clang-cl",
    
    [Parameter(Mandatory=$false)]
    [int]$Iterations = 3,
    
    [switch]$EnableLTO,
    [switch]$EnablePGO
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FreeWindows 构建性能基准测试" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 测试配置
$testConfigs = @(
    @{
        Name = "Debug (无优化)"
        BuildType = "Debug"
        ExtraFlags = ""
    },
    @{
        Name = "Release (O2)"
        BuildType = "Release"
        ExtraFlags = ""
    },
    @{
        Name = "Release (O3)"
        BuildType = "Release"
        ExtraFlags = "-DCMAKE_C_FLAGS_RELEASE='/O2 /Ob2 /DNDEBUG' -DCMAKE_CXX_FLAGS_RELEASE='/O2 /Ob2 /DNDEBUG'"
    }
)

if ($EnableLTO) {
    $testConfigs += @{
        Name = "Release + LTO"
        BuildType = "Release"
        ExtraFlags = "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON"
    }
}

$results = @()

foreach ($config in $testConfigs) {
    Write-Host "测试配置: $($config.Name)" -ForegroundColor Green
    Write-Host "----------------------------------------" -ForegroundColor Gray
    
    $configResults = @{
        Name = $config.Name
        BuildTimes = @()
        BinarySize = 0
        Success = $true
    }
    
    for ($i = 1; $i -le $Iterations; $i++) {
        Write-Host "  迭代 $i/$Iterations..." -NoNewline
        
        # 清理构建
        if (Test-Path $BuildDir) {
            Remove-Item -Path $BuildDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        # 配置
        $configCmd = "cmake -S src\reactos-full -B $BuildDir -G Ninja " +
                     "-DARCH=amd64 -DCMAKE_BUILD_TYPE=$($config.BuildType) " +
                     "-DCMAKE_C_COMPILER=clang-cl -DCMAKE_CXX_COMPILER=clang-cl " +
                     "$($config.ExtraFlags)"
        
        Invoke-Expression $configCmd 2>&1 | Out-Null
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host " ✗ 配置失败" -ForegroundColor Red
            $configResults.Success = $false
            break
        }
        
        # 构建并计时
        $startTime = Get-Date
        cmake --build $BuildDir --parallel 8 2>&1 | Out-Null
        $endTime = Get-Date
        
        if ($LASTEXITCODE -eq 0) {
            $duration = ($endTime - $startTime).TotalSeconds
            $configResults.BuildTimes += $duration
            Write-Host " ✓ $([math]::Round($duration, 2))s" -ForegroundColor Green
        } else {
            Write-Host " ✗ 构建失败" -ForegroundColor Red
            $configResults.Success = $false
            break
        }
    }
    
    # 计算平均时间
    if ($configResults.Success -and $configResults.BuildTimes.Count -gt 0) {
        $avgTime = ($configResults.BuildTimes | Measure-Object -Average).Average
        $configResults.AverageTime = $avgTime
        
        # 测量二进制大小
        $exeFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue
        $totalSize = ($exeFiles | Measure-Object -Property Length -Sum).Sum
        $configResults.BinarySize = $totalSize
        
        Write-Host "  平均时间: $([math]::Round($avgTime, 2))s" -ForegroundColor Cyan
        Write-Host "  二进制大小: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor Cyan
    }
    
    $results += $configResults
    Write-Host ""
}

# 生成报告
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "性能基准测试报告" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "测试配置：" -ForegroundColor Yellow
Write-Host "  迭代次数: $Iterations" -ForegroundColor White
Write-Host "  并行度: 8" -ForegroundColor White
Write-Host "  编译器: Clang 20.1.8" -ForegroundColor White
Write-Host ""

Write-Host "结果对比：" -ForegroundColor Yellow
Write-Host ""

$baselineTime = ($results | Where-Object { $_.Name -eq "Debug (无优化)" }).AverageTime

foreach ($result in $results) {
    if ($result.Success) {
        $speedup = if ($baselineTime -gt 0) { $baselineTime / $result.AverageTime } else { 1.0 }
        
        Write-Host "  $($result.Name):" -ForegroundColor Cyan
        Write-Host "    构建时间: $([math]::Round($result.AverageTime, 2))s" -ForegroundColor White
        Write-Host "    加速比: $([math]::Round($speedup, 2))x" -ForegroundColor $(if ($speedup -gt 1) { "Green" } else { "White" })
        Write-Host "    二进制大小: $([math]::Round($result.BinarySize / 1MB, 2)) MB" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "  $($result.Name): 失败" -ForegroundColor Red
        Write-Host ""
    }
}

# 保存结果到文件
$reportPath = "benchmark-results.json"
$results | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath
Write-Host "详细结果已保存到: $reportPath" -ForegroundColor Cyan

