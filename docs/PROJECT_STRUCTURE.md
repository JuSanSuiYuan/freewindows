# FreeWindows 项目结构

本文档概述了 freeWindows 项目的完整目录结构和组织方式。

生成时间: 2025-10-26

## 项目概述

freeWindows 整合了 ReactOS 和 Wine 两个开源项目，旨在创建一个基于 LLVM 工具链的现代 Windows 兼容操作系统。

## 顶层目录结构

```
freeWindows/
├── src/                    # 源代码
│   ├── reactos/           # ReactOS 源代码
│   └── wine/              # Wine 源代码
├── third_party/           # 第三方依赖
│   ├── reactos/           # ReactOS SDK 和工具
│   └── wine/              # Wine 库和工具
├── media/                 # 媒体资源
│   ├── reactos/           # ReactOS 资源
│   └── wine/              # Wine 资源
├── docs/                  # 文档
│   ├── reactos/           # ReactOS 文档
│   └── wine/              # Wine 文档
├── cmake/                 # CMake 配置
│   ├── reactos/           # ReactOS CMake 文件
│   └── toolchains/        # 工具链配置
├── config/                # 开发配置
│   ├── reactos/           # ReactOS 配置
│   └── wine/              # Wine 配置
├── scripts/               # 构建和工具脚本
│   ├── reactos/           # ReactOS 脚本
│   └── *.ps1              # freeWindows 脚本
├── patches/               # 源代码补丁
└── build/                 # 构建输出（未跟踪）
```

## 详细目录说明

### 1. 源代码 (`src/`)

#### ReactOS 源代码 (`src/reactos/`)
- **base/** - 基础系统组件（shell、系统工具等）
- **dll/** - 动态链接库（kernel32、user32、gdi32 等）
- **drivers/** - 设备驱动程序（文件系统、网络、存储等）
- **ntoskrnl/** - Windows NT 内核实现
- **hal/** - 硬件抽象层
- **win32ss/** - Win32 子系统（窗口管理、GDI 等）
- **subsystems/** - 其他子系统（POSIX、Win32 等）
- **modules/** - 可加载模块
- **boot/** - 引导加载程序

#### Wine 源代码 (`src/wine/`)
- **dlls/** - Windows DLL 的 Wine 实现（7500+ 文件）
- **programs/** - Windows 程序实现（600+ 文件）
- **server/** - Wine 服务器（进程管理、同步等）
- **loader/** - Wine 加载器

### 2. 第三方依赖 (`third_party/`)

#### ReactOS (`third_party/reactos/`)
- **sdk/** - 软件开发工具包
  - 头文件、库文件、工具等

#### Wine (`third_party/wine/`)
- **libs/** - Wine 核心库（1375 项）
- **include/** - Wine 头文件（1097 项）
- **tools/** - 构建和开发工具（182 项）
- **build/** - 构建配置文件
  - configure, configure.ac, aclocal.m4

### 3. 媒体资源 (`media/`)

#### ReactOS 资源 (`media/reactos/`)
- **doc/** - 文档资源
- **drivers/** - 驱动相关资源
- **fonts/** - 字体文件
- **graphics/** - 图形资源（图标、位图等）
- **inf/** - 设备信息文件
- **nls/** - 本地化文件
- **sdb/** - 应用程序兼容性数据库
- **sounds/** - 系统声音
- **themes/** - 主题文件
- **vgafonts/** - VGA 字体

#### Wine 资源 (`media/wine/`)
- **fonts/** - Wine 字体文件（28 项）
- **nls/** - 本地化文件（77 项）
- **po/** - 翻译文件（51 项）

### 4. 文档 (`docs/`)

#### 项目文档
- **getting-started.md** - 入门指南
- **quick-start-optimized.md** - 优化构建快速开始
- **PROJECT_STRUCTURE.md** - 本文档
- **REACTOS_FILE_MAPPING.md** - ReactOS 文件映射
- **WINE_FILE_MAPPING.md** - Wine 文件映射

#### ReactOS 文档 (`docs/reactos/`)
- **README.md** - ReactOS 说明
- **INSTALL.md** - 安装指南
- **CONTRIBUTING.md** - 贡献指南
- **CODING_STYLE.md** - 编码规范
- **CODE_OF_CONDUCT.md** - 行为准则
- **CREDITS.md** - 贡献者名单
- **licenses/** - 许可证文件
  - COPYING, COPYING.LIB, COPYING3, COPYING3.LIB, COPYING.ARM

#### Wine 文档 (`docs/wine/`)
- **README.md** - Wine 说明
- **ANNOUNCE.md** - 发布公告
- **AUTHORS.md** - 作者列表
- **MAINTAINERS.md** - 维护者列表
- **VERSION** - 版本信息
- **documentation/** - 详细文档（17 项）
- **licenses/** - 许可证文件
  - LICENSE, LICENSE.OLD, COPYING.LIB

### 5. 构建配置 (`cmake/`)

#### ReactOS CMake (`cmake/reactos/`)
- **CMakeLists.txt** - 主 CMake 配置
- **PreLoad.cmake** - 预加载配置
- **toolchain-clang.cmake** - Clang 工具链
- **toolchain-gcc.cmake** - GCC 工具链
- **toolchain-msvc.cmake** - MSVC 工具链
- **overrides-gcc.cmake** - GCC 覆盖配置
- **overrides-msvc.cmake** - MSVC 覆盖配置

#### 工具链 (`cmake/toolchains/`)
- freeWindows 自定义工具链配置

### 6. 开发配置 (`config/`)

#### ReactOS 配置 (`config/reactos/`)
- **.clang-format** - 代码格式化配置
- **.editorconfig** - 编辑器配置
- **.gitignore** - Git 忽略规则
- **.gitattributes** - Git 属性
- **.gitmessage** - Git 提交消息模板
- **CODEOWNERS** - 代码所有者
- **.github/** - GitHub CI/CD 配置

#### Wine 配置 (`config/wine/`)
- **.editorconfig** - 编辑器配置
- **.gitattributes** - Git 属性
- **.gitlab-ci.yml** - GitLab CI 配置
- **.mailmap** - 邮箱映射

### 7. 脚本 (`scripts/`)

#### freeWindows 脚本
- **copy-reactos-organized.ps1** - ReactOS 文件组织复制脚本
- **copy-wine-organized.ps1** - Wine 文件组织复制脚本
- **configure-optimized.ps1** - 优化配置脚本
- **build-optimized.ps1** - 优化构建脚本

#### ReactOS 脚本 (`scripts/reactos/`)
- **configure.cmd** - Windows 配置脚本
- **configure.sh** - Unix 配置脚本

### 8. 补丁 (`patches/`)

用于存放对 ReactOS 和 Wine 源代码的修改补丁。

## 项目统计

### 文件数量统计
- **ReactOS**
  - 目录: 12 个主要目录
  - 配置文件: 29 个
  - 总项目: ~28,000 项
  
- **Wine**
  - 目录: 11 个主要目录
  - 配置文件: 15 个
  - 总项目: ~11,000 项

- **freeWindows 总计**
  - 源代码: ~23,000 项
  - 第三方依赖: ~4,000 项
  - 媒体资源: ~1,400 项
  - 文档: ~40 项

## 设计原则

### 1. 分离原则
- **不修改原始源代码**: ReactOS 和 Wine 的源代码保持原样
- **使用补丁系统**: 所有修改通过 `patches/` 目录管理
- **独立构建配置**: freeWindows 特定的构建配置独立存放

### 2. 组织原则
- **按来源分类**: 清晰区分 ReactOS、Wine 和 freeWindows 自有内容
- **按功能分类**: 源代码、依赖、资源、文档分别组织
- **保持可追溯**: 维护详细的文件映射文档

### 3. 集成原则
- **ReactOS 为基础**: 使用 ReactOS 的内核和驱动架构
- **Wine 为参考**: 参考 Wine 的用户态 API 实现
- **LLVM 为工具**: 采用 LLVM/Clang 作为编译工具链

## 构建系统

### 当前状态
- ReactOS 使用 **CMake** 构建系统
- Wine 使用 **autotools** 构建系统
- 需要创建统一的构建系统或适配层

### 计划方案
1. **方案 A**: 将 Wine 组件转换为 CMake
2. **方案 B**: 创建混合构建系统
3. **方案 C**: 选择性集成 Wine 组件

详见 `docs/build-system-integration.md`（待创建）

## 许可证

### ReactOS
- **主许可证**: GPL-2.0
- **库许可证**: LGPL-2.1
- **其他**: 部分组件使用 GPL-3.0, LGPL-3.0

### Wine
- **主许可证**: LGPL-2.1+
- **兼容性**: 与 ReactOS 的 GPL/LGPL 兼容

### freeWindows
- 继承 ReactOS 和 Wine 的许可证
- 遵循 GPL-2.0 和 LGPL-2.1

## 下一步计划

1. **构建系统集成**
   - 创建统一的 CMake 配置
   - 适配 Wine 组件到 CMake

2. **LLVM 工具链配置**
   - 配置 Clang/LLVM 编译器
   - 测试编译 ReactOS 组件

3. **组件选择和集成**
   - 评估 Wine 和 ReactOS 的重叠组件
   - 确定集成策略

4. **测试和验证**
   - 建立测试框架
   - 验证编译输出

## 参考文档

- [ReactOS 文件映射](REACTOS_FILE_MAPPING.md)
- [Wine 文件映射](WINE_FILE_MAPPING.md)
- [入门指南](getting-started.md)
- [优化构建指南](quick-start-optimized.md)

## 维护说明

### 更新源代码

#### 更新 ReactOS
```powershell
cd d:\编程项目\reactos
git pull
cd d:\编程项目\freeWindows
.\scripts\copy-reactos-organized.ps1
```

#### 更新 Wine
```powershell
cd d:\编程项目\wine
git pull
cd d:\编程项目\freeWindows
.\scripts\copy-wine-organized.ps1
```

### 推荐使用 Git Submodule

为了更好地管理依赖，建议将 ReactOS 和 Wine 作为 Git submodule：

```bash
git submodule add https://github.com/reactos/reactos.git external/reactos
git submodule add https://gitlab.winehq.org/wine/wine.git external/wine
```

然后修改复制脚本的源路径指向 submodule。

## 联系方式

如有问题或建议，请参考项目 README.md 中的联系方式。
