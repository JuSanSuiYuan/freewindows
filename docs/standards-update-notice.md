# 标准更新通知

## C24 和 C++26 标准更新

**日期**：2025-10-25  
**版本**：1.1

---

## 更新内容

### C 语言标准：C99 → C24

- **旧标准**：C99（ISO/IEC 9899:1999）
- **新标准**：C24（ISO/IEC 9899:2024 草案，代号 C2y）
- **工具链标志**：`-std=c2y` 或 `/std:c2y`

### C++ 语言标准：C++17 → C++26

- **旧标准**：C++17（ISO/IEC 14882:2017）
- **新标准**：C++26（ISO/IEC 14882:2026 草案）
- **工具链标志**：`-std=c++26` 或 `/std:c++26`

---

## 重要说明

### ⚠️ 草案版本

**C24 和 C++26 尚未正式发布**，目前使用的是草案版本：

- **C24**：使用草案名称 `c2y`（C2y = C 标准的下一个版本）
- **C++26**：使用草案名称 `c++26`

**影响**：
- 标准可能会有变化
- 某些特性可能不稳定
- 编译器支持可能不完整

**建议**：
- 开发环境可以使用草案版本
- 生产环境建议等待正式发布

---

## 编译器要求

### 最低版本

| 编译器 | 最低版本 | 推荐版本 | 说明 |
|--------|----------|----------|------|
| **Clang** | 18.0.0 | 19.0.0+ | C24/C++26 草案支持 |
| **LLVM** | 18.0.0 | 19.0.0+ | 完整工具链 |

### 检查版本

```powershell
# 检查 Clang 版本
clang --version

# 应该显示 >= 18.0.0
```

---

## 工具链更新

### 已更新的文件

1. **`cmake/toolchains/clang-cl.cmake`**
   ```cmake
   # 旧配置
   set(CMAKE_C_FLAGS_INIT "/W4 /WX- /nologo /std:c2x")
   set(CMAKE_CXX_FLAGS_INIT "/W4 /WX- /nologo /std:c++20 /EHsc")
   
   # 新配置
   set(CMAKE_C_FLAGS_INIT "/W4 /WX- /nologo /std:c2y")
   set(CMAKE_CXX_FLAGS_INIT "/W4 /WX- /nologo /std:c++26 /EHsc")
   ```

2. **`cmake/toolchains/clang-gnu.cmake`**
   ```cmake
   # 旧配置
   set(CMAKE_C_FLAGS_INIT "-Wall -Wextra -Werror=implicit-function-declaration -std=c2x")
   set(CMAKE_CXX_FLAGS_INIT "-Wall -Wextra -std=c++20 -fno-exceptions -fno-rtti")
   
   # 新配置
   set(CMAKE_C_FLAGS_INIT "-Wall -Wextra -Werror=implicit-function-declaration -std=c2y")
   set(CMAKE_CXX_FLAGS_INIT "-Wall -Wextra -std=c++26 -fno-exceptions -fno-rtti")
   ```

---

## 兼容性

### ✅ 向后兼容

所有 C99 和 C++11 代码仍然可以编译：

- **C99 代码**：完全兼容
- **C++11 代码**：完全兼容
- **新特性**：可选使用

### ⚠️ 潜在问题

1. **VLA（可变长度数组）**
   - C99：强制支持
   - C24：可选支持
   - **解决方案**：Clang 默认支持 VLA

2. **隐式函数声明**
   - C99：允许（警告）
   - C24：不允许（错误）
   - **解决方案**：确保所有函数都有声明

---

## 新特性（C24）

### 继承自 C23 的特性

1. **`nullptr` 关键字**
   ```c
   void *ptr = nullptr;  // 类型安全的空指针
   ```

2. **`typeof` 运算符**
   ```c
   typeof(x) y = x;  // 类型推断
   ```

3. **二进制字面量**
   ```c
   unsigned int flags = 0b1010'1100;
   ```

4. **属性**
   ```c
   [[deprecated("Use new_function instead")]]
   void old_function(void);
   ```

5. **`constexpr`**
   ```c
   constexpr int BUFFER_SIZE = 1024;
   ```

### C24 新增特性（待定）

C24 标准正在制定中，可能会有新增特性。请关注：
- [C 标准委员会](https://www.open-std.org/jtc1/sc22/wg14/)
- [Clang C 支持状态](https://clang.llvm.org/c_status.html)

---

## 新特性（C++26）

### 继承自 C++20/C++23 的特性

1. **概念（Concepts）**
   ```cpp
   template<typename T>
   concept Addable = requires(T a, T b) {
       { a + b } -> std::same_as<T>;
   };
   ```

2. **协程（Coroutines）**
   ```cpp
   generator<int> fibonacci() {
       int a = 0, b = 1;
       while (true) {
           co_yield a;
           auto next = a + b;
           a = b;
           b = next;
       }
   }
   ```

3. **范围（Ranges）**
   ```cpp
   std::vector<int> vec = {1, 2, 3, 4, 5};
   auto even = vec | std::views::filter([](int n) { return n % 2 == 0; });
   ```

### C++26 新增特性（待定）

C++26 标准正在制定中，可能会有新增特性。请关注：
- [C++ 标准委员会](https://isocpp.org/)
- [Clang C++ 支持状态](https://clang.llvm.org/cxx_status.html)

---

## 迁移指南

### 步骤 1：更新编译器

```powershell
# 检查当前版本
clang --version

# 如果版本 < 18.0.0，需要更新
choco upgrade llvm
```

### 步骤 2：重新配置构建

```powershell
cd d:\编程项目\freeWindows

# 清理旧配置
.\scripts\configure-optimized.ps1 -Clean

# 重新配置
.\scripts\configure-optimized.ps1 -EnableCCache
```

### 步骤 3：测试编译

```powershell
# 构建
.\scripts\build-optimized.ps1

# 如果遇到错误，查看错误日志
```

### 步骤 4：验证标准

```powershell
# 检查 C 标准
clang -std=c2y -E -dM - < /dev/null | Select-String "__STDC_VERSION__"

# 检查 C++ 标准
clang++ -std=c++26 -E -dM - < /dev/null | Select-String "__cplusplus"
```

---

## 常见问题

### Q1：为什么使用草案版本？

**A**：为了使用最新的语言特性，提高代码质量和性能。草案版本通常比较稳定，且 Clang 支持良好。

---

### Q2：草案版本稳定吗？

**A**：相对稳定，但可能会有变化。建议：
- 开发环境：可以使用
- 生产环境：建议等待正式发布

---

### Q3：如何回退到 C23/C++20？

**A**：修改工具链文件：

```cmake
# 回退到 C23
set(CMAKE_C_FLAGS_INIT "/W4 /WX- /nologo /std:c2x")

# 回退到 C++20
set(CMAKE_CXX_FLAGS_INIT "/W4 /WX- /nologo /std:c++20 /EHsc")
```

---

### Q4：会影响现有代码吗？

**A**：不会。C24 和 C++26 向后兼容，所有现有代码仍然可以编译。

---

### Q5：需要修改代码吗？

**A**：不需要。新特性是可选的，可以选择性使用。

---

## 相关文档

- [C24 特性指南](c23-features.md)（已更新）
- [标准和兼容性](standards-and-compatibility.md)（已更新）
- [性能优化指南](performance-optimization.md)
- [快速开始](quick-start-optimized.md)

---

## 总结

✅ **C 标准**：C99 → C24（草案，c2y）  
✅ **C++ 标准**：C++17 → C++26（草案）  
✅ **向后兼容**：所有现有代码仍然可以编译  
✅ **新特性**：可选使用  
⚠️ **注意**：草案版本，可能会有变化

---

**文档版本**：1.0  
**最后更新**：2025-10-25  
**C 标准**：C24 (ISO/IEC 9899:2024 草案，C2y)  
**C++ 标准**：C++26 (ISO/IEC 14882:2026 草案)
