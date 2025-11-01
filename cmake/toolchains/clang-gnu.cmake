# Clang-GNU Toolchain for ReactOS
# This toolchain uses Clang in GCC-compatible mode

# 设置系统信息
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR AMD64)

# 设置编译器
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_RC_COMPILER llvm-rc)

# 设置链接器
set(CMAKE_LINKER ld.lld)
set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
set(CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")

# 设置归档工具
set(CMAKE_AR llvm-ar)
set(CMAKE_RANLIB llvm-ranlib)

# 编译器标志
set(CMAKE_C_FLAGS_INIT "-Wall -Wextra -Werror=implicit-function-declaration -std=c23")
set(CMAKE_CXX_FLAGS_INIT "-Wall -Wextra -std=c++23 -fno-exceptions -fno-rtti")

# 调试标志
set(CMAKE_C_FLAGS_DEBUG_INIT "-g -O0")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "-g -O0")

# 发布标志
set(CMAKE_C_FLAGS_RELEASE_INIT "-O3 -DNDEBUG -flto")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "-O3 -DNDEBUG -flto")

# 带调试信息的发布标志
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "-O2 -g -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "-O2 -g -DNDEBUG")

# 最小大小发布标志
set(CMAKE_C_FLAGS_MINSIZEREL_INIT "-Os -DNDEBUG")
set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT "-Os -DNDEBUG")

# 链接器标志
set(CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=lld -shared")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=lld")

# 发布链接器标志（启用 LTO）
set(CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT "-flto -Wl,--gc-sections")
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE_INIT "-flto -Wl,--gc-sections")

# 启用 LTO（链接时优化）
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELWITHDEBINFO TRUE)

# 设置目标架构
add_compile_options(
    -target x86_64-pc-windows-gnu
    -march=x86-64
    -mtune=generic
)

# 设置预处理器宏
add_compile_definitions(
    _AMD64_
    _WIN64
    WIN64
    _WINDOWS
    __USE_MINGW_ANSI_STDIO=1
)

# 模拟 GCC 版本（用于兼容性）
add_compile_definitions(__GNUC__=11 __GNUC_MINOR__=0)

# Clang 特定优化选项
add_compile_options(
    # 启用优化
    -ffunction-sections
    -fdata-sections
    
    # 代码生成
    -fno-common
    -fno-strict-aliasing
    
    # 警告控制
    -Wno-unused-parameter
    -Wno-missing-field-initializers
    -Wno-sign-compare
    
    # 启用有用的警告
    -Wunused-variable
    -Wunused-function
    -Wshadow
    -Wformat-security
)

# 搜索路径
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

message(STATUS "Using Clang-GNU toolchain")
message(STATUS "  C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "  C++ Compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "  Linker: ${CMAKE_LINKER}")
