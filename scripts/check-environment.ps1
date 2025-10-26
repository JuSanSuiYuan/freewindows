# 环境检查脚本 - 检查 LLVM/Clang 迁移所需的工具

$ErrorActionPreference = "Continue"

Write-Host "=== FreeWindows 环境检查 ===" -ForegroundColor Cyan
Write-Host ""

function Test-Command {
    param([string]$Command)
    try {
        $result = Get-Command $Command -ErrorAction Stop
        return @{
            Found = $true
            Path = $result.Source
            Version = $null
        }
    } catch {
        return @{
            Found = $false
            Path = $null
            Version = $null
        }
    }
}

function Get-ToolVersion {
    param([string]$Command)
    try {
        $output = & $Command --version 2>&1 | Select-Object -First 1
        return $output
    } catch {
        return "无法获取版本"
    }
}

# 检查必需工具
Write-Host "1. LLVM/Clang 工具链" -ForegroundColor Yellow
Write-Host ""

$LLVMTools = @(
    @{Name="clang"; Required=$true; Description="Clang C 编译器"},
    @{Name="clang++"; Required=$true; Description="Clang C++ 编译器"},
    @{Name="clang-cl"; Required=$true; Description="Clang MSVC 兼容编译器"},
    @{Name="lld-link"; Required=$true; Description="LLD MSVC 兼容链接器"},
    @{Name="ld.lld"; Required=$true; Description="LLD GNU 兼容链接器"},
    @{Name="llvm-ar"; Required=$true; Description="LLVM 归档工具"},
    @{Name="llvm-lib"; Required=$true; Description="LLVM 库工具"},
    @{Name="llvm-rc"; Required=$true; Description="LLVM 资源编译器"},
    @{Name="llvm-mt"; Required=$false; Description="LLVM 清单工具"},
    @{Name="clang-tidy"; Required=$false; Description="Clang 静态分析"},
    @{Name="clang-format"; Required=$false; Description="Clang 代码格式化"}
)

$AllFound = $true
foreach ($Tool in $LLVMTools) {
    $result = Test-Command $Tool.Name
    if ($result.Found) {
        $version = Get-ToolVersion $Tool.Name
        Write-Host "  ✓ $($Tool.Name)" -ForegroundColor Green -NoNewline
        Write-Host " - $($Tool.Description)" -ForegroundColor Gray
        Write-Host "    路径: $($result.Path)" -ForegroundColor DarkGray
        Write-Host "    版本: $version" -ForegroundColor DarkGray
    } else {
        if ($Tool.Required) {
            Write-Host "  ✗ $($Tool.Name)" -ForegroundColor Red -NoNewline
            Write-Host " - $($Tool.Description) [必需]" -ForegroundColor Gray
            $AllFound = $false
        } else {
            Write-Host "  ⚠ $($Tool.Name)" -ForegroundColor Yellow -NoNewline
            Write-Host " - $($Tool.Description) [可选]" -ForegroundColor Gray
        }
    }
}

Write-Host ""

# 检查构建工具
Write-Host "2. 构建工具" -ForegroundColor Yellow
Write-Host ""

$BuildTools = @(
    @{Name="cmake"; Required=$true; Description="CMake 构建系统"},
    @{Name="ninja"; Required=$false; Description="Ninja 构建工具"},
    @{Name="git"; Required=$true; Description="Git 版本控制"}
)

foreach ($Tool in $BuildTools) {
    $result = Test-Command $Tool.Name
    if ($result.Found) {
        $version = Get-ToolVersion $Tool.Name
        Write-Host "  ✓ $($Tool.Name)" -ForegroundColor Green -NoNewline
        Write-Host " - $($Tool.Description)" -ForegroundColor Gray
        Write-Host "    路径: $($result.Path)" -ForegroundColor DarkGray
        Write-Host "    版本: $version" -ForegroundColor DarkGray
    } else {
        if ($Tool.Required) {
            Write-Host "  ✗ $($Tool.Name)" -ForegroundColor Red -NoNewline
            Write-Host " - $($Tool.Description) [必需]" -ForegroundColor Gray
            $AllFound = $false
        } else {
            Write-Host "  ⚠ $($Tool.Name)" -ForegroundColor Yellow -NoNewline
            Write-Host " - $($Tool.Description) [可选]" -ForegroundColor Gray
        }
    }
}

Write-Host ""

# 检查 ReactOS 源代码
Write-Host "3. ReactOS 源代码" -ForegroundColor Yellow
Write-Host ""

$ReactOSPath = "..\reactos"
$ReactOSFullPath = Join-Path $PSScriptRoot "..\$ReactOSPath"

if (Test-Path $ReactOSFullPath) {
    Write-Host "  ✓ ReactOS 源代码目录存在" -ForegroundColor Green
    Write-Host "    路径: $ReactOSFullPath" -ForegroundColor DarkGray
    
    $CMakeFile = Join-Path $ReactOSFullPath "CMakeLists.txt"
    if (Test-Path $CMakeFile) {
        Write-Host "  ✓ CMakeLists.txt 存在" -ForegroundColor Green
    } else {
        Write-Host "  ✗ CMakeLists.txt 不存在" -ForegroundColor Red
        $AllFound = $false
    }
} else {
    Write-Host "  ✗ ReactOS 源代码目录不存在" -ForegroundColor Red
    Write-Host "    预期路径: $ReactOSFullPath" -ForegroundColor DarkGray
    $AllFound = $false
}

Write-Host ""

# 总结
Write-Host "=== 检查结果 ===" -ForegroundColor Cyan
Write-Host ""

if ($AllFound) {
    Write-Host "✓ 所有必需工具已安装！" -ForegroundColor Green
    Write-Host ""
    Write-Host "下一步：" -ForegroundColor Yellow
    Write-Host "  配置 ReactOS 构建：" -ForegroundColor White
    Write-Host "    .\scripts\configure-reactos.ps1 -Arch amd64 -Toolchain clang-cl" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "✗ 缺少必需的工具或文件" -ForegroundColor Red
    Write-Host ""
    Write-Host "请安装缺少的工具：" -ForegroundColor Yellow
    Write-Host "  LLVM: https://github.com/llvm/llvm-project/releases" -ForegroundColor White
    Write-Host "  CMake: https://cmake.org/download/" -ForegroundColor White
    Write-Host "  Git: https://git-scm.com/download/win" -ForegroundColor White
    Write-Host ""
}
