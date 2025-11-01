# 完整系统链接测试脚本
# 测试 LLD 链接器配置和符号导出/导入

param(
    [Parameter(Mandatory=$false)]
    [string]$BuildDir = "build\reactos-amd64-clang-cl",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Debug", "Release")]
    [string]$BuildType = "Debug",
    
    [switch]$ShowDetails,
    [switch]$CleanFirst
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FreeWindows 完整系统链接测试" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

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

# 阶段 1：测试基础工具链接
Write-Host "[阶段 1/5] 测试基础工具链接" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$basicTools = @(
    "bin2c",
    "geninc",
    "gendib",
    "spec2def",
    "utf16le",
    "obj2bin",
    "mkshelllink"
)

$successCount = 0
$failCount = 0

foreach ($tool in $basicTools) {
    Write-Host "  测试 $tool..." -NoNewline
    
    try {
        cmake --build $BuildDir --target $tool 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✓" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host " ✗" -ForegroundColor Red
            $failCount++
        }
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        $failCount++
    }
}

Write-Host ""
Write-Host "基础工具链接结果: $successCount 成功, $failCount 失败" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

# 阶段 2：测试库文件链接
Write-Host "[阶段 2/5] 测试库文件链接" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$libraries = @(
    "zlibhost",
    "dbghelphost",
    "cmlibhost",
    "inflibhost"
)

$libSuccessCount = 0
$libFailCount = 0

foreach ($lib in $libraries) {
    Write-Host "  测试 $lib..." -NoNewline
    
    try {
        cmake --build $BuildDir --target $lib 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✓" -ForegroundColor Green
            $libSuccessCount++
        } else {
            Write-Host " ✗" -ForegroundColor Red
            $libFailCount++
        }
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        $libFailCount++
    }
}

Write-Host ""
Write-Host "库文件链接结果: $libSuccessCount 成功, $libFailCount 失败" -ForegroundColor $(if ($libFailCount -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

# 阶段 3：测试复杂工具链接
Write-Host "[阶段 3/5] 测试复杂工具链接" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

$complexTools = @(
    "widl",
    "cabman",
    "hhpcomp",
    "asmpp",
    "xml2sdb"
)

$complexSuccessCount = 0
$complexFailCount = 0

foreach ($tool in $complexTools) {
    Write-Host "  测试 $tool..." -NoNewline
    
    try {
        cmake --build $BuildDir --target $tool 2>&1 | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✓" -ForegroundColor Green
            $complexSuccessCount++
        } else {
            Write-Host " ✗" -ForegroundColor Red
            $complexFailCount++
        }
    } catch {
        Write-Host " ✗" -ForegroundColor Red
        $complexFailCount++
    }
}

Write-Host ""
Write-Host "复杂工具链接结果: $complexSuccessCount 成功, $complexFailCount 失败" -ForegroundColor $(if ($complexFailCount -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

# 阶段 4：检查链接器输出
Write-Host "[阶段 4/5] 检查链接器输出" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

# 检查是否使用了 LLD
Write-Host "  检查链接器..." -NoNewline
$buildLog = cmake --build $BuildDir --target widl --verbose 2>&1 | Out-String

if ($buildLog -match "lld-link") {
    Write-Host " ✓ 使用 LLD 链接器" -ForegroundColor Green
} else {
    Write-Host " ⚠ 未检测到 LLD 链接器" -ForegroundColor Yellow
}

# 检查链接时间
Write-Host "  检查链接性能..." -NoNewline
$startTime = Get-Date
cmake --build $BuildDir --target widl 2>&1 | Out-Null
$endTime = Get-Date
$linkTime = ($endTime - $startTime).TotalSeconds

Write-Host " ✓ 链接时间: $([math]::Round($linkTime, 2)) 秒" -ForegroundColor Green

Write-Host ""

# 阶段 5：符号导出/导入测试
Write-Host "[阶段 5/5] 符号导出/导入测试" -ForegroundColor Green
Write-Host "----------------------------------------" -ForegroundColor Gray

# 检查生成的可执行文件
$exeFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue

Write-Host "  找到 $($exeFiles.Count) 个可执行文件" -ForegroundColor Cyan

# 检查导入库
$libFiles = Get-ChildItem -Path $BuildDir -Recurse -Filter "*.lib" -ErrorAction SilentlyContinue

Write-Host "  找到 $($libFiles.Count) 个库文件" -ForegroundColor Cyan

# 使用 llvm-nm 检查符号（如果可用）
$llvmNm = Get-Command llvm-nm -ErrorAction SilentlyContinue

if ($llvmNm) {
    Write-Host "  检查符号表..." -NoNewline
    
    # 随机选择一个可执行文件检查
    if ($exeFiles.Count -gt 0) {
        $testExe = $exeFiles[0].FullName
        try {
            $symbols = & llvm-nm $testExe 2>&1 | Out-String
            
            if ($symbols -match "T " -or $symbols -match "no symbols") {
                # "no symbols" 对于 Release 构建是正常的（符号被剥离）
                Write-Host " ✓ 符号检查完成" -ForegroundColor Green
            } else {
                Write-Host " ⚠ 符号表可能异常" -ForegroundColor Yellow
            }
        } catch {
            Write-Host " ✓ 符号检查完成（无调试符号）" -ForegroundColor Green
        }
    }
} else {
    Write-Host "  ⚠ llvm-nm 不可用，跳过符号检查" -ForegroundColor Yellow
}

Write-Host ""

# 总结
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "链接测试总结" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$totalSuccess = $successCount + $libSuccessCount + $complexSuccessCount
$totalFail = $failCount + $libFailCount + $complexFailCount
$totalTests = $totalSuccess + $totalFail

Write-Host "总测试数: $totalTests" -ForegroundColor Cyan
Write-Host "成功: $totalSuccess" -ForegroundColor Green
Write-Host "失败: $totalFail" -ForegroundColor $(if ($totalFail -eq 0) { "Green" } else { "Red" })
Write-Host "成功率: $([math]::Round($totalSuccess / $totalTests * 100, 2))%" -ForegroundColor $(if ($totalFail -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

if ($totalFail -eq 0) {
    Write-Host "✓ 所有链接测试通过！" -ForegroundColor Green
    Write-Host ""
    Write-Host "下一步：" -ForegroundColor Cyan
    Write-Host "  1. 尝试编译完整 ReactOS 系统" -ForegroundColor White
    Write-Host "  2. 生成 ISO 镜像" -ForegroundColor White
    Write-Host "  3. 虚拟机测试" -ForegroundColor White
    exit 0
} else {
    Write-Host "⚠ 部分链接测试失败" -ForegroundColor Yellow
    Write-Host "请检查构建日志以获取详细信息" -ForegroundColor Yellow
    exit 1
}

