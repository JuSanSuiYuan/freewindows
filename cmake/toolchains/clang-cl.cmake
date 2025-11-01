# Clang-CL Toolchain for ReactOS
# This toolchain uses Clang in MSVC-compatible mode (clang-cl)

# 设置系统信息
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR AMD64)

# 设置编译器
set(CMAKE_C_COMPILER clang-cl)
set(CMAKE_CXX_COMPILER clang-cl)
set(CMAKE_RC_COMPILER llvm-rc)
set(CMAKE_MT llvm-mt)

# 设置链接器
set(CMAKE_LINKER lld-link)
set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_LINKER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> /out:<TARGET> <LINK_LIBRARIES>")
set(CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_LINKER> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> /out:<TARGET> <LINK_LIBRARIES>")

# 设置归档工具
set(CMAKE_AR llvm-ar)
set(CMAKE_RANLIB llvm-ranlib)

# 编译器标志
set(CMAKE_C_FLAGS_INIT "/W4 /WX- /nologo /std:c23")
set(CMAKE_CXX_FLAGS_INIT "/W4 /WX- /nologo /std:c++23 /EHsc")

# 调试标志
set(CMAKE_C_FLAGS_DEBUG_INIT "/Od /Zi /RTC1 /MDd")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "/Od /Zi /RTC1 /MDd")

# 发布标志
set(CMAKE_C_FLAGS_RELEASE_INIT "/O2 /Oi /GL /MD /DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "/O2 /Oi /GL /MD /DNDEBUG")

# 带调试信息的发布标志
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "/O2 /Oi /Zi /MD /DNDEBUG")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "/O2 /Oi /Zi /MD /DNDEBUG")

# 最小大小发布标志
set(CMAKE_C_FLAGS_MINSIZEREL_INIT "/O1 /MD /DNDEBUG")
set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT "/O1 /MD /DNDEBUG")

# 链接器标志
set(CMAKE_EXE_LINKER_FLAGS_INIT "/MACHINE:X64 /NOLOGO")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "/MACHINE:X64 /NOLOGO /DLL")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "/MACHINE:X64 /NOLOGO")

# 调试链接器标志
set(CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT "/DEBUG")
set(CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT "/DEBUG")

# 发布链接器标志（启用 LTCG）
set(CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT "/LTCG /OPT:REF /OPT:ICF")
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE_INIT "/LTCG /OPT:REF /OPT:ICF")

# Clang 特定优化
# 启用 LTO（链接时优化）
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELWITHDEBINFO TRUE)

# 设置目标架构
add_compile_definitions(
    _AMD64_
    _WIN64
    WIN64
    _WINDOWS
)

# 模拟 MSVC 版本（用于兼容性）
# MSVC 2022 = 1930
add_compile_definitions(_MSC_VER=1930)

# Clang 特定警告控制
add_compile_options(
    # 禁用某些过于严格的警告
    -Wno-microsoft-enum-value
    -Wno-microsoft-anon-tag
    -Wno-ignored-attributes
    
    # 启用有用的警告
    -Wunused-variable
    -Wunused-function
    -Wshadow
)

# 搜索路径
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

message(STATUS "Using Clang-CL toolchain")
message(STATUS "  C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "  C++ Compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "  Linker: ${CMAKE_LINKER}")
