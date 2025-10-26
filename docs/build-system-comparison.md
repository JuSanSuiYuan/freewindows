# 构建系统对比：CMake vs 其他方案

## 快速结论

✅ **FreeWindows 使用 CMake** - 这是 ReactOS 迁移到 LLVM 的最佳选择

---

## 为什么选择 CMake？

### 1. ReactOS 已经使用 CMake

**现状**：
- ReactOS 从 0.4.x 版本开始使用 CMake
- 完整的 CMakeLists.txt 体系
- 成熟的构建配置
- 社区熟悉 CMake

**优势**：
- ✅ 零迁移成本
- ✅ 保持兼容性
- ✅ 社区支持

---

### 2. 跨平台支持

**CMake 支持的平台**：
- ✅ Windows（主要开发平台）
- ✅ Linux（交叉编译）
- ✅ macOS（可选）

**其他构建系统的限制**：
- ❌ CBuild-ng：仅 Linux
- ❌ Yocto：仅 Linux
- ❌ Buildroot：仅 Linux

---

### 3. 多种生成器

**CMake 支持的生成器**：
```powershell
# Ninja（推荐，最快）
cmake -G Ninja

# Visual Studio（IDE 集成）
cmake -G "Visual Studio 17 2022"

# Unix Makefiles（传统）
cmake -G "Unix Makefiles"

# NMake Makefiles（Windows）
cmake -G "NMake Makefiles"
```

---

### 4. 编译器无关

**CMake 支持的编译器**：
- ✅ Clang / Clang-CL（FreeWindows 使用）
- ✅ MSVC（ReactOS 原生支持）
- ✅ GCC（MinGW）
- ✅ Intel Compiler

---

## 其他构建系统分析

### CBuild-ng

**定位**：嵌入式 Linux 系统级构建工具

**优势**：
- 快速构建（5 分钟 → 49 秒缓存）
- 系统级依赖管理（300+ 包）
- Kconfig 图形化配置

**劣势**：
- ❌ **不支持 Windows**（文档明确说明）
- ❌ 仅适用于 Linux 发行版构建
- ❌ 不适合单个项目（如 ReactOS）

**结论**：❌ 不适合 FreeWindows

**详细分析**：参见 [CBuild-ng 分析文档](cbuild-ng-analysis.md)

---

### Meson

**定位**：现代构建系统

**优势**：
- 快速（比 CMake 快）
- 简洁的语法
- 良好的 Ninja 集成

**劣势**：
- ⚠️ ReactOS 不使用 Meson
- ⚠️ 需要完全重写构建脚本
- ⚠️ 迁移成本高

**结论**：⚠️ 可行但不推荐（迁移成本高）

---

### Autotools

**定位**：传统 Unix 构建系统

**优势**：
- 成熟稳定
- 广泛使用

**劣势**：
- ❌ 主要用于 Unix/Linux
- ❌ Windows 支持差
- ❌ 复杂难用

**结论**：❌ 不适合 Windows 开发

---

### Bazel

**定位**：Google 的大规模构建系统

**优势**：
- 极快的增量构建
- 强大的缓存机制
- 支持分布式构建

**劣势**：
- ⚠️ 学习曲线陡峭
- ⚠️ 配置复杂
- ⚠️ ReactOS 不使用 Bazel

**结论**：⚠️ 可行但不推荐（过于复杂）

---

### Ninja（构建执行器）

**定位**：快速构建执行器（不是构建系统）

**优势**：
- ✅ 极快的构建速度
- ✅ 最小化磁盘 I/O
- ✅ 更好的并行构建

**使用方式**：
```powershell
# CMake 生成 Ninja 构建文件
cmake -G Ninja -S reactos -B build

# Ninja 执行构建
ninja -C build
```

**结论**：✅ **强烈推荐**（与 CMake 配合使用）

---

## 性能优化方案

### 方案 1：CMake + Ninja（推荐）

**配置**：
```powershell
cmake -G Ninja -S reactos -B build -DCMAKE_BUILD_TYPE=Release
ninja -C build -j8
```

**优势**：
- ✅ 比 Make 快 2-3 倍
- ✅ 更好的并行构建
- ✅ 最小化磁盘 I/O

**预期性能**：
- 首次编译：10-15 分钟
- 增量编译：1-2 分钟

---

### 方案 2：CMake + ccache（推荐）

**配置**：
```powershell
# 安装 ccache
choco install ccache

# 配置 CMake
cmake -DCMAKE_C_COMPILER_LAUNCHER=ccache `
      -DCMAKE_CXX_COMPILER_LAUNCHER=ccache `
      -S reactos -B build
```

**优势**：
- ✅ 缓存编译结果
- ✅ 重复编译快 10 倍
- ✅ 类似 CBuild-ng 的缓存机制

**预期性能**：
- 首次编译：10-15 分钟
- 缓存编译：1-2 分钟

---

### 方案 3：CMake + Ninja + ccache（最佳）

**配置**：
```powershell
cmake -G Ninja `
      -DCMAKE_C_COMPILER_LAUNCHER=ccache `
      -DCMAKE_CXX_COMPILER_LAUNCHER=ccache `
      -DCMAKE_BUILD_TYPE=Release `
      -S reactos -B build

ninja -C build -j8
```

**优势**：
- ✅ 结合 Ninja 和 ccache 的优势
- ✅ 最快的构建速度
- ✅ 最佳的缓存效果

**预期性能**：
- 首次编译：8-12 分钟
- 增量编译：30-60 秒
- 缓存编译：30-60 秒

---

## 性能对比

| 构建方案 | 首次编译 | 增量编译 | 缓存编译 | Windows 支持 |
|---------|---------|---------|---------|-------------|
| **CMake + Make** | 15-20 分钟 | 3-5 分钟 | N/A | ✅ |
| **CMake + Ninja** | 10-15 分钟 | 1-2 分钟 | N/A | ✅ |
| **CMake + ccache** | 10-15 分钟 | 3-5 分钟 | 1-2 分钟 | ✅ |
| **CMake + Ninja + ccache** | 8-12 分钟 | 30-60 秒 | 30-60 秒 | ✅ |
| **CBuild-ng** | 5 分钟 | 49 秒 | 49 秒 | ❌ |

**注意**：CBuild-ng 的性能数据来自嵌入式 Linux 构建，不适用于 ReactOS。

---

## 推荐配置

### 开发环境

```powershell
# 安装工具
choco install cmake ninja ccache

# 配置构建
cd d:\编程项目\freeWindows
.\scripts\configure-reactos.ps1 `
    -Arch amd64 `
    -Toolchain clang-cl `
    -BuildType Debug `
    -Generator Ninja

# 启用 ccache（可选）
$env:CMAKE_C_COMPILER_LAUNCHER = "ccache"
$env:CMAKE_CXX_COMPILER_LAUNCHER = "ccache"

# 构建
ninja -C build\reactos-amd64-clang-cl -j8
```

---

### 生产环境

```powershell
# 发布构建
.\scripts\configure-reactos.ps1 `
    -Arch amd64 `
    -Toolchain clang-cl `
    -BuildType Release `
    -Generator Ninja `
    -EnableLTO

# 构建
ninja -C build\reactos-amd64-clang-cl -j8
```

---

## 总结

### ✅ 推荐方案

**CMake + Ninja + ccache**

**原因**：
1. ✅ 跨平台（Windows/Linux/macOS）
2. ✅ 最快的构建速度
3. ✅ 最佳的缓存效果
4. ✅ ReactOS 已经使用 CMake
5. ✅ 零迁移成本

### ❌ 不推荐方案

**CBuild-ng、Yocto、Buildroot**

**原因**：
1. ❌ 不支持 Windows
2. ❌ 仅适用于嵌入式 Linux
3. ❌ 不适合单个项目
4. ❌ 迁移成本极高

---

## 参考资料

- [CMake 官方文档](https://cmake.org/documentation/)
- [Ninja 构建系统](https://ninja-build.org/)
- [ccache 编译器缓存](https://ccache.dev/)
- [CBuild-ng 分析](cbuild-ng-analysis.md)

---

**文档版本**：1.0  
**最后更新**：2025-10-25  
**推荐方案**：CMake + Ninja + ccache
