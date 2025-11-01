# 下一步操作指南

## 🎯 当前状态

✅ **基础设施已完成** - 所有必需的文档、脚本和工具链配置已创建  
✅ **C23 标准已配置** - 使用现代 C23 标准，同时保持向后兼容  
✅ **构建系统确认** - 继续使用 CMake（已分析 CBuild-ng，不适合 Windows 开发）  
🔄 **准备开始构建** - 现在可以开始实际的 LLVM/Clang 迁移工作

---

## 📋 立即执行的步骤

### 步骤 1：检查环境 ✓

运行环境检查脚本，确认所有工具已安装：

```powershell
cd d:\编程项目\freeWindows
.\scripts\check-environment.ps1
```

**预期输出**：
- ✓ 所有 LLVM 工具（clang, clang-cl, lld-link 等）
- ✓ CMake 和 Ninja
- ✓ ReactOS 源代码

**如果缺少工具**：
1. **LLVM**：访问 https://github.com/llvm/llvm-project/releases
   - 下载最新的 Windows 安装包（例如：LLVM-18.1.8-win64.exe）
   - 安装时勾选"Add LLVM to system PATH"
   
2. **CMake**：访问 https://cmake.org/download/
   - 下载并安装，确保添加到 PATH

3. **Ninja**（可选但推荐）：
   ```powershell
   choco install ninja
   # 或
   scoop install ninja
   ```

4. **Conan**（可选但推荐）：
   ```powershell
   choco install conan
   # 或从 https://conan.io/downloads.html 下载安装
   ```

---

### 步骤 2：配置 ReactOS 构建 ⏸️

使用 Clang-CL 配置 ReactOS：

```powershell
.\scripts\configure-reactos.ps1 `
    -Arch amd64 `
    -Toolchain clang-cl `
    -BuildType Debug `
    -Verbose
```

**参数说明**：
- `-Arch amd64`：目标架构（也可以用 `i386`）
- `-Toolchain clang-cl`：使用 Clang-CL（MSVC 兼容模式）
- `-BuildType Debug`：调试构建（也可以用 `Release`）
- `-Verbose`：显示详细输出

**预期结果**：
- ✅ **成功**：CMake 配置完成，生成构建文件
- ❌ **失败**：记录错误信息，进入故障排除

---

### 步骤 3：尝试构建 ⏸️

如果配置成功，尝试构建：

```powershell
# 方法 1：使用 CMake 直接构建
cmake --build build\reactos-amd64-clang-cl --parallel

# 方法 2：使用构建脚本
.\scripts\build.ps1 -BuildDir "build\reactos-amd64-clang-cl"

# 方法 3：使用 Conan 包管理器构建
.\scripts\build-with-conan.ps1
```

**预期结果**：
- ✅ **完全成功**：恭喜！ReactOS 已成功使用 Clang 编译
- ⚠️ **部分成功**：某些模块编译失败，记录错误
- ❌ **完全失败**：记录所有错误，进入修复阶段

---

### 步骤 4：记录错误 ⏸️

如果构建失败，创建错误日志：

```powershell
# 将构建输出保存到文件
cmake --build build\reactos-amd64-clang-cl --parallel 2>&1 | Tee-Object -FilePath docs\error-log.txt
```

然后分析错误类型：

1. **内联汇编错误**：
   - 搜索 `error: invalid instruction mnemonic`
   - 搜索 `error: unknown token in expression`

2. **编译器内建函数错误**：
   - 搜索 `error: use of undeclared identifier`
   - 搜索 `error: implicit declaration of function`

3. **链接器错误**：
   - 搜索 `lld-link: error:`
   - 搜索 `undefined reference to`

4. **其他错误**：
   - 记录所有其他错误信息

---

## 🔧 故障排除

### 问题 1：找不到 clang-cl

**症状**：
```
错误：缺少必需的工具：clang-cl
```

**解决方案**：
1. 确认 LLVM 已安装
2. 检查 PATH 环境变量：
   ```powershell
   $env:PATH -split ';' | Select-String llvm
   ```
3. 手动添加到 PATH（临时）：
   ```powershell
   $env:PATH += ";C:\Program Files\LLVM\bin"
   ```

---

### 问题 2：CMake 配置失败

**症状**：
```
CMake Error: Could not find CMAKE_C_COMPILER
```

**解决方案**：
1. 确认编译器路径正确：
   ```powershell
   Get-Command clang-cl
   ```
2. 尝试使用完整路径：
   ```powershell
   .\scripts\configure-reactos.ps1 `
       -Arch amd64 `
       -Toolchain clang-cl `
       -Verbose
   ```

---

### 问题 3：内联汇编错误

**症状**：
```
error: invalid instruction mnemonic 'movl'
```

**原因**：GCC 使用 AT&T 语法，Clang-CL 使用 Intel 语法

**解决方案**：
1. **短期**：切换到 Clang-GNU 工具链：
   ```powershell
   .\scripts\configure-reactos.ps1 -Toolchain clang-gnu
   ```

2. **长期**：创建补丁转换汇编语法

---

### 问题 4：编译器内建函数错误

**症状**：
```
error: use of undeclared identifier '__builtin_xxx'
```

**解决方案**：
创建兼容性头文件（在 `patches/` 中）

---

## 📊 进度跟踪

完成每个步骤后，更新 `PROGRESS.md`：

```markdown
## 阶段 2：环境准备 ✅ 100%

- [x] 运行环境检查脚本
- [x] 确认所有工具已安装
- [x] 验证 LLVM 版本兼容性
```

---

## 📚 相关文档

- **可行性分析**：`docs/feasibility-analysis.md`
- **构建系统分析**：`docs/build-analysis.md`
- **迁移笔记**：`docs/migration-notes.md`
- **进度跟踪**：`PROGRESS.md`

---

## 🎓 学习资源

### LLVM/Clang 文档
- [Clang 用户手册](https://clang.llvm.org/docs/UsersManual.html)
- [LLD 链接器](https://lld.llvm.org/)
- [Clang-CL 文档](https://clang.llvm.org/docs/MSVCCompatibility.html)

### ReactOS 文档
- [ReactOS 构建指南](https://reactos.org/wiki/Building_ReactOS)
- [ReactOS 开发者文档](https://reactos.org/wiki/Development_Introduction)

---

## 💡 提示

1. **从 Debug 构建开始**：更容易调试问题
2. **使用 Verbose 模式**：获取详细的错误信息
3. **逐步构建**：先构建小模块，再构建完整系统
4. **记录所有错误**：为后续修复提供参考
5. **定期提交**：使用 Git 跟踪所有更改

---

## 🚀 成功标准

### 阶段 2 完成标准
- ✅ 所有必需工具已安装
- ✅ 环境检查脚本通过
- ✅ LLVM 版本 ≥ 10.0.0

### 阶段 3 完成标准
- ✅ CMake 配置成功
- ✅ 至少一个模块编译成功
- ✅ 错误日志已创建和分类

### 最终成功标准
- ✅ ReactOS 完全使用 Clang 编译
- ✅ 生成的 ISO 可以启动
- ✅ 所有功能测试通过
- ✅ 性能与 GCC/MSVC 构建相当或更好

---

## 📞 获取帮助

如果遇到问题：

1. **查看文档**：`docs/` 目录中的所有文档
2. **检查进度**：`PROGRESS.md` 中的已知问题
3. **更新笔记**：在 `docs/migration-notes.md` 中记录新问题
4. **社区支持**：ReactOS 论坛和 LLVM 邮件列表

---

**准备好了吗？开始第一步：**

```powershell
cd d:\编程项目\freeWindows
.\scripts\check-environment.ps1
```

祝你好运！🎉
