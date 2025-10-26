# ReactOS 文件组织映射

本文档记录了从 ReactOS 源代码到 freeWindows 项目的文件组织映射关系。

生成时间: 2025-10-26 10:30:04

## 目录映射

### 源代码目录

- `base/` -> `src/reactos/base/`
- `boot/` -> `src/reactos/boot/`
- `dll/` -> `src/reactos/dll/`
- `drivers/` -> `src/reactos/drivers/`
- `hal/` -> `src/reactos/hal/`
- `media/` -> `media/reactos/`
- `modules/` -> `src/reactos/modules/`
- `ntoskrnl/` -> `src/reactos/ntoskrnl/`
- `sdk/` -> `third_party/reactos/sdk/`
- `subsystems/` -> `src/reactos/subsystems/`
- `win32ss/` -> `src/reactos/win32ss/`

### 配置文件

#### 构建配置

- `CMakeLists.txt` -> `cmake/reactos/CMakeLists.txt`
- `overrides-gcc.cmake` -> `cmake/reactos/overrides-gcc.cmake`
- `overrides-msvc.cmake` -> `cmake/reactos/overrides-msvc.cmake`
- `PreLoad.cmake` -> `cmake/reactos/PreLoad.cmake`
- `toolchain-clang.cmake` -> `cmake/reactos/toolchain-clang.cmake`
- `toolchain-gcc.cmake` -> `cmake/reactos/toolchain-gcc.cmake`
- `toolchain-msvc.cmake` -> `cmake/reactos/toolchain-msvc.cmake`

#### 文档文件

- `apistatus.lst` -> `docs/reactos/apistatus.lst`
- `CODE_OF_CONDUCT.md` -> `docs/reactos/CODE_OF_CONDUCT.md`
- `CODING_STYLE.md` -> `docs/reactos/CODING_STYLE.md`
- `CONTRIBUTING.md` -> `docs/reactos/CONTRIBUTING.md`
- `CREDITS` -> `docs/reactos/CREDITS.md`
- `Doxyfile` -> `docs/reactos/Doxyfile`
- `INSTALL` -> `docs/reactos/INSTALL.md`
- `PULL_REQUEST_MANAGEMENT.md` -> `docs/reactos/PULL_REQUEST_MANAGEMENT.md`
- `README.md` -> `docs/reactos/README.md`

#### 许可证文件

- `COPYING` -> `docs/reactos/licenses/COPYING`
- `COPYING.ARM` -> `docs/reactos/licenses/COPYING.ARM`
- `COPYING.LIB` -> `docs/reactos/licenses/COPYING.LIB`
- `COPYING3` -> `docs/reactos/licenses/COPYING3`
- `COPYING3.LIB` -> `docs/reactos/licenses/COPYING3.LIB`

#### 开发配置

- `.clang-format` -> `config/reactos/.clang-format`
- `.editorconfig` -> `config/reactos/.editorconfig`
- `.gitattributes` -> `config/reactos/.gitattributes`
- `.gitignore` -> `config/reactos/.gitignore`
- `.gitmessage` -> `config/reactos/.gitmessage`
- `CODEOWNERS` -> `config/reactos/CODEOWNERS`

#### 构建脚本

- `configure.cmd` -> `scripts/reactos/configure.cmd`
- `configure.sh` -> `scripts/reactos/configure.sh`

## 组织原则

1. **源代码** (`src/reactos/`) - 所有 ReactOS 核心源代码
   - 内核、驱动、系统库、子系统等

2. **第三方依赖** (`third_party/reactos/`) - SDK 和开发工具
   - 包含编译所需的 SDK 和工具链

3. **媒体资源** (`media/reactos/`) - 图标、图片等资源文件

4. **构建配置** (`cmake/reactos/`) - CMake 配置文件
   - 包含各种工具链配置和构建脚本

5. **文档** (`docs/reactos/`) - 所有文档和许可证
   - 包括安装指南、贡献指南、编码规范等

6. **配置文件** (`config/reactos/`) - 开发环境配置
   - 编辑器配置、代码格式化、Git 配置等

7. **脚本** (`scripts/reactos/`) - 构建和配置脚本

## 使用说明

### 构建 ReactOS

由于文件已重新组织，需要调整构建流程：

1. 使用 freeWindows 提供的构建脚本
2. 构建系统会自动引用正确的源代码路径
3. 参考 `docs/getting-started.md` 了解详细构建步骤

### 更新 ReactOS 源代码

如需更新 ReactOS 源代码：

1. 在原 ReactOS 目录更新代码
2. 重新运行本脚本同步更新
3. 或使用 Git submodule 方式管理（推荐）

## 注意事项

- 本映射保持 ReactOS 原始目录结构，便于追踪上游更新
- 所有 freeWindows 特定的修改应放在对应的 `patches/` 目录
- 不要直接修改 `src/reactos/` 下的文件，使用补丁方式
