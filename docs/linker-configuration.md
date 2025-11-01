# LLD 链接器配置文档

## 概述

FreeWindows 项目使用 LLVM 的 LLD 链接器（lld-link）替代传统的 MSVC 链接器和 GNU ld。

**日期**：2025-10-30  
**状态**：✅ 配置完成并测试通过

---

## LLD 链接器优势

### 1. 性能优势

- **快速链接**：比传统链接器快 2-5 倍
- **并行处理**：支持多线程链接
- **增量链接**：支持快速增量链接（可选）

### 2. 兼容性

- **MSVC 兼容**：lld-link 完全兼容 MSVC 链接器
- **符号格式**：支持 PDB 调试符号
- **DEF 文件**：支持 Windows DEF 文件

### 3. 现代化

- **LTO 支持**：完整的链接时优化支持
- **ASLR/DEP**：现代安全特性
- **大文件支持**：处理大型项目无压力

---

## 配置文件

### 主配置文件

**位置**：`cmake/linker/lld-link-config.cmake`

**功能**：
- LLD 基础选项配置
- 调试/发布模式配置
- 性能优化选项
- 辅助函数

### 符号导出配置

**位置**：`cmake/linker/symbol-export.cmake`

**功能**：
- 符号导出/导入宏定义
- DEF 文件生成
- 导入库管理
- 循环依赖处理

---

## LLD 链接选项

### 基础选项

```cmake
/MACHINE:X64          # 64位目标
/NOLOGO               # 不显示版本信息
/INCREMENTAL:NO       # 禁用增量链接（更快）
/OPT:REF              # 移除未引用的函数
/OPT:ICF              # 合并相同的函数
```

### 调试选项

```cmake
/DEBUG:FULL           # 完整调试信息
/DEBUGTYPE:CV         # CodeView 调试格式
/PDB:<TARGET_PDB>     # PDB 文件路径
```

### 发布选项

```cmake
/LTCG                 # 链接时代码生成（LTO）
/OPT:REF              # 移除未引用代码
/OPT:ICF              # 合并相同代码
```

### 性能选项

```cmake
/threads:8            # 使用 8 个线程
/time                 # 显示链接时间
```

---

## 符号导出/导入

### 导出符号

#### 方法 1：使用 __declspec(dllexport)

```c
__declspec(dllexport) void MyFunction() {
    // 函数实现
}
```

#### 方法 2：使用 DEF 文件

```def
LIBRARY MyLibrary
EXPORTS
    MyFunction
    AnotherFunction
```

#### 方法 3：CMake 辅助函数

```cmake
set_dll_exports(my_target
    EXPORTS
        MyFunction
        AnotherFunction
)
```

### 导入符号

#### 方法 1：使用 __declspec(dllimport)

```c
__declspec(dllimport) void MyFunction();
```

#### 方法 2：链接导入库

```cmake
link_import_library(my_target my_library.lib)
```

---

## 不同目标类型的链接配置

### 1. 应用程序（EXE）

```cmake
set_lld_linker_options(my_app APP)
```

**链接选项**：
- `/SUBSYSTEM:WINDOWS`
- `/ENTRY:mainCRTStartup`

### 2. 动态库（DLL）

```cmake
set_lld_linker_options(my_dll DLL)
```

**链接选项**：
- `/DLL`
- `/SUBSYSTEM:WINDOWS`
- `/DYNAMICBASE`（ASLR）
- `/NXCOMPAT`（DEP）

### 3. 驱动程序（SYS）

```cmake
set_lld_linker_options(my_driver DRIVER)
```

**链接选项**：
- `/SUBSYSTEM:NATIVE`
- `/DRIVER`
- `/ENTRY:DriverEntry`
- `/NODEFAULTLIB`

### 4. 内核（NTOSKRNL）

```cmake
set_lld_linker_options(ntoskrnl KERNEL)
```

**链接选项**：
- `/SUBSYSTEM:NATIVE`
- `/ENTRY:KiSystemStartup`
- `/BASE:0x80000000`
- `/FIXED`
- `/NODEFAULTLIB`

---

## 链接测试结果

### 测试日期：2025-10-30

```
✅ 总测试数：16
✅ 成功：16
✅ 失败：0
✅ 成功率：100%
```

### 测试项目

#### 基础工具（7/7 通过）
- ✅ bin2c
- ✅ geninc
- ✅ gendib
- ✅ spec2def
- ✅ utf16le
- ✅ obj2bin
- ✅ mkshelllink

#### 库文件（4/4 通过）
- ✅ zlibhost
- ✅ dbghelphost
- ✅ cmlibhost
- ✅ inflibhost

#### 复杂工具（5/5 通过）
- ✅ widl
- ✅ cabman
- ✅ hhpcomp
- ✅ asmpp
- ✅ xml2sdb

### 性能数据

- **链接时间**：0.09-0.11 秒（单个工具）
- **并行度**：8 线程
- **生成文件**：21 个可执行文件，9 个库文件

---

## 常见问题

### Q1：如何启用 LTO（链接时优化）？

**A**：在 CMake 配置时添加：

```cmake
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
```

或在构建时：

```powershell
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON ..
```

### Q2：如何处理循环依赖？

**A**：使用辅助函数：

```cmake
handle_circular_dependencies(my_target
    LIBRARIES
        lib1
        lib2
)
```

### Q3：如何生成导入库？

**A**：使用辅助函数：

```cmake
set_import_library(my_dll ${CMAKE_BINARY_DIR}/my_dll.lib)
```

### Q4：如何检查符号表？

**A**：使用 llvm-nm：

```powershell
llvm-nm my_program.exe
```

### Q5：链接时间太长怎么办？

**A**：启用并行链接：

```cmake
target_link_options(my_target PRIVATE /threads:8)
```

---

## 与其他链接器对比

### LLD vs MSVC Link

| 特性 | LLD | MSVC Link |
|------|-----|-----------|
| 速度 | ⚡⚡⚡⚡⚡ | ⚡⚡⚡ |
| 并行 | ✅ 8+ 线程 | ✅ 有限 |
| LTO | ✅ 完整支持 | ✅ 支持 |
| 开源 | ✅ | ❌ |
| 跨平台 | ✅ | ❌ |

### LLD vs GNU ld

| 特性 | LLD | GNU ld |
|------|-----|--------|
| Windows | ✅ 原生支持 | ⚠️ 需要 MinGW |
| MSVC 兼容 | ✅ | ❌ |
| 速度 | ⚡⚡⚡⚡⚡ | ⚡⚡⚡⚡ |
| PDB 支持 | ✅ | ❌ |

---

## 下一步

### 阶段 6：测试和验证

1. **编译完整 ReactOS**
   ```powershell
   cmake --build build\reactos-amd64-clang-cl --target all
   ```

2. **生成 ISO 镜像**
   ```powershell
   cmake --build build\reactos-amd64-clang-cl --target bootcd
   ```

3. **虚拟机测试**
   - 使用 QEMU 或 VirtualBox
   - 测试启动和基本功能

### 阶段 7：性能优化

1. **启用 LTO**
2. **启用 PGO**
3. **性能对比测试**

---

## 参考资料

- [LLD 官方文档](https://lld.llvm.org/)
- [LLD-Link 文档](https://lld.llvm.org/windows_support.html)
- [MSVC 链接器选项](https://docs.microsoft.com/en-us/cpp/build/reference/linker-options)

---

**文档版本**：1.0  
**最后更新**：2025-10-30  
**状态**：✅ 链接器配置完成

