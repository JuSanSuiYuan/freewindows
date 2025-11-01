# 标准和兼容性

## 语言标准

### C 语言标准：C23

FreeWindows 项目使用 **C23**（ISO/IEC 9899:2023）作为 C 语言标准。

**工具链配置**：
- Clang-CL：`/std:c23`
- Clang-GNU：`-std=c23`

**原因**：
- ✅ 现代化特性（`nullptr`、`typeof`、`constexpr`）
- ✅ 更好的安全性（属性、溢出检查）
- ✅ 向后兼容 C99 代码
- ✅ 与 C++ 更好的互操作性

**详细信息**：参见 [C23 特性指南](c23-features.md)

---

### C++ 语言标准：C++23

FreeWindows 项目使用 **C++23**（ISO/IEC 14882:2023）作为 C++ 语言标准。

**工具链配置**：
- Clang-CL：`/std:c++23`
- Clang-GNU：`-std=c++23`

**原因**：
- ✅ 概念（Concepts）
- ✅ 协程（Coroutines）
- ✅ 模块（Modules）
- ✅ 范围（Ranges）
- ✅ 三路比较运算符（`<=>`）

---

## 与 ReactOS 的兼容性

### ReactOS 原始标准

ReactOS 使用以下标准：
- **C 标准**：C99（`set(CMAKE_C_STANDARD 99)`）
- **C++ 标准**：C++11（`set(CMAKE_CXX_STANDARD 11)`）

### 兼容性分析

| 方面 | ReactOS (C99) | FreeWindows (C24) | 兼容性 |
|------|---------------|-------------------|--------|
| **基本语法** | ✅ | ✅ | ✅ 完全兼容 |
| **函数声明** | ✅ | ✅ | ✅ 完全兼容 |
| **结构体/联合体** | ✅ | ✅ | ✅ 完全兼容 |
| **指针** | ✅ | ✅ | ✅ 完全兼容 |
| **VLA** | ✅ 强制 | ⚠️ 可选 | ⚠️ 需要检查 |
| **复数类型** | ✅ | ✅ | ✅ 完全兼容 |
| **新特性** | ❌ | ✅ | ✅ 可选使用 |

### 潜在问题

#### 1. VLA（可变长度数组）

**C99**：VLA 是强制特性
```c
void func(int n) {
    int array[n];  // VLA，C99 强制支持
}
```

**C24**：VLA 是可选特性（继承自 C23）

**解决方案**：
- Clang 默认支持 VLA
- 如果需要禁用，使用 `-Wvla` 警告
- 或重构代码使用动态内存分配

#### 2. 隐式函数声明

**C99**：允许（但会警告）
```c
int main() {
    foo();  // 隐式声明为 int foo()
}
```

**C24**：不允许（错误，继承自 C23）

**解决方案**：
- 已在工具链中添加 `-Werror=implicit-function-declaration`
- 确保所有函数都有显式声明

---

## 编译器要求

### 最低版本

| 工具 | 最低版本 | 推荐版本 | C24/C++26 支持 |
|------|----------|----------|----------------|
| **Clang** | 18.0.0 | 19.0.0+ | ✅ 草案支持 |
| **LLVM** | 18.0.0 | 19.0.0+ | ✅ 草案支持 |
| **CMake** | 3.17.0 | 3.28.0+ | ✅ 支持 |

### 检查编译器版本

```powershell
# 检查 Clang 版本
clang --version

# 检查 C23 支持
clang -std=c2x -E -dM - < /dev/null | Select-String "__STDC_VERSION__"
```

**预期输出**：
```
#define __STDC_VERSION__ 202400L  // C24 (草案)
```

---

## 迁移策略

### 阶段 1：保守迁移（当前）

**目标**：使用 C24 编译，但不修改现有代码

**策略**：
- ✅ 使用 `-std=c2y` 编译标志
- ✅ 不修改 ReactOS 源代码
- ✅ 确保 C99 代码仍然可以编译

**预期结果**：
- 所有 C99 代码正常编译
- 可以选择性使用 C23 特性

---

### 阶段 2：渐进式采用（未来）

**目标**：逐步使用 C24 特性改进代码

**策略**：
- ⏸️ 新代码使用 C24 特性
- ⏸️ 重构关键模块使用 C24
- ⏸️ 保持向后兼容

**示例**：
```c
// 旧代码（C99）
void *ptr = NULL;
#define MAX(a, b) ((a) > (b) ? (a) : (b))

// 新代码（C24）
void *ptr = nullptr;
#define MAX(a, b) ({ \
    typeof(a) _a = (a); \
    typeof(b) _b = (b); \
    _a > _b ? _a : _b; \
})
```

---

### 阶段 3：全面采用（长期）

**目标**：充分利用 C23 特性

**策略**：
- ⏸️ 使用 `constexpr` 替代宏
- ⏸️ 使用属性标记 API
- ⏸️ 使用新标准库函数
- ⏸️ 优化性能
- ⏸️ 探索 C23 新增特性

---

## 兼容性测试

### 测试计划

1. **编译测试**：
   - ✅ 配置 C23 工具链
   - ⏸️ 编译 ReactOS 所有模块
   - ⏸️ 记录编译错误

2. **功能测试**：
   - ⏸️ 启动测试
   - ⏸️ 驱动加载测试
   - ⏸️ 应用程序测试

3. **性能测试**：
   - ⏸️ 编译时间对比
   - ⏸️ 二进制大小对比
   - ⏸️ 运行时性能对比

---

## 标准库支持

### C23 新增头文件

| 头文件 | 功能 | Clang 支持 | 使用建议 |
|--------|------|------------|----------|
| `<stdbit.h>` | 位操作 | ✅ Clang 18+ | ✅ 推荐使用 |
| `<stdckdint.h>` | 溢出检查 | ✅ Clang 18+ | ✅ 推荐使用 |
| C24 新增 | 待定 | ⏸️ Clang 19+ | ⏸️ 待标准发布 |
| 其他改进 | 各种增强 | ✅ | ✅ 可选使用 |

### 示例：使用 C23 标准库

```c
#include <stdbit.h>
#include <stdckdint.h>

// 位操作
unsigned int count_bits(unsigned int x) {
    return stdc_count_ones(x);  // C23 标准函数
}

// 溢出检查
bool safe_add(int a, int b, int *result) {
    return !ckd_add(result, a, b);  // 返回 false 表示无溢出
}
```

---

## 编译器标志参考

### C 标准标志

| 标志 | 说明 | 支持 |
|------|------|------|
| `-std=c89` | C89/C90 标准 | ✅ |
| `-std=c99` | C99 标准 | ✅ |
| `-std=c11` | C11 标准 | ✅ |
| `-std=c17` | C17 标准 | ✅ |
| `-std=c2x` | C23 标准（草案名称） | ✅ |
| `-std=c23` | C23 标准（正式名称） | ✅ Clang 18+ |
| `-std=c23` | C23 标准 | ✅ Clang 17+ |

### C++ 标准标志

| 标志 | 说明 | 支持 |
|------|------|------|
| `-std=c++11` | C++11 标准 | ✅ |
| `-std=c++14` | C++14 标准 | ✅ |
| `-std=c++17` | C++17 标准 | ✅ |
| `-std=c++20` | C++20 标准 | ✅ |
| `-std=c++23` | C++23 标准 | ✅ Clang 17+ |
| `-std=c++23` | C++23 标准 | ✅ Clang 17+ |

---

## 参考资料

### C24 标准
- [C24 标准草案（待发布）](https://www.open-std.org/jtc1/sc22/wg14/)
- [C23 标准草案（N3096）](https://www.open-std.org/jtc1/sc22/wg14/www/docs/n3096.pdf)
- [C 标准新特性概览](https://en.cppreference.com/w/c)
- [Clang C 支持状态](https://clang.llvm.org/c_status.html)

### C++26 标准
- [C++26 标准草案（待发布）](https://isocpp.org/)
- [C++23 标准](https://en.cppreference.com/w/cpp/23)
- [C++20 标准](https://en.cppreference.com/w/cpp/20)
- [Clang C++ 支持状态](https://clang.llvm.org/cxx_status.html)

### ReactOS 兼容性
- [ReactOS 构建指南](https://reactos.org/wiki/Building_ReactOS)
- [ReactOS 编码规范](https://reactos.org/wiki/Coding_Style)

---

## 总结

✅ **FreeWindows 使用 C23 和 C++23 标准**  
✅ **向后兼容 ReactOS 的 C99/C++11 代码**  
✅ **可选择性使用新特性**  
✅ **推荐渐进式采用**  
✅ **Clang 17+ 支持这些标准**

---

**文档版本**：1.1  
**最后更新**：2025-10-25  
**C 标准**：C23 (ISO/IEC 9899:2023)  
**C++ 标准**：C++23 (ISO/IEC 14882:2023)
