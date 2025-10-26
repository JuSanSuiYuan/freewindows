# ReactOS Clang-CL Toolchain
# 专门为 ReactOS 优化的 Clang-CL 工具链配置

# 设置编译器
set(CMAKE_C_COMPILER clang-cl CACHE STRING "C compiler")
set(CMAKE_CXX_COMPILER clang-cl CACHE STRING "C++ compiler")
set(CMAKE_ASM_MASM_COMPILER clang-cl CACHE STRING "ASM compiler")
set(CMAKE_RC_COMPILER llvm-rc CACHE STRING "Resource compiler")

# 设置链接器
set(CMAKE_LINKER lld-link CACHE STRING "Linker")

# 设置归档工具
set(CMAKE_AR llvm-lib CACHE STRING "Archiver")

# 告诉 CMake 这是 MSVC 兼容的编译器
set(MSVC 1)
set(CMAKE_C_COMPILER_ID "Clang" CACHE STRING "C compiler ID")
set(CMAKE_CXX_COMPILER_ID "Clang" CACHE STRING "C++ compiler ID")

# 设置编译器前端为 MSVC 模式
set(CMAKE_C_COMPILER_FRONTEND_VARIANT "MSVC" CACHE STRING "")
set(CMAKE_CXX_COMPILER_FRONTEND_VARIANT "MSVC" CACHE STRING "")

message(STATUS "Using ReactOS Clang-CL toolchain")
message(STATUS "  C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "  C++ Compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "  Linker: ${CMAKE_LINKER}")
