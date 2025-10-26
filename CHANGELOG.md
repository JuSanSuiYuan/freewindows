# FreeWindows 更新日志

所有重要的更改都会记录在此文件中。

## 0.5.0 - 2025-10-26

### 重大变更

- **技术栈迁移**：决定迁移到 Qt + Vulkan 现代化技术栈
  - **UI 框架**：Qt 6.9+ (FluentWinUI3 风格)
  - **3D 图形**：Vulkan 1.3+
  - **时间表**：6-9 个月完成迁移
  - **详情**：请参阅 `docs/qt-vulkan-migration-plan.md`

### 新特性

- **文档**：新增 Qt vs Vulkan vs Qt+Vulkan 深度分析
- **文档**：新增 Qt + Vulkan 迁移实施计划
- **文档**：新增现代化 UI 实现指南
- **文档**：新增现代化标题栏设计方案

### 计划

- **阶段 1**：环境准备（1 个月）
- **阶段 2**：核心框架（2 个月）
- **阶段 3**：系统界面迁移（3 个月）
- **阶段 4**：Vulkan 3D 支持（2 个月）
- **阶段 5**：应用程序迁移（按需）

## [未发布] - 2025-10-25

### 新增

#### 性能优化方案
- ✅ 实现 CMake + Ninja + ccache 优化方案
- ✅ 新增 `scripts/configure-optimized.ps1` - 优化配置脚本
- ✅ 新增 `scripts/build-optimized.ps1` - 优化构建脚本
- ✅ 新增 `docs/performance-optimization.md` - 性能优化指南
- ✅ 新增 `docs/quick-start-optimized.md` - 快速开始（优化版）
- ✅ 预期性能提升：首次编译 40%，增量编译 60%，缓存编译 80%

#### 构建系统分析
- ✅ 分析 CBuild-ng 作为 CMake 替代方案
- ✅ 结论：CBuild-ng 不适合 Windows 开发，继续使用 CMake
- ✅ 新增 `docs/cbuild-ng-analysis.md` - CBuild-ng 详细分析
- ✅ 新增 `docs/build-system-comparison.md` - 构建系统对比
- ✅ 推荐使用 CMake + Ninja + ccache 优化性能

#### C24/C++26 标准支持
- ✅ 将 C 标准从 C99 升级到 C24（草案，C2y）
- ✅ 将 C++ 标准从 C++17 升级到 C++26（草案）
- ✅ 更新所有工具链文件使用新标准
  - `cmake/toolchains/clang-cl.cmake`：`/std:c2y` 和 `/std:c++26`
  - `cmake/toolchains/clang-gnu.cmake`：`-std=c2y` 和 `-std=c++26`
- ⚠️ 注意：C24 和 C++26 尚未正式发布，使用草案版本

#### 文档
- ✅ 新增 `docs/c23-features.md` - C23 特性详细指南
- ✅ 新增 `docs/standards-and-compatibility.md` - 标准和兼容性文档
- ✅ 更新 `README.md` - 添加现代标准原则
- ✅ 更新 `docs/getting-started.md` - 反映 C23 配置
- ✅ 更新 `NEXT_STEPS.md` - 添加 C23 状态
- ✅ 更新 `PROGRESS.md` - 记录 C23 配置完成

### 技术细节

#### C23 新特性
- `nullptr` 关键字
- `typeof` 和 `typeof_unqual` 运算符
- 二进制字面量（`0b` 前缀）
- 数字分隔符（`1'000'000`）
- 属性（`[[deprecated]]`、`[[nodiscard]]`、`[[maybe_unused]]`）
- `constexpr` 支持
- `auto` 类型推断
- 新标准库头文件（`<stdbit.h>`、`<stdckdint.h>`）

#### 兼容性
- ✅ 向后兼容 ReactOS 的 C99 代码
- ✅ 所有 C99 特性仍然可用
- ⚠️ VLA（可变长度数组）在 C23 中是可选的（Clang 默认支持）
- ✅ 可选择性使用 C23 新特性

#### 编译器要求
- **最低版本**：Clang 10.0.0（基本 C23 支持）
- **推荐版本**：Clang 18.0.0+（完全 C23 支持）

### 迁移策略

#### 阶段 1：保守迁移（当前）
- 使用 C23 编译标志
- 不修改现有代码
- 确保 C99 代码正常编译

#### 阶段 2：渐进式采用（未来）
- 新代码使用 C23 特性
- 重构关键模块
- 保持向后兼容

#### 阶段 3：全面采用（长期）
- 充分利用 C23 特性
- 优化性能
- 提高代码质量

---

## [初始版本] - 2025-10-25

### 新增

#### 项目基础设施
- ✅ 创建 `freeWindows` 项目目录结构
- ✅ 创建 `.gitignore` 文件

#### 文档
- ✅ `README.md` - 项目概述
- ✅ `docs/feasibility-analysis.md` - 详细可行性分析（8000+ 字）
- ✅ `docs/getting-started.md` - 快速开始指南
- ✅ `docs/migration-notes.md` - 迁移笔记模板
- ✅ `docs/summary.md` - 项目总结
- ✅ `docs/build-analysis.md` - ReactOS 构建系统分析
- ✅ `patches/README.md` - 补丁管理说明
- ✅ `PROGRESS.md` - 进度跟踪
- ✅ `NEXT_STEPS.md` - 下一步操作指南

#### CMake 工具链
- ✅ `cmake/toolchains/clang-cl.cmake` - Clang-CL 工具链（MSVC 兼容）
- ✅ `cmake/toolchains/clang-gnu.cmake` - Clang-GNU 工具链（GCC 兼容）
- ✅ `cmake/toolchains/reactos-clang-cl.cmake` - ReactOS 专用工具链

#### 构建脚本
- ✅ `scripts/configure.ps1` - 通用配置脚本
- ✅ `scripts/build.ps1` - 通用构建脚本
- ✅ `scripts/test.ps1` - 通用测试脚本
- ✅ `scripts/configure-reactos.ps1` - ReactOS 专用配置脚本
- ✅ `scripts/check-environment.ps1` - 环境检查脚本

#### 可行性分析
- ✅ **LLVM/Clang 迁移**：完全可行（核心目标）
- ⚠️ **MLIR-AIR 集成**：技术可行但适用范围有限（仅 AMD FPGA）
- ⚠️ **Tawa 集成**：仅适用于 NVIDIA GPU 加速场景
- ⚠️ **Neptune 集成**：适用范围极其有限（仅 AI 推理）

#### ReactOS 构建系统分析
- ✅ 发现 ReactOS 已有 Clang 支持基础
- ✅ 识别 Clang-CL 特殊处理代码
- ✅ 分析编译器检测逻辑
- ✅ 确定推荐工具链（Clang-CL）

### 技术决策

#### 工具链选择
- **推荐**：Clang-CL（MSVC 兼容模式）
  - ReactOS 已有支持代码
  - Windows ABI 兼容性最好
  - 最小化修改

- **备选**：Clang-GNU（GCC 兼容模式）
  - 与 GCC 高度兼容
  - 可能需要更多调整

#### 项目原则
- **零修改原则**：所有文件都在 `freeWindows/` 中，不触碰 `reactos/`
- **完整文档**：从可行性分析到操作指南
- **自动化脚本**：PowerShell 脚本简化操作
- **补丁管理**：完整的补丁创建和应用流程
- **进度跟踪**：清晰的阶段划分和完成标准

---

## 版本说明

- **[未发布]**：正在开发中的功能
- **[初始版本]**：项目创建时的基础功能

---

## 贡献者

- FreeWindows 项目组

---

**文档版本**：1.1  
**最后更新**：2025-10-25  
**C 标准**：C23 (ISO/IEC 9899:2023)  
**C++ 标准**：C++20 (ISO/IEC 14882:2020)
