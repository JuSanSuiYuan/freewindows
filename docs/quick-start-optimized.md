# 快速开始：优化构建

## 一键启动优化构建

### 最简单的方式

```powershell
cd d:\编程项目\freeWindows

# 1. 安装工具（仅需一次）
choco install cmake ninja llvm ccache

# 2. 优化配置
.\scripts\configure-optimized.ps1 -EnableCCache

# 3. 快速构建
.\scripts\build-optimized.ps1 -ShowStats
```

---

## 完整流程

### 步骤 1：安装必需工具

```powershell
# 使用 Chocolatey（推荐）
choco install cmake ninja llvm ccache

# 或使用 Scoop
scoop install cmake ninja llvm ccache

# 验证安装
cmake --version    # 应该 >= 3.17
ninja --version    # 任何版本
clang --version    # 应该 >= 10.0
ccache --version   # 任何版本
```

---

### 步骤 2：配置构建

#### 开发环境（推荐）

```powershell
.\scripts\configure-optimized.ps1 `
    -Arch amd64 `
    -Toolchain clang-cl `
    -BuildType Debug `
    -EnableCCache
```

**特点**：
- ✅ 快速增量编译
- ✅ 完整调试信息
- ✅ 编译缓存加速

**预期时间**：
- 首次编译：10-12 分钟
- 增量编译：1-2 分钟
- 缓存编译：30-60 秒

---

#### 生产环境

```powershell
.\scripts\configure-optimized.ps1 `
    -Arch amd64 `
    -Toolchain clang-cl `
    -BuildType Release `
    -EnableCCache `
    -EnableLTO `
    -EnableUnityBuild
```

**特点**：
- ✅ 最优性能
- ✅ 最小二进制
- ✅ 全局优化

**预期时间**：
- 首次编译：15-18 分钟
- 增量编译：2-3 分钟
- 缓存编译：1-2 分钟

---

### 步骤 3：执行构建

```powershell
# 使用优化构建脚本（推荐）
.\scripts\build-optimized.ps1 -ShowStats

# 或直接使用 Ninja
ninja -C build\reactos-amd64-clang-cl-optimized -j8

# 或使用通用构建脚本
.\scripts\build.ps1 -BuildDir "build\reactos-amd64-clang-cl-optimized"
```

---

### 步骤 4：查看结果

```powershell
# 查看 ccache 统计
ccache -s

# 查看构建输出
ls build\reactos-amd64-clang-cl-optimized

# 运行测试
.\scripts\test.ps1 -BuildDir "build\reactos-amd64-clang-cl-optimized"
```

---

## 常用命令

### 配置命令

```powershell
# 基础配置
.\scripts\configure-optimized.ps1

# 启用所有优化
.\scripts\configure-optimized.ps1 -EnableCCache -EnableLTO -EnableUnityBuild

# 清理并重新配置
.\scripts\configure-optimized.ps1 -Clean

# 详细输出
.\scripts\configure-optimized.ps1 -Verbose

# i386 架构
.\scripts\configure-optimized.ps1 -Arch i386

# Clang-GNU 工具链
.\scripts\configure-optimized.ps1 -Toolchain clang-gnu
```

---

### 构建命令

```powershell
# 基础构建
.\scripts\build-optimized.ps1

# 显示缓存统计
.\scripts\build-optimized.ps1 -ShowStats

# 清理并构建
.\scripts\build-optimized.ps1 -Clean

# 指定并行任务数
.\scripts\build-optimized.ps1 -Jobs 16

# 构建特定目标
.\scripts\build-optimized.ps1 -Target ntoskrnl

# 详细输出
.\scripts\build-optimized.ps1 -Verbose
```

---

### ccache 命令

```powershell
# 查看统计
ccache -s

# 清空缓存
ccache -C

# 清理过期缓存
ccache -c

# 查看配置
ccache -p

# 设置最大缓存大小
ccache --set-config max_size=20G

# 启用压缩
ccache --set-config compression=true
```

---

## 性能对比

### 不同配置的性能

| 配置 | 首次编译 | 增量编译 | 缓存编译 |
|------|---------|---------|---------|
| **基础（Make）** | 20 分钟 | 5 分钟 | N/A |
| **Ninja** | 12 分钟 | 2 分钟 | N/A |
| **Ninja + ccache** | 12 分钟 | 2 分钟 | 1 分钟 |
| **完整优化** | 15 分钟 | 2.5 分钟 | 1.5 分钟 |

**完整优化** = Ninja + ccache + LTO + Unity Build

---

## 推荐工作流程

### 日常开发

```powershell
# 1. 首次配置（仅需一次）
.\scripts\configure-optimized.ps1 -EnableCCache

# 2. 修改代码
# ... 编辑源文件 ...

# 3. 增量构建
.\scripts\build-optimized.ps1

# 4. 测试
.\scripts\test.ps1
```

**预期时间**：
- 修改 1 个文件：10-30 秒
- 修改 10 个文件：1-2 分钟
- 修改 100 个文件：5-10 分钟

---

### 发布构建

```powershell
# 1. 清理并配置
.\scripts\configure-optimized.ps1 `
    -BuildType Release `
    -EnableCCache `
    -EnableLTO `
    -EnableUnityBuild `
    -Clean

# 2. 完整构建
.\scripts\build-optimized.ps1 -ShowStats

# 3. 运行测试
.\scripts\test.ps1

# 4. 生成 ISO
# ... ReactOS 特定命令 ...
```

---

## 故障排除

### 问题 1：找不到 ninja

**错误**：
```
'ninja' is not recognized as an internal or external command
```

**解决方案**：
```powershell
# 安装 Ninja
choco install ninja

# 或手动下载
# https://github.com/ninja-build/ninja/releases
```

---

### 问题 2：ccache 未生效

**症状**：
```powershell
ccache -s
# cache hit rate: 0.00 %
```

**解决方案**：
```powershell
# 1. 确认 CMake 配置
cmake -LA build | Select-String COMPILER_LAUNCHER

# 2. 清理并重新构建
ninja -C build -t clean
.\scripts\build-optimized.ps1

# 3. 再次查看统计
ccache -s
```

---

### 问题 3：构建失败

**错误**：
```
ninja: error: loading 'build.ninja': No such file or directory
```

**解决方案**：
```powershell
# 重新运行配置
.\scripts\configure-optimized.ps1
```

---

### 问题 4：内存不足

**症状**：
```
clang: error: unable to execute command: Killed
```

**解决方案**：
```powershell
# 减少并行任务数
.\scripts\build-optimized.ps1 -Jobs 4

# 或禁用 Unity Build
.\scripts\configure-optimized.ps1 -EnableCCache
```

---

## 高级技巧

### 技巧 1：使用 RAM Disk

```powershell
# 创建 RAM Disk（需要第三方工具）
# 将构建目录放在 RAM Disk 上

.\scripts\configure-optimized.ps1 `
    -BuildDir "R:\build" `
    -EnableCCache
```

**优势**：
- ✅ 极快的 I/O 速度
- ✅ 减少 SSD 磨损

---

### 技巧 2：远程缓存

```powershell
# 配置远程 ccache 服务器
$env:CCACHE_REMOTE_STORAGE = "redis://cache-server:6379"

# 构建
.\scripts\build-optimized.ps1
```

---

### 技巧 3：并行链接

```cmake
# 在 CMakeLists.txt 中添加
if(MSVC)
    add_link_options(/CGTHREADS:8)
endif()
```

---

## 性能监控

### 构建时间监控

```powershell
# 记录构建时间
$StartTime = Get-Date
.\scripts\build-optimized.ps1
$EndTime = Get-Date
$Duration = $EndTime - $StartTime
Write-Host "构建时间：$($Duration.ToString('mm\:ss'))"
```

---

### ccache 效率监控

```powershell
# 构建前
ccache -z  # 重置统计

# 构建
.\scripts\build-optimized.ps1

# 构建后
ccache -s  # 查看统计
```

**关键指标**：
- **cache hit rate**：缓存命中率（目标 > 80%）
- **cache size**：缓存大小
- **files in cache**：缓存文件数

---

## 总结

### ✅ 推荐配置

**日常开发**：
```powershell
.\scripts\configure-optimized.ps1 -EnableCCache
.\scripts\build-optimized.ps1
```

**发布构建**：
```powershell
.\scripts\configure-optimized.ps1 -EnableCCache -EnableLTO -EnableUnityBuild
.\scripts\build-optimized.ps1
```

### 📊 预期性能

- **首次编译**：10-15 分钟
- **增量编译**：1-2 分钟
- **缓存编译**：30-60 秒

### 🎯 关键要点

1. ✅ 使用 Ninja（必需）
2. ✅ 启用 ccache（强烈推荐）
3. ✅ 调整并行任务数
4. ⚠️ LTO 仅用于 Release
5. ⚠️ Unity Build 谨慎使用

---

**文档版本**：1.0  
**最后更新**：2025-10-25  
**推荐方案**：CMake + Ninja + ccache
