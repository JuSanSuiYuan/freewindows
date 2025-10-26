# ReactOS 到 LLVM 迁移笔记

本文档记录 ReactOS 从 GCC/MSVC 迁移到 LLVM/Clang 过程中遇到的问题和解决方案。

---

## 迁移进度

### 阶段 1：基础设施搭建 ✅

- [x] 创建 `freeWindows` 项目结构
- [x] 编写 CMake 工具链文件（clang-cl、clang-gnu）
- [x] 编写构建脚本（configure.ps1、build.ps1、test.ps1）
- [x] 编写文档（可行性分析、快速开始指南）

### 阶段 2：编译器适配 🔄

- [ ] 分析 ReactOS 构建系统
- [ ] 识别 GCC/MSVC 特定代码
- [ ] 修复编译器兼容性问题
- [ ] 处理内联汇编差异
- [ ] 调整编译器标志

### 阶段 3：链接器适配 ⏸️

- [ ] 配置 LLD 链接器
- [ ] 调整链接脚本
- [ ] 处理符号导出/导入
- [ ] 修复链接错误

### 阶段 4：测试和验证 ⏸️

- [ ] 单元测试
- [ ] 集成测试
- [ ] 启动测试
- [ ] 性能测试

### 阶段 5：优化 ⏸️

- [ ] 启用 LTO（链接时优化）
- [ ] 启用 PGO（配置文件引导优化）
- [ ] 调整优化标志
- [ ] 性能对比分析

---

## 已知问题和解决方案

### 1. 编译器差异

#### 问题 1.1：内联汇编语法

**问题描述**：
ReactOS 包含大量内联汇编代码，GCC 使用 AT&T 语法，MSVC 使用 Intel 语法。

**示例**：
```c
// GCC (AT&T 语法)
__asm__ volatile (
    "movl %0, %%eax\n"
    "addl %1, %%eax\n"
    : "=r" (result)
    : "r" (a), "r" (b)
    : "eax"
);

// MSVC (Intel 语法)
__asm {
    mov eax, a
    add eax, b
    mov result, eax
}
```

**解决方案**：
- **方案 A**：使用 Clang-GNU 工具链（支持 AT&T 语法）
- **方案 B**：使用 Clang-CL 工具链，并将汇编代码转换为 Intel 语法
- **方案 C**：将内联汇编提取到独立的 `.asm` 文件中

**状态**：待实施

---

#### 问题 1.2：编译器内建函数

**问题描述**：
GCC 和 MSVC 的内建函数（intrinsics）不完全兼容。

**示例**：
```c
// GCC
__builtin_popcount(x)
__builtin_clz(x)

// MSVC
__popcnt(x)
_BitScanReverse(&index, x)
```

**解决方案**：
- Clang 支持两种风格的内建函数
- 使用条件编译选择正确的内建函数
- 创建兼容性头文件

**示例代码**：
```c
// compat.h
#ifdef __clang__
    #define POPCOUNT(x) __builtin_popcount(x)
    #define CLZ(x) __builtin_clz(x)
#elif defined(_MSC_VER)
    #define POPCOUNT(x) __popcnt(x)
    #define CLZ(x) _BitScanReverse(&index, x)
#endif
```

**状态**：待实施

---

#### 问题 1.3：预处理器宏

**问题描述**：
ReactOS 代码依赖 `_MSC_VER` 和 `__GNUC__` 宏来检测编译器。

**解决方案**：
- Clang-CL 自动定义 `_MSC_VER`
- Clang-GNU 自动定义 `__GNUC__`
- 如果需要，可以手动定义这些宏

**CMake 配置**：
```cmake
# 模拟 MSVC 2022
add_compile_definitions(_MSC_VER=1930)

# 模拟 GCC 11
add_compile_definitions(__GNUC__=11 __GNUC_MINOR__=0)
```

**状态**：已实施（在工具链文件中）

---

### 2. 链接器差异

#### 问题 2.1：链接脚本格式

**问题描述**：
GNU ld 和 MSVC link.exe 使用不同的链接脚本格式。

**解决方案**：
- LLD 支持两种格式
- 使用 `lld-link`（MSVC 格式）或 `ld.lld`（GNU 格式）

**状态**：待实施

---

#### 问题 2.2：符号导出/导入

**问题描述**：
Windows DLL 需要显式导出/导入符号（`__declspec(dllexport/dllimport)`）。

**解决方案**：
- 确保所有公共符号正确标记
- 使用 `.def` 文件或 `__declspec`

**状态**：待实施

---

### 3. 构建系统差异

#### 问题 3.1：ReactOS 构建系统

**问题描述**：
ReactOS 使用自定义的构建系统（RBuild），可能不完全兼容 CMake。

**解决方案**：
- ReactOS 已经支持 CMake（从 0.4.x 版本开始）
- 使用 CMake 作为主要构建系统
- 调整 CMakeLists.txt 以支持 Clang

**状态**：待分析

---

#### 问题 3.2：依赖项管理

**问题描述**：
ReactOS 依赖一些外部库（如 FreeType、zlib 等）。

**解决方案**：
- 确保这些库也使用 LLVM 工具链编译
- 或使用预编译的二进制文件（需要 ABI 兼容）

**状态**：待分析

---

## 性能对比

### 编译时间

| 工具链 | 编译时间 | 相对速度 |
|--------|----------|----------|
| GCC 11 | 待测试 | 基准 |
| MSVC 2022 | 待测试 | 待测试 |
| Clang-CL 18 | 待测试 | 待测试 |
| Clang-GNU 18 | 待测试 | 待测试 |

### 运行时性能

| 工具链 | 启动时间 | 内存占用 | 性能分数 |
|--------|----------|----------|----------|
| GCC 11 | 待测试 | 待测试 | 基准 |
| MSVC 2022 | 待测试 | 待测试 | 待测试 |
| Clang-CL 18 | 待测试 | 待测试 | 待测试 |
| Clang-GNU 18 | 待测试 | 待测试 | 待测试 |

### 二进制大小

| 工具链 | 内核大小 | 驱动大小 | 总大小 |
|--------|----------|----------|--------|
| GCC 11 | 待测试 | 待测试 | 待测试 |
| MSVC 2022 | 待测试 | 待测试 | 待测试 |
| Clang-CL 18 | 待测试 | 待测试 | 待测试 |
| Clang-GNU 18 | 待测试 | 待测试 | 待测试 |

---

## 优化建议

### 1. 链接时优化（LTO）

**启用方法**：
```cmake
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
```

**预期收益**：
- 减小二进制大小（5-15%）
- 提高运行时性能（5-10%）
- 增加编译时间（20-50%）

---

### 2. 配置文件引导优化（PGO）

**步骤**：
1. 使用 `-fprofile-generate` 编译
2. 运行代表性工作负载
3. 使用 `-fprofile-use` 重新编译

**预期收益**：
- 提高运行时性能（10-20%）
- 优化热路径代码

---

### 3. 目标架构优化

**示例**：
```cmake
# 针对现代 x86-64 CPU
add_compile_options(-march=x86-64-v3)

# 或针对特定 CPU
add_compile_options(-march=native)
```

**注意**：
- `-march=native` 仅适用于本地构建
- 发布版本应使用通用的 `-march=x86-64`

---

## 参考资料

### LLVM/Clang 文档
- [Clang 命令行参考](https://clang.llvm.org/docs/ClangCommandLineReference.html)
- [LLD 链接器文档](https://lld.llvm.org/)
- [LLVM 优化指南](https://llvm.org/docs/Passes.html)

### ReactOS 文档
- [ReactOS 构建指南](https://reactos.org/wiki/Building_ReactOS)
- [ReactOS 开发者文档](https://reactos.org/wiki/Development_Introduction)

### 迁移案例
- [Chromium 迁移到 Clang](https://chromium.googlesource.com/chromium/src/+/master/docs/clang.md)
- [Firefox 迁移到 Clang](https://firefox-source-docs.mozilla.org/build/buildsystem/toolchains.html)

---

## 贡献指南

如果你在迁移过程中遇到问题或找到解决方案，请更新本文档。

**格式**：
```markdown
#### 问题 X.Y：问题标题

**问题描述**：
简要描述问题

**示例**：
代码示例（如果适用）

**解决方案**：
解决方案描述

**状态**：待实施/进行中/已完成
```

---

**文档版本**：1.0  
**最后更新**：2025-10-25  
**维护者**：FreeWindows 项目组
