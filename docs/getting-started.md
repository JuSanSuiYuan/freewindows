# FreeWindows 快速开始指南

## 前置要求

### 1. 安装 LLVM 工具链

#### Windows 平台

**方法 A：使用官方安装包（推荐）**

1. 访问 [LLVM Releases](https://github.com/llvm/llvm-project/releases)
2. 下载最新的 Windows 安装包（例如：`LLVM-18.1.0-win64.exe`）
3. 运行安装程序，确保勾选以下选项：
   - ✅ Add LLVM to the system PATH
   - ✅ Install Clang
   - ✅ Install LLD
   - ✅ Install clang-cl

**方法 B：使用包管理器**

```powershell
# 使用 Chocolatey
choco install llvm

# 或使用 Scoop
scoop install llvm
```

**验证安装**：

```powershell
clang --version
clang-cl --version
lld-link --version
```

### 2. 安装 CMake

```powershell
# 使用 Chocolatey
choco install cmake

# 或使用 Scoop
scoop install cmake

# 或从官网下载
# https://cmake.org/download/
```

### 3. 安装 Ninja（可选，推荐）

```powershell
# 使用 Chocolatey
choco install ninja

# 或使用 Scoop
scoop install ninja
```

### 4. 其他工具

```powershell
# Git（如果还没有）
choco install git

# Python（用于构建脚本）
choco install python
```

---

## 项目结构

```
freeWindows/
├── README.md                   # 项目概述
├── docs/                       # 文档
│   ├── feasibility-analysis.md # 可行性分析
│   ├── getting-started.md      # 本文档
│   ├── build-guide.md          # 详细构建指南
│   └── migration-notes.md      # 迁移笔记
├── cmake/                      # CMake 配置
│   ├── toolchains/             # 工具链文件
│   │   ├── clang-cl.cmake      # Clang-CL 工具链
│   │   └── clang-gnu.cmake     # Clang-GNU 工具链
│   └── modules/                # CMake 模块
├── toolchain/                  # 工具链配置
│   ├── clang-cl/               # Clang-CL 配置
│   └── clang-gnu/              # Clang-GNU 配置
├── scripts/                    # 构建脚本
│   ├── build.ps1               # 主构建脚本
│   ├── configure.ps1           # 配置脚本
│   └── test.ps1                # 测试脚本
├── patches/                    # ReactOS 补丁
│   └── README.md               # 补丁说明
├── build/                      # 构建输出（.gitignore）
└── third_party/                # 第三方依赖
```

---

## 快速开始

### 步骤 1：克隆或确认 ReactOS 源代码

确保 ReactOS 源代码在 `d:\编程项目\reactos\` 目录中。

```powershell
# 如果还没有克隆
cd d:\编程项目
git clone https://github.com/reactos/reactos.git
```

### 步骤 2：配置 FreeWindows 构建

```powershell
cd d:\编程项目\freeWindows
.\scripts\configure.ps1 -Toolchain clang-cl
```

**参数说明**：
- `-Toolchain clang-cl`：使用 Clang-CL（MSVC 兼容模式）
- `-Toolchain clang-gnu`：使用 Clang（GCC 兼容模式）

### 步骤 3：构建 ReactOS

```powershell
.\scripts\build.ps1
```

### 步骤 4：测试

```powershell
.\scripts\test.ps1
```

---

## 配置选项

### CMake 工具链文件

#### Clang-CL 工具链（推荐）

文件：`cmake/toolchains/clang-cl.cmake`

```cmake
# 设置编译器
set(CMAKE_C_COMPILER clang-cl)
set(CMAKE_CXX_COMPILER clang-cl)
set(CMAKE_LINKER lld-link)

# 设置编译器标志（使用 C23 和 C++20）
set(CMAKE_C_FLAGS_INIT "/W4 /WX /std:c2x")
set(CMAKE_CXX_FLAGS_INIT "/W4 /WX /std:c++20")

# 设置链接器标志
set(CMAKE_EXE_LINKER_FLAGS_INIT "/MACHINE:X64")
```

#### Clang-GNU 工具链

文件：`cmake/toolchains/clang-gnu.cmake`

```cmake
# 设置编译器
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_LINKER ld.lld)

# 设置编译器标志（使用 C23 和 C++20）
set(CMAKE_C_FLAGS_INIT "-Wall -Wextra -Werror -std=c2x")
set(CMAKE_CXX_FLAGS_INIT "-Wall -Wextra -Werror -std=c++20")
```

---

## 构建脚本说明

### configure.ps1

配置构建环境，生成 CMake 缓存。

```powershell
.\scripts\configure.ps1 `
    -Toolchain clang-cl `
    -BuildType Release `
    -Generator Ninja
```

**参数**：
- `-Toolchain`：工具链类型（`clang-cl` 或 `clang-gnu`）
- `-BuildType`：构建类型（`Debug`、`Release`、`RelWithDebInfo`）
- `-Generator`：CMake 生成器（`Ninja`、`Visual Studio 17 2022`）

### build.ps1

执行构建。

```powershell
.\scripts\build.ps1 `
    -Target all `
    -Jobs 8
```

**参数**：
- `-Target`：构建目标（`all`、`kernel`、`drivers` 等）
- `-Jobs`：并行任务数

### test.ps1

运行测试。

```powershell
.\scripts\test.ps1 `
    -TestSuite unit `
    -Verbose
```

**参数**：
- `-TestSuite`：测试套件（`unit`、`integration`、`boot`）
- `-Verbose`：详细输出

---

## 常见问题

### Q1：编译错误：找不到 `clang-cl`

**解决方案**：

1. 确认 LLVM 已正确安装
2. 检查环境变量 `PATH` 是否包含 LLVM 的 `bin` 目录
3. 重启 PowerShell 或命令提示符

```powershell
# 检查 PATH
$env:PATH -split ';' | Select-String llvm

# 手动添加（临时）
$env:PATH += ";C:\Program Files\LLVM\bin"
```

### Q2：链接错误：找不到 `lld-link`

**解决方案**：

确保安装了完整的 LLVM 工具链，包括 LLD。

```powershell
# 验证 LLD 安装
lld-link --version
```

### Q3：内联汇编错误

**解决方案**：

ReactOS 可能包含 GCC 风格的内联汇编（AT&T 语法）。Clang-CL 默认使用 Intel 语法。

**选项 A**：使用 Clang-GNU 工具链

```powershell
.\scripts\configure.ps1 -Toolchain clang-gnu
```

**选项 B**：修改汇编代码（在 `patches/` 中创建补丁）

### Q4：预处理器宏不兼容

**解决方案**：

Clang 可以模拟 GCC 和 MSVC 的宏。

```cmake
# 在 CMakeLists.txt 中添加
add_compile_definitions(
    _MSC_VER=1930  # 模拟 MSVC 2022
    __GNUC__=11    # 模拟 GCC 11
)
```

### Q5：性能不如 GCC/MSVC

**解决方案**：

1. 启用 LTO（链接时优化）
2. 使用 PGO（配置文件引导优化）
3. 调整优化标志

```cmake
# 启用 LTO
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)

# 优化标志
set(CMAKE_C_FLAGS_RELEASE "-O3 -march=native")
```

---

## 下一步

1. 阅读 [详细构建指南](build-guide.md)
2. 查看 [可行性分析](feasibility-analysis.md)
3. 参与 [迁移笔记](migration-notes.md)

---

## 获取帮助

- **GitHub Issues**：[提交问题](https://github.com/your-repo/freeWindows/issues)
- **文档**：查看 `docs/` 目录中的其他文档
- **ReactOS 社区**：[ReactOS 论坛](https://reactos.org/forum/)

---

**文档版本**：1.0  
**最后更新**：2025-10-25
