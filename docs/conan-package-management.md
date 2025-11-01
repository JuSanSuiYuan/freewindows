# Conan 包管理器使用指南

## 概述

FreeWindows 项目使用 **Conan** 作为主要的包管理器来管理项目的外部依赖关系。Conan 是一个去中心化的开源包管理器，专为 C/C++ 项目设计。

## 为什么选择 Conan？

1. **去中心化**: 没有单一的中央仓库，可以从多个来源获取包
2. **二进制管理**: 支持预编译的二进制包，加快构建速度
3. **跨平台**: 支持 Windows、Linux、macOS 等多种平台
4. **与 CMake 集成**: 与项目现有的 CMake 构建系统无缝集成
5. **灵活的依赖管理**: 支持复杂的依赖关系和版本控制

## 安装 Conan

### Windows

#### 使用 Chocolatey（推荐）
```powershell
choco install conan
```

#### 使用 pip
```powershell
pip install conan
```

#### 从官网下载
访问 [Conan 下载页面](https://conan.io/downloads.html) 下载安装程序。

### 验证安装
```powershell
conan --version
```

## Conan 配置

### 初始化配置
首次使用 Conan 时，需要进行初始化配置：
```powershell
conan profile detect --force
```

### 配置默认配置文件
Conan 会自动创建默认配置文件，通常位于：
- Windows: `C:\Users\<用户名>\.conan2\profiles\default`

## 项目结构

```
freeWindows/
├── conanfile.py      # Conan 配方文件（Python 格式）
├── conanfile.txt     # Conan 配方文件（文本格式）
├── scripts/
│   └── build-with-conan.ps1  # 使用 Conan 的构建脚本
└── build-conan/      # Conan 构建输出目录
```

## 使用 Conan 管理依赖

### 添加依赖
在 `conanfile.txt` 中添加依赖：
```ini
[requires]
zlib/1.2.11
openssl/1.1.1k

[generators]
CMakeDeps
CMakeToolchain
```

### 安装依赖
```powershell
# 在项目根目录下执行
conan install . --build=missing
```

### 构建项目
```powershell
# 使用提供的 PowerShell 脚本
.\scripts\build-with-conan.ps1
```

## Conan 配方文件

### conanfile.py
Python 格式的配方文件，提供更强大的功能：
```python
from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake, cmake_layout

class FreeWindowsConan(ConanFile):
    name = "freeWindows"
    version = "1.0.0"
    
    # 设置
    settings = "os", "compiler", "build_type", "arch"
    
    # 导出源代码
    exports_sources = "CMakeLists.txt", "src/*", "cmake/*"
    
    def layout(self):
        cmake_layout(self)
        
    def generate(self):
        tc = CMakeToolchain(self)
        tc.generate()
        
    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
        
    def requirements(self):
        # 添加依赖
        pass
```

### conanfile.txt
简单的文本格式配方文件：
```ini
[requires]
# 依赖列表

[generators]
# 生成器列表

[options]
# 选项列表
```

## 构建流程

使用 Conan 的完整构建流程：

1. **安装依赖**:
   ```powershell
   conan install . --build=missing
   ```

2. **激活环境**:
   ```powershell
   # Windows (PowerShell)
   . ./conanbuild.ps1
   ```

3. **配置和构建**:
   ```powershell
   cmake --preset conan-release  # 或 conan-debug
   cmake --build --preset conan-release
   ```

4. **清理环境**:
   ```powershell
   # Windows (PowerShell)
   . ./conanbuild.ps1 --unset
   ```

## 最佳实践

### 1. 依赖版本管理
- 使用具体版本号而不是范围
- 定期更新依赖以获取安全修复

### 2. 配置管理
- 使用不同的配置文件管理不同环境（开发、测试、生产）
- 为不同架构和编译器创建特定配置

### 3. 包缓存
- 利用 Conan 的本地缓存避免重复下载
- 定期清理不需要的包以节省磁盘空间

### 4. 二进制包管理
- 优先使用预编译的二进制包
- 仅为特定平台构建必要的包

## 常见问题

### Q1: 如何添加新的依赖？
在 `conanfile.txt` 的 `[requires]` 部分添加依赖，然后运行：
```powershell
conan install . --build=missing
```

### Q2: 如何更新依赖？
```powershell
conan install . --update --build=missing
```

### Q3: 如何清理构建？
```powershell
# 清理 Conan 构建目录
rm -rf build-conan/
# 或使用脚本
.\scripts\build-with-conan.ps1 -Clean
```

### Q4: 如何查看已安装的包？
```powershell
conan list "*"
```

## 参考资源

- [Conan 官方文档](https://docs.conan.io/)
- [Conan 中心仓库](https://conan.io/center/)
- [Conan GitHub 仓库](https://github.com/conan-io/conan)

---

**文档版本**: 1.0  
**最后更新**: 2025-10-26  
**作者**: FreeWindows 项目组