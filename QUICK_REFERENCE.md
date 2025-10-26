# FreeWindows 快速参考

## 📁 项目结构速览

```
freeWindows/
├── src/                    # 源代码 (~23,500 项)
│   ├── reactos/           # ReactOS 源代码 (~15,800 项)
│   └── wine/              # Wine 源代码 (~7,600 项)
├── third_party/           # 第三方依赖 (~4,000 项)
│   ├── reactos/sdk/       # ReactOS SDK
│   └── wine/              # Wine 库和工具
├── media/                 # 媒体资源 (~1,400 项)
│   ├── reactos/           # ReactOS 资源
│   └── wine/              # Wine 资源
├── docs/                  # 文档
├── cmake/                 # CMake 配置
├── config/                # 开发配置
├── scripts/               # 自动化脚本
└── patches/               # 源代码补丁
```

## 📚 关键文档

### 入门文档
- **[README.md](README.md)** - 项目介绍
- **[docs/getting-started.md](docs/getting-started.md)** - 入门指南
- **[docs/quick-start-optimized.md](docs/quick-start-optimized.md)** - 优化构建快速开始

### 项目结构
- **[docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md)** - 完整项目结构说明
- **[docs/INTEGRATION_SUMMARY.md](docs/INTEGRATION_SUMMARY.md)** - ReactOS 和 Wine 集成总结
- **[docs/REACTOS_FILE_MAPPING.md](docs/REACTOS_FILE_MAPPING.md)** - ReactOS 文件映射
- **[docs/WINE_FILE_MAPPING.md](docs/WINE_FILE_MAPPING.md)** - Wine 文件映射

### 技术分析
- **[docs/feasibility-analysis.md](docs/feasibility-analysis.md)** - 可行性分析
- **[docs/build-analysis.md](docs/build-analysis.md)** - 构建分析
- **[docs/migration-notes.md](docs/migration-notes.md)** - 迁移笔记

## 🛠️ 常用脚本

### 更新源代码

```powershell
# 更新 ReactOS
cd d:\编程项目\reactos
git pull
cd d:\编程项目\freeWindows
.\scripts\copy-reactos-organized.ps1

# 更新 Wine
cd d:\编程项目\wine
git pull
cd d:\编程项目\freeWindows
.\scripts\copy-wine-organized.ps1
```

### 构建项目

```powershell
# 标准构建
.\scripts\configure.ps1
.\scripts\build.ps1

# 优化构建
.\scripts\configure-optimized.ps1 -EnableCCache
.\scripts\build-optimized.ps1 -ShowStats
```

## 📊 项目统计

| 类别 | 数量 |
|------|------|
| **总文件数** | ~29,000 项 |
| **源代码** | ~23,500 项 |
| **第三方依赖** | ~4,000 项 |
| **媒体资源** | ~1,400 项 |
| **文档** | ~40 个 |

### ReactOS 组件
- base/ - 基础系统组件
- dll/ - 动态链接库
- drivers/ - 设备驱动
- ntoskrnl/ - NT 内核
- hal/ - 硬件抽象层
- win32ss/ - Win32 子系统

### Wine 组件
- dlls/ - Windows DLL 实现
- programs/ - Windows 程序
- server/ - Wine 服务器
- loader/ - Wine 加载器

## 🎯 开发原则

1. **不修改原始源代码** - 保持 ReactOS 和 Wine 源代码不变
2. **使用补丁系统** - 所有修改通过 patches/ 目录管理
3. **清晰的组织** - 按来源和功能分类组织文件
4. **可追溯性** - 维护详细的文件映射文档

## 🔧 技术栈

- **内核**: ReactOS NT 内核
- **用户态**: ReactOS + Wine API 实现
- **编译器**: LLVM/Clang
- **构建系统**: CMake (主要) + autotools (Wine)
- **标准**: C23, C++26

## 📝 许可证

- **ReactOS**: GPL-2.0 / LGPL-2.1
- **Wine**: LGPL-2.1+
- **freeWindows**: 继承上述许可证

## 🚀 下一步

1. ✅ ReactOS 源代码集成
2. ✅ Wine 源代码集成
3. ⏳ 构建系统适配
4. ⏳ LLVM 工具链配置
5. ⏳ 组件评估和选择
6. ⏳ 编译测试

## 📞 资源链接

- [ReactOS 官网](https://reactos.org/)
- [Wine 官网](https://www.winehq.org/)
- [LLVM 官网](https://llvm.org/)
- [ReactOS GitHub](https://github.com/reactos/reactos)
- [Wine GitLab](https://gitlab.winehq.org/wine/wine)

## 💡 提示

- 使用 `docs/` 目录查找详细文档
- 使用 `scripts/` 目录查找自动化脚本
- 查看 `CHANGELOG.md` 了解项目变更
- 查看 `PROGRESS.md` 了解项目进度
