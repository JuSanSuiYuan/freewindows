# FreeWindows 修复记录

## 2025-10-30 - 编译错误修复

### 修复 1：格式字符串类型不匹配

**文件**：`third_party/reactos/sdk/tools/widl/register.c:45`

**问题**：
```c
sprintf( buffer, "{%08X-%04X-%04X-...", uuid->Data1, ...);
```
- `uuid->Data1` 是 `unsigned long` 类型
- 格式字符串使用 `%08X`（期望 `unsigned int`）
- Clang 报错：`format specifies type 'unsigned int' but the argument has type 'unsigned long'`

**修复**：
```c
sprintf( buffer, "{%08lX-%04X-%04X-...", uuid->Data1, ...);
```
- 将 `%08X` 改为 `%08lX` 以匹配 `unsigned long` 类型

**补丁文件**：`patches/0001-fix-widl-format-string.patch`

---

### 修复 2：#pragma pack 警告

**文件**：`third_party/reactos/sdk/tools/widl/typelib_struct.h:305, 602`

**问题**：
```c
#include "pshpack1.h"
```
- Clang 对 `#pragma pack` 在头文件中的使用更加严格
- 报错：`the current #pragma pack alignment value is modified in the included file`

**修复**：
在 `third_party/reactos/sdk/tools/widl/CMakeLists.txt` 中添加：
```cmake
# Disable pragma-pack warning for Clang (FreeWindows patch)
if(CMAKE_C_COMPILER_ID MATCHES "Clang")
    target_compile_options(widl PRIVATE "-Wno-pragma-pack")
endif()
```

**补丁文件**：`patches/0002-disable-pragma-pack-warning.patch`

---

## 修复状态

- ✅ 格式字符串修复已应用
- ✅ pragma-pack 警告已禁用
- 🔄 准备重新构建测试

---

## 下一步

1. 重新运行构建：
   ```powershell
   cmake --build build\reactos-amd64-clang-cl --parallel
   ```

2. 验证修复是否成功

3. 记录新的构建结果

---

**文档版本**：1.0  
**最后更新**：2025-10-30  
**修复数量**：2

