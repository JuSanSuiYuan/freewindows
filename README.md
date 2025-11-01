# FreeWindows 项目

## 项目目标

将 ReactOS 操作系统从 GCC/MSVC 编译器迁移到基于 LLVM 的现代编译器工具链，并探索集成以下先进编译技术的可行性：

1. **LLVM/Clang** - 现代 C/C++ 编译器前端和优化框架
2. **MLIR-AIR** - AMD/Xilinx 的 AI 引擎 MLIR 方言
3. **Tawa** - NVIDIA GPU 自动 warp 专用化编译器
4. **Neptune** - Apache TVM 的分支，用于深度学习编译

## 项目原则

- **不修改 ReactOS 源代码**：所有修改、补丁、构建脚本都放在 `freeWindows/` 目录中
- **保持兼容性**：确保迁移后的系统功能与原 ReactOS 保持一致
- **渐进式迁移**：分阶段完成从 GCC/MSVC 到 LLVM 的迁移
- **使用现代标准**：采用 C23 和 C++23 标准，同时保持向后兼容

## 目录结构

```
freeWindows/
├── docs/               # 文档和可行性分析
├── cmake/              # CMake 工具链文件
├── toolchain/          # LLVM 工具链配置
├── scripts/            # 构建脚本
├── patches/            # ReactOS 源代码补丁（如需要）
├── build/              # 构建输出目录
└── third_party/        # 第三方依赖
```

## 快速开始

### 标准构建
详见 [docs/getting-started.md](docs/getting-started.md)

### 优化构建（推荐）
```powershell
# 安装工具
choco install cmake ninja llvm ccache

# 优化配置
.\scripts\configure-optimized.ps1 -EnableCCache

# 快速构建
.\scripts\build-optimized.ps1 -ShowStats
```

### 使用 Conan 包管理器构建
```powershell
# 安装 Conan
# 从 https://conan.io/downloads.html 下载并安装

# 使用 Conan 构建
.\scripts\build-with-conan.ps1
```

详见 [docs/quick-start-optimized.md](docs/quick-start-optimized.md)

## 许可证

FreeWindows 项目采用**混合许可证策略**:

### 原有代码许可证
- **ReactOS 源代码**: GPL-2.0 / LGPL-2.1
- **Wine 源代码**: LGPL-2.1+
- **第三方依赖**: 保持原有许可证

### 新代码许可证  
- **项目新增代码**: 木兰宽松许可证第2版 (MulanPSL v2)
- **文档和脚本**: 木兰宽松许可证第2版

### 详细说明
请参阅 [LICENSE-COMPOSITE.md](LICENSE-COMPOSITE.md) 了解完整的混合许可证策略。

## 许可证文件
- [LICENSE-MULAN.md](LICENSE-MULAN.md) - 木兰宽松许可证第2版
- [LICENSE-COMPOSITE.md](LICENSE-COMPOSITE.md) - 混合许可证声明
