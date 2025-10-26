# Wine 文件分类复制脚本
# 将 Wine 源代码按类别组织到 freeWindows 目录

param(
    [string]$WinePath = "d:\编程项目\wine",
    [string]$TargetPath = "d:\编程项目\freeWindows",
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Wine 文件分类复制工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "[模拟模式] 不会实际复制文件" -ForegroundColor Yellow
    Write-Host ""
}

# 定义目录映射关系
$directoryMapping = @{
    # 源代码目录
    "dlls"          = "src/wine/dlls"
    "programs"      = "src/wine/programs"
    "server"        = "src/wine/server"
    "loader"        = "src/wine/loader"
    
    # 库文件
    "libs"          = "third_party/wine/libs"
    "include"       = "third_party/wine/include"
    
    # 工具
    "tools"         = "third_party/wine/tools"
    
    # 资源文件
    "fonts"         = "media/wine/fonts"
    "nls"           = "media/wine/nls"
    "po"            = "media/wine/po"
    
    # 文档
    "documentation" = "docs/wine/documentation"
}

# 定义文件映射关系（根目录文件）
$fileMapping = @{
    # 构建配置文件
    "configure"               = "third_party/wine/build/configure"
    "configure.ac"            = "third_party/wine/build/configure.ac"
    "aclocal.m4"              = "third_party/wine/build/aclocal.m4"
    
    # 文档文件
    "README.md"               = "docs/wine/README.md"
    "ANNOUNCE.md"             = "docs/wine/ANNOUNCE.md"
    "AUTHORS"                 = "docs/wine/AUTHORS.md"
    "MAINTAINERS"             = "docs/wine/MAINTAINERS.md"
    "VERSION"                 = "docs/wine/VERSION"
    
    # 许可证文件
    "LICENSE"                 = "docs/wine/licenses/LICENSE"
    "LICENSE.OLD"             = "docs/wine/licenses/LICENSE.OLD"
    "COPYING.LIB"             = "docs/wine/licenses/COPYING.LIB"
    
    # 配置文件
    ".editorconfig"           = "config/wine/.editorconfig"
    ".gitignore"              = "config/wine/.gitignore"
    ".gitattributes"          = "config/wine/.gitattributes"
    ".gitlab-ci.yml"          = "config/wine/.gitlab-ci.yml"
    ".mailmap"                = "config/wine/.mailmap"
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
Write-Host "步骤 1: 复制 Wine 源代码目录" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Cyan

foreach ($mapping in $directoryMapping.GetEnumerator()) {
    $sourcePath = Join-Path $WinePath $mapping.Key
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
    $sourcePath = Join-Path $WinePath $mapping.Key
    $destPath = Join-Path $TargetPath $mapping.Value
    
    if (Test-Path $sourcePath) {
        Copy-ItemWithProgress -Source $sourcePath -Destination $destPath -Description "$($mapping.Key) -> $($mapping.Value)"
    } else {
        Write-Host "  [跳过] 源文件不存在: $($mapping.Key)" -ForegroundColor Yellow
    }
}

Write-Host ""

# 3. 生成映射文档
Write-Host "步骤 3: 生成文件映射文档" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Cyan

$mappingDoc = @"
# Wine 文件组织映射

本文档记录了从 Wine 源代码到 freeWindows 项目的文件组织映射关系。

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

$buildFiles = $fileMapping.GetEnumerator() | Where-Object { $_.Value -like "third_party/wine/build/*" } | Sort-Object Key
foreach ($mapping in $buildFiles) {
    $mappingDoc += "`n- ``$($mapping.Key)`` -> ``$($mapping.Value)``"
}

$mappingDoc += @"


#### 文档文件

"@

$docFiles = $fileMapping.GetEnumerator() | Where-Object { $_.Value -like "docs/wine/*" -and $_.Value -notlike "*/licenses/*" } | Sort-Object Key
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

$configFiles = $fileMapping.GetEnumerator() | Where-Object { $_.Value -like "config/wine/*" } | Sort-Object Key
foreach ($mapping in $configFiles) {
    $mappingDoc += "`n- ``$($mapping.Key)`` -> ``$($mapping.Value)``"
}

$mappingDoc += @"


## 组织原则

1. **源代码** (``src/wine/``) - Wine 核心源代码
   - ``dlls/`` - Windows DLL 实现
   - ``programs/`` - Windows 程序实现
   - ``server/`` - Wine 服务器
   - ``loader/`` - Wine 加载器

2. **第三方依赖** (``third_party/wine/``) - 库、头文件和工具
   - ``libs/`` - 核心库
   - ``include/`` - 头文件
   - ``tools/`` - 构建和开发工具
   - ``build/`` - 构建配置文件

3. **媒体资源** (``media/wine/``) - 字体、本地化等资源
   - ``fonts/`` - 字体文件
   - ``nls/`` - 本地化文件
   - ``po/`` - 翻译文件

4. **文档** (``docs/wine/``) - 所有文档和许可证
   - 包括 README、发布说明、作者列表等
   - ``licenses/`` - 许可证文件
   - ``documentation/`` - 详细文档

5. **配置文件** (``config/wine/``) - 开发环境配置
   - 编辑器配置、Git 配置、CI/CD 配置等

## Wine 与 ReactOS 的关系

Wine 和 ReactOS 都是实现 Windows API 的开源项目：

- **Wine** - 在 Unix-like 系统上运行 Windows 应用程序
- **ReactOS** - 完整的 Windows 兼容操作系统

freeWindows 项目整合两者的优势：
- 使用 ReactOS 的内核和驱动架构
- 参考 Wine 的用户态 API 实现
- 采用 LLVM 工具链进行现代化编译

## 使用说明

### 构建 Wine 组件

Wine 使用 autotools 构建系统，与 ReactOS 的 CMake 不同：

1. Wine 组件需要适配到 freeWindows 的构建系统
2. 可能需要创建 CMake 包装器或转换脚本
3. 参考 ``docs/wine-integration.md`` 了解集成方案

### 更新 Wine 源代码

如需更新 Wine 源代码：

1. 在原 Wine 目录更新代码
2. 重新运行本脚本同步更新
3. 或使用 Git submodule 方式管理（推荐）

## 注意事项

- Wine 使用 autotools，ReactOS 使用 CMake，需要构建系统适配
- Wine 的许可证是 LGPL，与 ReactOS 的 GPL 兼容
- 不要直接修改 ``src/wine/`` 下的文件，使用补丁方式
- Wine 和 ReactOS 的 API 实现可能存在差异，需要仔细评估
"@

$mappingDocPath = Join-Path $TargetPath "docs/WINE_FILE_MAPPING.md"

if (-not $DryRun) {
    $mappingDoc | Out-File -FilePath $mappingDocPath -Encoding UTF8
    Write-Host "  已生成映射文档: docs/WINE_FILE_MAPPING.md" -ForegroundColor Green
} else {
    Write-Host "  [模拟] 将生成映射文档: docs/WINE_FILE_MAPPING.md" -ForegroundColor Gray
}

Write-Host ""

# 4. 显示统计信息
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
    Write-Host "  .\scripts\copy-wine-organized.ps1" -ForegroundColor Yellow
} else {
    Write-Host "Wine 文件已成功组织并复制到 freeWindows 目录" -ForegroundColor Green
    Write-Host "查看映射文档: docs/WINE_FILE_MAPPING.md" -ForegroundColor Cyan
}

Write-Host ""
