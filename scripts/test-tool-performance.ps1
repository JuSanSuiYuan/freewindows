# 工具性能测试脚本
# 测试已编译工具的运行性能

param(
    [Parameter(Mandatory=$false)]
    [string]$BuildDir = "build\reactos-full-amd64-clang-cl",
    
    [Parameter(Mandatory=$false)]
    [int]$Iterations = 10
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FreeWindows 工具性能测试" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 查找可执行文件
$exeFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -notlike "*CMake*" }

if ($exeFiles.Count -eq 0) {
    Write-Host "错误：没有找到可执行文件" -ForegroundColor Red
    exit 1
}

Write-Host "找到 $($exeFiles.Count) 个工具" -ForegroundColor Cyan
Write-Host ""

# 测试简单的工具
$testTools = @(
    @{
        Name = "bin2c"
        Args = @()
        ExpectError = $true  # 没有参数会显示帮助
    },
    @{
        Name = "spec2def"
        Args = @()
        ExpectError = $true
    },
    @{
        Name = "widl"
        Args = @("--help")
        ExpectError = $false
    }
)

$results = @()

foreach ($test in $testTools) {
    $tool = $exeFiles | Where-Object { $_.Name -like "$($test.Name)*" } | Select-Object -First 1
    
    if (-not $tool) {
        Write-Host "跳过 $($test.Name) (未找到)" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "测试 $($test.Name)..." -ForegroundColor Green
    Write-Host "  路径: $($tool.FullName)" -ForegroundColor Gray
    Write-Host "  大小: $([math]::Round($tool.Length / 1KB, 2)) KB" -ForegroundColor Gray
    
    $times = @()
    $successCount = 0
    
    for ($i = 1; $i -le $Iterations; $i++) {
        $startTime = Get-Date
        
        try {
            $output = & $tool.FullName $test.Args 2>&1
            $exitCode = $LASTEXITCODE
        } catch {
            $exitCode = 1
        }
        
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalMilliseconds
        
        $times += $duration
        
        if (($test.ExpectError -and $exitCode -ne 0) -or (-not $test.ExpectError -and $exitCode -eq 0)) {
            $successCount++
        }
    }
    
    $avgTime = ($times | Measure-Object -Average).Average
    $minTime = ($times | Measure-Object -Minimum).Minimum
    $maxTime = ($times | Measure-Object -Maximum).Maximum
    
    Write-Host "  平均时间: $([math]::Round($avgTime, 2)) ms" -ForegroundColor Cyan
    Write-Host "  最小时间: $([math]::Round($minTime, 2)) ms" -ForegroundColor Cyan
    Write-Host "  最大时间: $([math]::Round($maxTime, 2)) ms" -ForegroundColor Cyan
    Write-Host "  成功率: $successCount/$Iterations" -ForegroundColor $(if ($successCount -eq $Iterations) { "Green" } else { "Yellow" })
    Write-Host ""
    
    $results += @{
        Tool = $test.Name
        Size = $tool.Length
        AverageTime = $avgTime
        MinTime = $minTime
        MaxTime = $maxTime
        SuccessRate = $successCount / $Iterations
    }
}

# 生成报告
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "性能测试总结" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "测试配置：" -ForegroundColor Yellow
Write-Host "  迭代次数: $Iterations" -ForegroundColor White
Write-Host "  编译器: Clang 20.1.8" -ForegroundColor White
Write-Host "  优化级别: Debug" -ForegroundColor White
Write-Host ""

Write-Host "工具性能排名（按平均时间）：" -ForegroundColor Yellow
$sortedResults = $results | Sort-Object AverageTime

$rank = 1
foreach ($result in $sortedResults) {
    Write-Host "  $rank. $($result.Tool): $([math]::Round($result.AverageTime, 2)) ms" -ForegroundColor Cyan
    $rank++
}

Write-Host ""

# 保存结果
$reportPath = "tool-performance.json"
$results | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath
Write-Host "详细结果已保存到: $reportPath" -ForegroundColor Cyan

