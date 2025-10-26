# ReactOS 补丁目录

本目录包含针对 ReactOS 源代码的补丁，用于支持 LLVM/Clang 编译。

## 原则

- **不修改 ReactOS 源代码**：所有修改通过补丁形式提供
- **最小化补丁**：仅修改必要的代码
- **上游优先**：尽可能将补丁提交到 ReactOS 上游

## 补丁格式

使用 Git 格式的补丁文件（`.patch`）：

```bash
# 生成补丁
git format-patch -1 <commit-hash> -o patches/

# 应用补丁
git apply patches/<patch-file>.patch
```

## 补丁列表

### 编译器兼容性补丁

| 补丁文件 | 描述 | 状态 |
|---------|------|------|
| `0001-clang-inline-asm.patch` | 修复内联汇编兼容性 | 待创建 |
| `0002-clang-intrinsics.patch` | 修复编译器内建函数 | 待创建 |
| `0003-clang-warnings.patch` | 修复 Clang 警告 | 待创建 |

### 链接器兼容性补丁

| 补丁文件 | 描述 | 状态 |
|---------|------|------|
| `0010-lld-linker-script.patch` | 调整链接脚本 | 待创建 |
| `0011-lld-symbol-export.patch` | 修复符号导出 | 待创建 |

### 构建系统补丁

| 补丁文件 | 描述 | 状态 |
|---------|------|------|
| `0020-cmake-clang-support.patch` | CMake Clang 支持 | 待创建 |
| `0021-cmake-lld-support.patch` | CMake LLD 支持 | 待创建 |

## 应用补丁

### 方法 1：自动应用（推荐）

```powershell
# 使用提供的脚本
.\scripts\apply-patches.ps1
```

### 方法 2：手动应用

```powershell
# 进入 ReactOS 目录
cd ..\reactos

# 应用所有补丁
Get-ChildItem ..\freeWindows\patches\*.patch | ForEach-Object {
    git apply $_.FullName
}
```

## 创建补丁

### 步骤 1：修改 ReactOS 代码

```powershell
cd ..\reactos
# 进行必要的修改
```

### 步骤 2：提交更改

```powershell
git add <modified-files>
git commit -m "Fix: Clang compatibility for inline assembly"
```

### 步骤 3：生成补丁

```powershell
git format-patch -1 HEAD -o ..\freeWindows\patches\
```

### 步骤 4：重命名补丁

```powershell
# 按照编号规则重命名
mv ..\freeWindows\patches\0001-*.patch ..\freeWindows\patches\0001-clang-inline-asm.patch
```

### 步骤 5：更新本文档

在上面的补丁列表中添加新补丁的信息。

## 提交到上游

如果补丁具有通用价值，应该提交到 ReactOS 上游：

1. 访问 [ReactOS JIRA](https://jira.reactos.org/)
2. 创建新的 issue
3. 附加补丁文件
4. 等待审核和合并

## 注意事项

- 补丁应该是独立的、可单独应用的
- 每个补丁应该只解决一个问题
- 补丁文件名应该描述性强
- 补丁应该包含详细的提交信息
- 定期检查补丁是否仍然适用（ReactOS 更新后）

## 补丁维护

### 检查补丁是否仍然适用

```powershell
cd ..\reactos
git apply --check ..\freeWindows\patches\<patch-file>.patch
```

### 更新过时的补丁

如果 ReactOS 更新导致补丁无法应用：

1. 手动解决冲突
2. 重新生成补丁
3. 更新补丁文件

---

**文档版本**：1.0  
**最后更新**：2025-10-25
