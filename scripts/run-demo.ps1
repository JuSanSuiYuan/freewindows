# 运行 Material 3 演示
# 简单的运行脚本

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "运行 Material 3 演示" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 查找可执行文件
$exeFiles = Get-ChildItem -Path "demos\Material3Demo\build" -Recurse -Filter "*.exe" -ErrorAction SilentlyContinue

if ($exeFiles.Count -eq 0) {
    Write-Host "未找到可执行文件" -ForegroundColor Red
    Write-Host ""
    Write-Host "请先构建项目：" -ForegroundColor Yellow
    Write-Host "  方法 1：使用 Qt Creator 打开并构建" -ForegroundColor White
    Write-Host "  方法 2：运行 .\scripts\build-material3-demo.ps1" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "找到 $($exeFiles.Count) 个可执行文件：" -ForegroundColor Cyan
foreach ($exe in $exeFiles) {
    Write-Host "  - $($exe.Name)" -ForegroundColor White
}

Write-Host ""

# 运行第一个
$mainExe = $exeFiles | Where-Object { $_.Name -like "Material3Demo*" } | Select-Object -First 1

if (-not $mainExe) {
    $mainExe = $exeFiles[0]
}

Write-Host "启动: $($mainExe.Name)" -ForegroundColor Green
Write-Host "路径: $($mainExe.FullName)" -ForegroundColor Gray
Write-Host ""

# 设置 Qt 环境
$env:PATH = "D:\QT\6.9.3\mingw_64\bin;$env:PATH"

try {
    Start-Process $mainExe.FullName
    Write-Host "✓ 程序已启动" -ForegroundColor Green
    Write-Host ""
    Write-Host "如果窗口没有显示，请检查：" -ForegroundColor Yellow
    Write-Host "  1. 是否有错误消息" -ForegroundColor White
    Write-Host "  2. 任务栏是否有程序图标" -ForegroundColor White
    Write-Host "  3. 是否被杀毒软件拦截" -ForegroundColor White
} catch {
    Write-Host "✗ 启动失败" -ForegroundColor Red
    Write-Host "错误: $_" -ForegroundColor Red
}

