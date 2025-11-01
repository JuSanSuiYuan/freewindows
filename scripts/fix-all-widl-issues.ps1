# 全面修复 widl 工具的 Clang 兼容性问题
param(
    [Parameter(Mandatory=$false)]
    [string]$ReactOSPath = "..\reactos"
)

$ErrorActionPreference = "Stop"
$ReactOSFullPath = Resolve-Path $ReactOSPath

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          全面修复 widl 工具 Clang 兼容性问题            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# 1. 修复所有格式字符串问题
Write-Host "[1/2] 修复格式字符串类型不匹配..." -ForegroundColor Yellow

$widlPath = Join-Path $ReactOSFullPath "sdk\tools\widl"
$cFiles = Get-ChildItem -Path $widlPath -Filter "*.c" -Recurse

$fixedFiles = @()
foreach ($file in $cFiles) {
    $content = Get-Content $file.FullName -Raw
    $original = $content
    
    # 修复所有 UUID 格式字符串
    $content = $content -replace '0x%08x', '0x%08lx'
    $content = $content -replace '0x%08X', '0x%08lX'
    $content = $content -replace '"%08x-', '"%08lx-'
    $content = $content -replace '"%08X-', '"%08lX-'
    $content = $content -replace '"\{%08x-', '"{%08lx-'
    $content = $content -replace '"\{%08X-', '"{%08lX-'
    
    if ($content -ne $original) {
        Set-Content $file.FullName -Value $content -NoNewline
        $fixedFiles += $file.Name
    }
}

if ($fixedFiles.Count -gt 0) {
    Write-Host "  ✓ 已修复 $($fixedFiles.Count) 个文件:" -ForegroundColor Green
    foreach ($name in $fixedFiles) {
        Write-Host "    - $name" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠ 没有需要修复的格式字符串" -ForegroundColor Yellow
}

# 2. 修复所有 pragma pack 问题
Write-Host "`n[2/2] 修复 pragma pack 警告..." -ForegroundColor Yellow

$pragmaFiles = @(
    "sdk\tools\widl\typelib_struct.h",
    "sdk\tools\widl\write_sltg.c"
)

$fixedPragma = @()
foreach ($relPath in $pragmaFiles) {
    $file = Join-Path $ReactOSFullPath $relPath
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # 检查是否已经有 clang diagnostic
        if ($content -notmatch '#pragma clang diagnostic') {
            # 在文件开头添加
            $header = @"
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpragma-pack"
#endif

"@
            # 在文件末尾添加
            $footer = @"

#ifdef __clang__
#pragma clang diagnostic pop
#endif
"@
            
            $content = $header + $content + $footer
            Set-Content $file -Value $content -NoNewline
            $fixedPragma += (Split-Path $relPath -Leaf)
        }
    }
}

if ($fixedPragma.Count -gt 0) {
    Write-Host "  ✓ 已修复 $($fixedPragma.Count) 个文件:" -ForegroundColor Green
    foreach ($name in $fixedPragma) {
        Write-Host "    - $name" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠ 没有需要修复的 pragma pack" -ForegroundColor Yellow
}

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                      修复完成！                          ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor Green

Write-Host "修复摘要:" -ForegroundColor Cyan
Write-Host "  - 格式字符串: $($fixedFiles.Count) 个文件" -ForegroundColor White
Write-Host "  - Pragma pack: $($fixedPragma.Count) 个文件" -ForegroundColor White
Write-Host ""
