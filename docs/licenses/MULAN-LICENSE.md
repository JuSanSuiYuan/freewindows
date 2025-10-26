# 木兰宽松许可证第2版使用指南

## 许可证概述

木兰宽松许可证第2版（Mulan Permissive Software License, Version 2）是一个宽松的开源许可证，具有以下特点：

### 主要特性
- **宽松性**: 允许商业使用、修改、分发
- **专利保护**: 包含专利授权和防御性终止条款
- **国际化**: 中英文双语版本，中文版本具有优先效力
- **兼容性**: 与大多数开源许可证兼容

### 适用场景
- 新编写的代码和文档
- 构建脚本和配置文件
- 项目新增的任何文件

## 许可证文本位置

完整的许可证文本位于项目根目录：
- `LICENSE-MULAN.md` - 完整的木兰宽松许可证第2版文本

## 使用要求

### 文件头注释

在新增的文件开头添加许可证声明：

```cpp
// 木兰宽松许可证，第2版
//
// 版权所有 (c) 2025 FreeWindows 项目
// 本软件根据木兰宽松许可证第2版授权。
// 您可以根据木兰宽松许可证第2版的规定使用、复制、修改和分发本软件。
// 有关详细信息，请参阅 LICENSE-MULAN.md。
//
// Mulan Permissive Software License，Version 2
//
// Copyright (c) 2025 FreeWindows Project
// This software is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//     http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.
```

### 文档文件

在文档文件开头添加：

```markdown
# 文档标题

**许可证**: 木兰宽松许可证第2版  
**版权**: © 2025 FreeWindows 项目
```

### 脚本文件

在脚本文件开头添加：

```bash
#!/bin/bash
#
# 木兰宽松许可证，第2版
# 版权所有 (c) 2025 FreeWindows 项目
# 详见 LICENSE-MULAN.md
```

## 分发要求

### 源代码分发
分发包含木兰许可证的代码时，必须：
1. 保留所有版权声明
2. 包含许可证文本副本
3. 明确说明使用的许可证

### 二进制分发
分发二进制文件时，建议：
1. 在文档中说明使用的许可证
2. 提供获取源代码的方式
3. 包含许可证文本或链接

## 与其他许可证的关系

### 兼容性
木兰宽松许可证第2版与以下许可证兼容：
- MIT 许可证
- Apache 2.0 许可证  
- BSD 许可证
- GPL 系列许可证（通过适当的接口）

### 在 FreeWindows 项目中的使用
在 FreeWindows 项目中，木兰许可证用于：
- 新编写的构建脚本和配置
- 项目文档和说明
- 源代码补丁和修改
- 新增的工具和实用程序

## 常见问题

### Q: 能否将木兰许可证的代码与GPL代码混合？
A: 可以，但混合后的整体作品需要遵循GPL许可证的要求。

### Q: 商业使用是否需要支付费用？
A: 不需要，木兰许可证是免费的，允许商业使用。

### Q: 修改代码后是否需要开源？
A: 木兰许可证不要求修改后的代码必须开源。

## 法律建议

本文档仅供参考，不构成法律建议。如有具体的法律问题，请咨询专业律师。

## 更新历史

- **v1.0** (2025-10-26): 初始版本