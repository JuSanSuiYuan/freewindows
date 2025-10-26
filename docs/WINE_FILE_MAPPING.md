# Wine 文件组织映射

本文档记录了从 Wine 源代码到 freeWindows 项目的文件组织映射关系。

生成时间: 2025-10-26 10:38:56

## 目录映射

### 源代码目录

- `dlls/` -> `src/wine/dlls/`
- `documentation/` -> `docs/wine/documentation/`
- `fonts/` -> `media/wine/fonts/`
- `include/` -> `third_party/wine/include/`
- `libs/` -> `third_party/wine/libs/`
- `loader/` -> `src/wine/loader/`
- `nls/` -> `media/wine/nls/`
- `po/` -> `media/wine/po/`
- `programs/` -> `src/wine/programs/`
- `server/` -> `src/wine/server/`
- `tools/` -> `third_party/wine/tools/`

### 配置文件

#### 构建配置

- `aclocal.m4` -> `third_party/wine/build/aclocal.m4`
- `configure` -> `third_party/wine/build/configure`
- `configure.ac` -> `third_party/wine/build/configure.ac`

#### 文档文件

- `ANNOUNCE.md` -> `docs/wine/ANNOUNCE.md`
- `AUTHORS` -> `docs/wine/AUTHORS.md`
- `MAINTAINERS` -> `docs/wine/MAINTAINERS.md`
- `README.md` -> `docs/wine/README.md`
- `VERSION` -> `docs/wine/VERSION`

#### 许可证文件

- `COPYING.LIB` -> `docs/wine/licenses/COPYING.LIB`
- `LICENSE` -> `docs/wine/licenses/LICENSE`
- `LICENSE.OLD` -> `docs/wine/licenses/LICENSE.OLD`

#### 开发配置

- `.editorconfig` -> `config/wine/.editorconfig`
- `.gitattributes` -> `config/wine/.gitattributes`
- `.gitignore` -> `config/wine/.gitignore`
- `.gitlab-ci.yml` -> `config/wine/.gitlab-ci.yml`
- `.mailmap` -> `config/wine/.mailmap`

## 组织原则

1. **源代码** (`src/wine/`) - Wine 核心源代码
   - `dlls/` - Windows DLL 实现
   - `programs/` - Windows 程序实现
   - `server/` - Wine 服务器
   - `loader/` - Wine 加载器

2. **第三方依赖** (`third_party/wine/`) - 库、头文件和工具
   - `libs/` - 核心库
   - `include/` - 头文件
   - `tools/` - 构建和开发工具
   - `build/` - 构建配置文件

3. **媒体资源** (`media/wine/`) - 字体、本地化等资源
   - `fonts/` - 字体文件
   - `nls/` - 本地化文件
   - `po/` - 翻译文件

4. **文档** (`docs/wine/`) - 所有文档和许可证
   - 包括 README、发布说明、作者列表等
   - `licenses/` - 许可证文件
   - `documentation/` - 详细文档

5. **配置文件** (`config/wine/`) - 开发环境配置
   - 编辑器配置、Git 配置、CI/CD 配置等

## Wine 与 ReactOS 的关系

Wine 和 ReactOS 都是实现 Windows API 的开源项目：

- **Wine** - 在 Unix-like 系统上运行 Windows 应用程序
- **ReactOS** - 完整的 Windows 兼容操作系统

freeWindows 项目整合两者的优势：
- 使用 ReactOS 的内核和驱动架构
- 参考 Wine 的用户态 API 实现
- 采用 LLVM 工具链进行现代化编译

## 使用说明

### 构建 Wine 组件

Wine 使用 autotools 构建系统，与 ReactOS 的 CMake 不同：

1. Wine 组件需要适配到 freeWindows 的构建系统
2. 可能需要创建 CMake 包装器或转换脚本
3. 参考 `docs/wine-integration.md` 了解集成方案

### 更新 Wine 源代码

如需更新 Wine 源代码：

1. 在原 Wine 目录更新代码
2. 重新运行本脚本同步更新
3. 或使用 Git submodule 方式管理（推荐）

## 注意事项

- Wine 使用 autotools，ReactOS 使用 CMake，需要构建系统适配
- Wine 的许可证是 LGPL，与 ReactOS 的 GPL 兼容
- 不要直接修改 `src/wine/` 下的文件，使用补丁方式
- Wine 和 ReactOS 的 API 实现可能存在差异，需要仔细评估
