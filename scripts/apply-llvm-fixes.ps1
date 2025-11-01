# 应用 LLVM 兼容性修复
# 这个脚本会直接修改 ReactOS 源代码以修复 Clang 编译错误

param(
    [Parameter(Mandatory=$false)]
    [string]$ReactOSPath = "..\reactos"
)

$ErrorActionPreference = "Stop"

Write-Host "=== 应用 LLVM 兼容性修复 ===" -ForegroundColor Cyan
Write-Host ""

$ReactOSFullPath = Resolve-Path $ReactOSPath

# 修复 1: widl 目录下所有格式字符串类型不匹配
Write-Host "[1/2] 修复 widl 目录格式字符串..." -ForegroundColor Yellow

$widlFiles = @(
    "sdk\tools\widl\register.c",
    "sdk\tools\widl\header.c",
    "sdk\tools\widl\write_msft.c"
)

$fixedCount = 0
foreach ($relPath in $widlFiles) {
    $file = Join-Path $ReactOSFullPath $relPath
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        $original = $content
        
        # 修复所有 UUID 格式字符串：%08x/%08X -> %08lx/%08lX
        $content = $content -replace '"%08x-', '"%08lx-'
        $content = $content -replace '"%08X-', '"%08lX-'
        $content = $content -replace '"\{%08x-', '"{%08lx-'
        $content = $content -replace '"\{%08X-', '"{%08lX-'
        
        if ($content -ne $original) {
            Set-Content $file -Value $content -NoNewline
            Write-Host "  ✓ 已修复 $(Split-Path $relPath -Leaf)" -ForegroundColor Green
            $fixedCount++
        }
    }
}

if ($fixedCount -eq 0) {
    Write-Host "  ⚠ 所有文件可能已经修复" -ForegroundColor Yellow
}

# 修复 2: widl/typelib_struct.h - pragma pack 问题
Write-Host "[2/2] 修复 widl/typelib_struct.h pragma pack..." -ForegroundColor Yellow

$typelibFile = Join-Path $ReactOSFullPath "sdk\tools\widl\typelib_struct.h"
if (Test-Path $typelibFile) {
    $content = Get-Content $typelibFile -Raw
    
    # 在文件开头添加 pragma 警告抑制
    if ($content -notmatch '#pragma clang diagnostic') {
        $header = @"
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpragma-pack"
#endif

"@
        $footer = @"

#ifdef __clang__
#pragma clang diagnostic pop
#endif
"@
        
        $content = $header + $content + $footer
        Set-Content $typelibFile -Value $content -NoNewline
        Write-Host "  ✓ 已修复 typelib_struct.h" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ typelib_struct.h 可能已经修复" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✗ 找不到 typelib_struct.h" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== 修复完成 ===" -ForegroundColor Green
Write-Host ""
Write-Host "下一步：重新构建" -ForegroundColor Cyan
Write-Host "  ninja -C build\reactos-amd64-clang-cl" -ForegroundColor Gray
Write-Host ""
