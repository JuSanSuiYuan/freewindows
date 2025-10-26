# ReactOS 文件分类复制脚本
# 将 ReactOS 源代码按类别组织到 freeWindows 目录

param(
    [string]$ReactOsPath = "d:\编程项目\reactos",
    [string]$TargetPath = "d:\编程项目\freeWindows",
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ReactOS 文件分类复制工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "[模拟模式] 不会实际复制文件" -ForegroundColor Yellow
    Write-Host ""
}

# 定义目录映射关系
$directoryMapping = @{
    # 源代码目录
    "base"       = "src/reactos/base"
    "dll"        = "src/reactos/dll"
    "drivers"    = "src/reactos/drivers"
    "ntoskrnl"   = "src/reactos/ntoskrnl"
    "hal"        = "src/reactos/hal"
    "win32ss"    = "src/reactos/win32ss"
    "subsystems" = "src/reactos/subsystems"
    "modules"    = "src/reactos/modules"
    "boot"       = "src/reactos/boot"
    
    # SDK 和工具
    "sdk"        = "third_party/reactos/sdk"
    
    # 媒体文件
    "media"      = "media/reactos"
}

# 定义文件映射关系（根目录文件）
$fileMapping = @{
    # 构建配置文件
    "CMakeLists.txt"          = "cmake/reactos/CMakeLists.txt"
    "PreLoad.cmake"           = "cmake/reactos/PreLoad.cmake"
    "toolchain-clang.cmake"   = "cmake/reactos/toolchain-clang.cmake"
    "toolchain-gcc.cmake"     = "cmake/reactos/toolchain-gcc.cmake"
    "toolchain-msvc.cmake"    = "cmake/reactos/toolchain-msvc.cmake"
    "overrides-gcc.cmake"     = "cmake/reactos/overrides-gcc.cmake"
    "overrides-msvc.cmake"    = "cmake/reactos/overrides-msvc.cmake"
    
    # 文档文件
    "README.md"               = "docs/reactos/README.md"
    "INSTALL"                 = "docs/reactos/INSTALL.md"
    "CONTRIBUTING.md"         = "docs/reactos/CONTRIBUTING.md"
    "CODING_STYLE.md"         = "docs/reactos/CODING_STYLE.md"
    "CODE_OF_CONDUCT.md"      = "docs/reactos/CODE_OF_CONDUCT.md"
    "PULL_REQUEST_MANAGEMENT.md" = "docs/reactos/PULL_REQUEST_MANAGEMENT.md"
    "CREDITS"                 = "docs/reactos/CREDITS.md"
    "Doxyfile"                = "docs/reactos/Doxyfile"
    
    # 许可证文件
    "COPYING"                 = "docs/reactos/licenses/COPYING"
    "COPYING.ARM"             = "docs/reactos/licenses/COPYING.ARM"
    "COPYING.LIB"             = "docs/reactos/licenses/COPYING.LIB"
    "COPYING3"                = "docs/reactos/licenses/COPYING3"
    "COPYING3.LIB"            = "docs/reactos/licenses/COPYING3.LIB"
    
    # 配置文件
    ".editorconfig"           = "config/reactos/.editorconfig"
    ".clang-format"           = "config/reactos/.clang-format"
    ".gitignore"              = "config/reactos/.gitignore"
    ".gitattributes"          = "config/reactos/.gitattributes"
    ".gitmessage"             = "config/reactos/.gitmessage"
    "CODEOWNERS"              = "config/reactos/CODEOWNERS"
    
    # 构建脚本
    "configure.cmd"           = "scripts/reactos/configure.cmd"
    "configure.sh"            = "scripts/reactos/configure.sh"
    
    # 其他文件
    "apistatus.lst"           = "docs/reactos/apistatus.lst"
}

# 统计信息
$stats = @{
    DirectoriesCopied = 0
    FilesCopied = 0
    TotalSize = 0
    Errors = 0
}

function Copy-ItemWithProgress {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Description
    )
    
    try {
        if ($DryRun) {
            Write-Host "  [模拟] $Description" -ForegroundColor Gray
            Write-Host "    从: $Source" -ForegroundColor DarkGray
            Write-Host "    到: $Destination" -ForegroundColor DarkGray
            return $true
        }
        
        # 创建目标目录
        $destDir = Split-Path -Parent $Destination
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        
        # 复制文件或目录
        if (Test-Path $Source -PathType Container) {
            Write-Host "  复制目录: $Description" -ForegroundColor Green
            Copy-Item -Path $Source -Destination $Destination -Recurse -Force
            $stats.DirectoriesCopied++
        } else {
            Write-Host "  复制文件: $Description" -ForegroundColor Green
            Copy-Item -Path $Source -Destination $Destination -Force
            $fileSize = (Get-Item $Source).Length
            $stats.FilesCopied++
            $stats.TotalSize += $fileSize
        }
        
        return $true
    }
    catch {
        Write-Host "  [错误] 复制失败: $Description" -ForegroundColor Red
        Write-Host "    错误信息: $($_.Exception.Message)" -ForegroundColor Red
        $stats.Errors++
        return $false
    }
}

# 1. 复制目录
Write-Host "步骤 1: 复制源代码目录" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Cyan

foreach ($mapping in $directoryMapping.GetEnumerator()) {
    $sourcePath = Join-Path $ReactOsPath $mapping.Key
    $destPath = Join-Path $TargetPath $mapping.Value
    
    if (Test-Path $sourcePath) {
        Copy-ItemWithProgress -Source $sourcePath -Destination $destPath -Description "$($mapping.Key) -> $($mapping.Value)"
    } else {
        Write-Host "  [跳过] 源目录不存在: $($mapping.Key)" -ForegroundColor Yellow
    }
}

Write-Host ""

# 2. 复制根目录文件
Write-Host "步骤 2: 复制配置和文档文件" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Cyan

foreach ($mapping in $fileMapping.GetEnumerator()) {
    $sourcePath = Join-Path $ReactOsPath $mapping.Key
    $destPath = Join-Path $TargetPath $mapping.Value
    
    if (Test-Path $sourcePath) {
        Copy-ItemWithProgress -Source $sourcePath -Destination $destPath -Description "$($mapping.Key) -> $($mapping.Value)"
    } else {
        Write-Host "  [跳过] 源文件不存在: $($mapping.Key)" -ForegroundColor Yellow
    }
}

Write-Host ""

# 3. 复制 .github 目录（CI/CD 配置）
Write-Host "步骤 3: 复制 CI/CD 配置" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Cyan

$githubSource = Join-Path $ReactOsPath ".github"
$githubDest = Join-Path $TargetPath "config/reactos/.github"

if (Test-Path $githubSource) {
    Copy-ItemWithProgress -Source $githubSource -Destination $githubDest -Description ".github -> config/reactos/.github"
}

Write-Host ""

# 4. 生成映射文档
Write-Host "步骤 4: 生成文件映射文档" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Cyan

$mappingDoc = @"
# ReactOS 文件组织映射

本文档记录了从 ReactOS 源代码到 freeWindows 项目的文件组织映射关系。

生成时间: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## 目录映射

### 源代码目录

"@

foreach ($mapping in $directoryMapping.GetEnumerator() | Sort-Object Key) {
    $mappingDoc += "`n- ``$($mapping.Key)/`` -> ``$($mapping.Value)/``"
}

$mappingDoc += @"


### 配置文件

#### 构建配置

"@

$buildFiles = $fileMapping.GetEnumerator() | Where-Object { $_.Value -like "cmake/*" } | Sort-Object Key
foreach ($mapping in $buildFiles) {
    $mappingDoc += "`n- ``$($mapping.Key)`` -> ``$($mapping.Value)``"
}

$mappingDoc += @"


#### 文档文件

"@

$docFiles = $fileMapping.GetEnumerator() | Where-Object { $_.Value -like "docs/*" -and $_.Value -notlike "*/licenses/*" } | Sort-Object Key
foreach ($mapping in $docFiles) {
    $mappingDoc += "`n- ``$($mapping.Key)`` -> ``$($mapping.Value)``"
}

$mappingDoc += @"


#### 许可证文件

"@

$licenseFiles = $fileMapping.GetEnumerator() | Where-Object { $_.Value -like "*/licenses/*" } | Sort-Object Key
foreach ($mapping in $licenseFiles) {
    $mappingDoc += "`n- ``$($mapping.Key)`` -> ``$($mapping.Value)``"
}

$mappingDoc += @"


#### 开发配置

"@

$configFiles = $fileMapping.GetEnumerator() | Where-Object { $_.Value -like "config/*" } | Sort-Object Key
foreach ($mapping in $configFiles) {
    $mappingDoc += "`n- ``$($mapping.Key)`` -> ``$($mapping.Value)``"
}

$mappingDoc += @"


#### 构建脚本

"@

$scriptFiles = $fileMapping.GetEnumerator() | Where-Object { $_.Value -like "scripts/*" } | Sort-Object Key
foreach ($mapping in $scriptFiles) {
    $mappingDoc += "`n- ``$($mapping.Key)`` -> ``$($mapping.Value)``"
}

$mappingDoc += @"


## 组织原则

1. **源代码** (``src/reactos/``) - 所有 ReactOS 核心源代码
   - 内核、驱动、系统库、子系统等

2. **第三方依赖** (``third_party/reactos/``) - SDK 和开发工具
   - 包含编译所需的 SDK 和工具链

3. **媒体资源** (``media/reactos/``) - 图标、图片等资源文件

4. **构建配置** (``cmake/reactos/``) - CMake 配置文件
   - 包含各种工具链配置和构建脚本

5. **文档** (``docs/reactos/``) - 所有文档和许可证
   - 包括安装指南、贡献指南、编码规范等

6. **配置文件** (``config/reactos/``) - 开发环境配置
   - 编辑器配置、代码格式化、Git 配置等

7. **脚本** (``scripts/reactos/``) - 构建和配置脚本

## 使用说明

### 构建 ReactOS

由于文件已重新组织，需要调整构建流程：

1. 使用 freeWindows 提供的构建脚本
2. 构建系统会自动引用正确的源代码路径
3. 参考 ``docs/getting-started.md`` 了解详细构建步骤

### 更新 ReactOS 源代码

如需更新 ReactOS 源代码：

1. 在原 ReactOS 目录更新代码
2. 重新运行本脚本同步更新
3. 或使用 Git submodule 方式管理（推荐）

## 注意事项

- 本映射保持 ReactOS 原始目录结构，便于追踪上游更新
- 所有 freeWindows 特定的修改应放在对应的 ``patches/`` 目录
- 不要直接修改 ``src/reactos/`` 下的文件，使用补丁方式
"@

$mappingDocPath = Join-Path $TargetPath "docs/REACTOS_FILE_MAPPING.md"

if (-not $DryRun) {
    $mappingDoc | Out-File -FilePath $mappingDocPath -Encoding UTF8
    Write-Host "  已生成映射文档: docs/REACTOS_FILE_MAPPING.md" -ForegroundColor Green
} else {
    Write-Host "  [模拟] 将生成映射文档: docs/REACTOS_FILE_MAPPING.md" -ForegroundColor Gray
}

Write-Host ""

# 5. 显示统计信息
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "复制完成统计" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "目录数量: $($stats.DirectoriesCopied)" -ForegroundColor Green
Write-Host "文件数量: $($stats.FilesCopied)" -ForegroundColor Green
Write-Host "总大小: $([math]::Round($stats.TotalSize / 1MB, 2)) MB" -ForegroundColor Green
Write-Host "错误数量: $($stats.Errors)" -ForegroundColor $(if ($stats.Errors -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($DryRun) {
    Write-Host "这是模拟运行。要实际复制文件，请运行:" -ForegroundColor Yellow
    Write-Host "  .\scripts\copy-reactos-organized.ps1" -ForegroundColor Yellow
} else {
    Write-Host "文件已成功组织并复制到 freeWindows 目录" -ForegroundColor Green
    Write-Host "查看映射文档: docs/REACTOS_FILE_MAPPING.md" -ForegroundColor Cyan
}

Write-Host ""
