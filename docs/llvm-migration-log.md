# FreeWindows LLVM 迁移日志

## 2025-10-28 - 初始配置成功

### 环境准备

**已安装工具**：
- Clang 20.1.8 (MSVC 兼容模式)
- LLD 20.1.8 (链接器)
- LLVM 工具链 (llvm-lib, llvm-rc, llvm-ar 等)
- CMake 4.1.2
- Ninja 1.13.1
- Bison 3.8.2 (通过 winflexbison)
- Flex 2.6.4 (通过 winflexbison)

### 配置结果

✅ **CMake 配置成功**

```
-- The C compiler identification is Clang 20.1.8 with MSVC-like command-line
-- The CXX compiler identification is Clang 20.1.8 with MSVC-like command-line
-- Found BISON: D:/scoop/shims/bison.exe (found version "3.8.2")
-- Found FLEX: D:/scoop/shims/flex.exe (found version "2.6.4")
-- Configuring done (4.1s)
-- Generating done (0.2s)
```

**配置参数**：
- 架构：amd64
- 工具链：clang-cl (MSVC 兼容模式)
- 构建类型：Debug
- 优化级别：4 (-O1)
- 生成器：Ninja

**构建目录**：`D:\编程项目\freeWindows\build\reactos-amd64-clang-cl`

### 遇到的问题和解决方案

#### 问题 1：脚本参数冲突
**错误**：`A parameter with the name 'Verbose' was defined multiple times`

**原因**：PowerShell 的 CmdletBinding 自动添加了 Verbose 参数，与脚本中定义的参数冲突

**解决方案**：将脚本中的 `-Verbose` 参数重命名为 `-ShowDetails`

#### 问题 2：缺少 Ninja 构建工具
**错误**：`CMake Error: CMake was unable to find a build program corresponding to "Unix Makefiles"`

**解决方案**：
```powershell
choco install ninja -y
```

#### 问题 3：缺少 BISON
**错误**：`Could NOT find BISON (missing: BISON_EXECUTABLE)`

**解决方案**：
```powershell
scoop install bison
```

#### 问题 4：缺少 FLEX
**错误**：`Could NOT find FLEX (missing: FLEX_EXECUTABLE)`

**解决方案**：
```powershell
scoop install winflexbison
```

### 构建进度

**成功构建的组件**（235 个目标中的 209 个）：
- ✅ 所有 SDK 基础工具（bin2c, gendib, geninc, spec2def, utf16le, obj2bin, mkshelllink）
- ✅ asmpp（有 1 个警告）
- ✅ cabman
- ✅ hhpcomp（有 4 个悬空指针警告）
- ✅ zlib 库
- ✅ dbghelp 库
- ✅ 其他 200+ 个目标

**构建统计**：
- 成功：209/235 (88.9%)
- 失败：2 个目标
- 构建时间：11 秒
- 并行度：8 线程

### 遇到的编译错误

#### 错误 1：格式字符串类型不匹配（widl/register.c）

**文件**：`sdk/tools/widl/register.c:45`

**错误信息**：
```
error: format specifies type 'unsigned int' but the argument has type 'unsigned long' [-Werror,-Wformat]
sprintf( buffer, "{%08X-%04X-%04X-%02X%02X-%02X%02X%02X%02X%02X%02X}",
                   ~~~~
                   %08lX
         uuid->Data1, uuid->Data2, uuid->Data3,
         ^~~~~~~~~~~
```

**原因**：
- `uuid->Data1` 是 `unsigned long` 类型
- 格式字符串使用 `%08X`（期望 `unsigned int`）
- 在 64 位 Windows 上，`long` 和 `int` 大小不同

**解决方案**：
```c
// 修改前
sprintf( buffer, "{%08X-%04X-%04X-...", uuid->Data1, ...);

// 修改后
sprintf( buffer, "{%08lX-%04X-%04X-...", uuid->Data1, ...);
// 或
sprintf( buffer, "{%08X-%04X-%04X-...", (unsigned int)uuid->Data1, ...);
```

#### 错误 2：#pragma pack 警告（widl/typelib.c）

**文件**：`sdk/tools/widl/typelib_struct.h:305, 602`

**错误信息**：
```
error: the current #pragma pack alignment value is modified in the included file [-Werror,-Wpragma-pack]
#include "pshpack1.h"
         ^
```

**原因**：
- Clang 对 `#pragma pack` 的嵌套使用更加严格
- ReactOS 代码在头文件中修改了 pack 对齐
- MSVC 允许这种做法，但 Clang 认为这是潜在的错误

**解决方案**：
1. **临时方案**：禁用此警告
   ```cmake
   add_compile_options(-Wno-pragma-pack)
   ```

2. **永久方案**：重构代码，避免在头文件中修改 pack
   ```c
   // 在 .c 文件中而不是 .h 文件中使用 pack
   #pragma pack(push, 1)
   #include "typelib_struct.h"
   #pragma pack(pop)
   ```

### 下一步

1. ✅ 环境准备完成
2. ✅ CMake 配置成功
3. ✅ 构建测试完成（88.9% 成功）
4. ✅ **已完成**：修复编译错误
5. ✅ **已完成**：完整构建测试（100% 成功）
6. ⏸️ 待定：性能对比

---

## 2025-10-30 23:23 - 编译错误修复完成

### 应用的修复

#### 修复 1：格式字符串类型不匹配
**文件**：`third_party/reactos/sdk/tools/widl/register.c:45`
**修改**：`%08X` → `%08lX`
**状态**：✅ 已应用

#### 修复 2：pragma-pack 警告
**文件**：`third_party/reactos/sdk/tools/widl/CMakeLists.txt`
**修改**：添加 `-Wno-pragma-pack` 编译选项
**状态**：✅ 已应用

### 构建结果

✅ **完整构建成功**

```
构建统计：
- 成功：27/27 (100%)
- 失败：0 个目标
- 警告：0 个
- 错误：0 个
```

**成功构建的工具**：
- ✅ widl（已修复）
- ✅ 所有 SDK 工具
- ✅ 所有库文件
- ✅ 所有可执行文件

### 性能数据

- 构建时间：约 15 秒
- 并行度：8 线程
- 编译器：Clang 20.1.8

### 构建命令

```powershell
# 使用 Ninja 构建
ninja -C build\reactos-amd64-clang-cl

# 或使用 CMake
cmake --build build\reactos-amd64-clang-cl --parallel
```

---

**文档版本**：1.0  
**最后更新**：2025-10-28 09:17  
**状态**：配置成功，准备构建
