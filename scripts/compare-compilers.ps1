# 编译器性能对比脚本
# 对比 Clang vs MSVC (如果可用)

param(
    [Parameter(Mandatory=$false)]
    [string]$SourceDir = "src\reactos-full",
    
    [Parameter(Mandatory=$false)]
    [int]$Jobs = 8
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FreeWindows 编译器性能对比" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查可用的编译器
$compilers = @()

# 检查 Clang
$clang = Get-Command clang-cl -ErrorAction SilentlyContinue
if ($clang) {
    $compilers += @{
        Name = "Clang"
        CCompiler = "clang-cl"
        CXXCompiler = "clang-cl"
        Linker = "lld-link"
        Available = $true
    }
}

# 检查 MSVC
$msvc = Get-Command cl -ErrorAction SilentlyContinue
if ($msvc) {
    $compilers += @{
        Name = "MSVC"
        CCompiler = "cl"
        CXXCompiler = "cl"
        Linker = "link"
        Available = $true
    }
}

if ($compilers.Count -eq 0) {
    Write-Host "错误：没有找到可用的编译器" -ForegroundColor Red
    exit 1
}

Write-Host "找到 $($compilers.Count) 个编译器：" -ForegroundColor Cyan
foreach ($compiler in $compilers) {
    Write-Host "  ✓ $($compiler.Name)" -ForegroundColor Green
}
Write-Host ""

$results = @()

foreach ($compiler in $compilers) {
    Write-Host "测试编译器: $($compiler.Name)" -ForegroundColor Green
    Write-Host "----------------------------------------" -ForegroundColor Gray
    
    $buildDir = "build\reactos-compare-$($compiler.Name.ToLower())"
    
    # 清理
    if (Test-Path $buildDir) {
        Remove-Item -Path $buildDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # 配置
    Write-Host "  配置..." -NoNewline
    
    $configCmd = "cmake -S $SourceDir -B $buildDir -G Ninja " +
                 "-DARCH=amd64 -DCMAKE_BUILD_TYPE=Release " +
                 "-DCMAKE_C_COMPILER=$($compiler.CCompiler) " +
                 "-DCMAKE_CXX_COMPILER=$($compiler.CXXCompiler)"
    
    Invoke-Expression $configCmd 2>&1 | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host " ✗" -ForegroundColor Red
        continue
    }
    
    Write-Host " ✓" -ForegroundColor Green
    
    # 构建
    Write-Host "  构建..." -NoNewline
    
    $startTime = Get-Date
    cmake --build $buildDir --parallel $Jobs 2>&1 | Out-Null
    $endTime = Get-Date
    
    if ($LASTEXITCODE -eq 0) {
        $duration = ($endTime - $startTime).TotalSeconds
        Write-Host " ✓ $([math]::Round($duration, 2))s" -ForegroundColor Green
        
        # 统计
        $exeFiles = Get-ChildItem -Path $buildDir -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue
        $totalSize = ($exeFiles | Measure-Object -Property Length -Sum).Sum
        
        $results += @{
            Compiler = $compiler.Name
            BuildTime = $duration
            BinarySize = $totalSize
            FileCount = $exeFiles.Count
            Success = $true
        }
        
        Write-Host "    文件数: $($exeFiles.Count)" -ForegroundColor Cyan
        Write-Host "    总大小: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor Cyan
    } else {
        Write-Host " ✗" -ForegroundColor Red
        $results += @{
            Compiler = $compiler.Name
            Success = $false
        }
    }
    
    Write-Host ""
}

# 生成对比报告
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "编译器对比报告" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$successResults = $results | Where-Object { $_.Success }

if ($successResults.Count -eq 0) {
    Write-Host "没有成功的构建结果" -ForegroundColor Red
    exit 1
}

# 找到最快的编译器
$fastest = $successResults | Sort-Object BuildTime | Select-Object -First 1

Write-Host "构建时间对比：" -ForegroundColor Yellow
foreach ($result in $successResults) {
    $speedup = $fastest.BuildTime / $result.BuildTime
    $indicator = if ($result.Compiler -eq $fastest.Compiler) { "🏆" } else { "  " }
    
    Write-Host "  $indicator $($result.Compiler): $([math]::Round($result.BuildTime, 2))s (${speedup}x)" -ForegroundColor $(if ($result.Compiler -eq $fastest.Compiler) { "Green" } else { "White" })
}

Write-Host ""

# 找到最小的二进制
$smallest = $successResults | Sort-Object BinarySize | Select-Object -First 1

Write-Host "二进制大小对比：" -ForegroundColor Yellow
foreach ($result in $successResults) {
    $ratio = $result.BinarySize / $smallest.BinarySize
    $indicator = if ($result.Compiler -eq $smallest.Compiler) { "🏆" } else { "  " }
    
    Write-Host "  $indicator $($result.Compiler): $([math]::Round($result.BinarySize / 1MB, 2)) MB (${ratio}x)" -ForegroundColor $(if ($result.Compiler -eq $smallest.Compiler) { "Green" } else { "White" })
}

Write-Host ""

# 保存结果
$reportPath = "compiler-comparison.json"
$results | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath
Write-Host "详细结果已保存到: $reportPath" -ForegroundColor Cyan

