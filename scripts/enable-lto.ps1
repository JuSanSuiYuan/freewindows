# 启用链接时优化 (LTO) 脚本
# 配置并构建启用 LTO 的 ReactOS

param(
    [Parameter(Mandatory=$false)]
    [string]$SourceDir = "src\reactos-full",
    
    [Parameter(Mandatory=$false)]
    [string]$BuildDir = "build\reactos-lto-amd64-clang-cl",
    
    [Parameter(Mandatory=$false)]
    [int]$Jobs = 8
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FreeWindows LTO 构建配置" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 清理旧构建
if (Test-Path $BuildDir) {
    Write-Host "清理旧构建目录..." -ForegroundColor Yellow
    Remove-Item -Path $BuildDir -Recurse -Force
}

# 创建构建目录
New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null

Write-Host "[1/3] 配置 LTO 构建..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

# CMake 配置
$configCmd = @"
cmake -S $SourceDir -B $BuildDir -G Ninja `
    -DARCH=amd64 `
    -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_C_COMPILER=clang-cl `
    -DCMAKE_CXX_COMPILER=clang-cl `
    -DCMAKE_LINKER=lld-link `
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON `
    -DCMAKE_C_FLAGS_RELEASE="/O2 /Ob2 /DNDEBUG /GL" `
    -DCMAKE_CXX_FLAGS_RELEASE="/O2 /Ob2 /DNDEBUG /GL" `
    -DCMAKE_EXE_LINKER_FLAGS="/LTCG /OPT:REF /OPT:ICF" `
    -DCMAKE_SHARED_LINKER_FLAGS="/LTCG /OPT:REF /OPT:ICF"
"@

Write-Host "执行配置命令..." -ForegroundColor Cyan
Invoke-Expression $configCmd

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ 配置失败" -ForegroundColor Red
    exit 1
}

Write-Host "✓ 配置成功" -ForegroundColor Green
Write-Host ""

Write-Host "[2/3] 构建 (启用 LTO)..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host "这可能需要更长时间，因为 LTO 需要额外的优化..." -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date

cmake --build $BuildDir --parallel $Jobs 2>&1 | Tee-Object -FilePath "$BuildDir\lto-build.log"

$endTime = Get-Date
$duration = ($endTime - $startTime).TotalSeconds

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 构建成功" -ForegroundColor Green
    Write-Host "  构建时间: $([math]::Round($duration, 2)) 秒" -ForegroundColor Cyan
} else {
    Write-Host "✗ 构建失败" -ForegroundColor Red
    Write-Host "  请查看日志: $BuildDir\lto-build.log" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

Write-Host "[3/3] 分析结果..." -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

# 统计文件
$exeFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue
$dllFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.dll" -ErrorAction SilentlyContinue

$exeSize = ($exeFiles | Measure-Object -Property Length -Sum).Sum
$dllSize = ($dllFiles | Measure-Object -Property Length -Sum).Sum
$totalSize = $exeSize + $dllSize

Write-Host "生成的文件：" -ForegroundColor Cyan
Write-Host "  可执行文件: $($exeFiles.Count) ($([math]::Round($exeSize / 1MB, 2)) MB)" -ForegroundColor White
Write-Host "  动态库: $($dllFiles.Count) ($([math]::Round($dllSize / 1MB, 2)) MB)" -ForegroundColor White
Write-Host "  总大小: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor White
Write-Host ""

# 对比非 LTO 构建
$normalBuildDir = "build\reactos-full-amd64-clang-cl"
if (Test-Path $normalBuildDir) {
    $normalExeFiles = Get-ChildItem -Path $normalBuildDir -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue
    $normalSize = ($normalExeFiles | Measure-Object -Property Length -Sum).Sum
    
    if ($normalSize -gt 0) {
        $reduction = (1 - ($totalSize / $normalSize)) * 100
        Write-Host "与非 LTO 构建对比：" -ForegroundColor Yellow
        Write-Host "  大小减少: $([math]::Round($reduction, 2))%" -ForegroundColor $(if ($reduction -gt 0) { "Green" } else { "Red" })
        Write-Host ""
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "LTO 构建完成" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "LTO 优势：" -ForegroundColor Yellow
Write-Host "  ✓ 更小的二进制文件" -ForegroundColor Green
Write-Host "  ✓ 更好的运行时性能" -ForegroundColor Green
Write-Host "  ✓ 更激进的内联优化" -ForegroundColor Green
Write-Host ""

Write-Host "LTO 代价：" -ForegroundColor Yellow
Write-Host "  ⚠ 更长的编译时间" -ForegroundColor Yellow
Write-Host "  ⚠ 更高的内存使用" -ForegroundColor Yellow
Write-Host ""

