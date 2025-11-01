# LLD 链接器配置
# 为 ReactOS 优化的 LLD-Link 配置

message(STATUS "Configuring LLD linker for ReactOS")

# 确保使用 LLD
set(CMAKE_LINKER "lld-link" CACHE STRING "Linker" FORCE)
set(CMAKE_C_LINK_EXECUTABLE_LINKER "lld-link")
set(CMAKE_CXX_LINK_EXECUTABLE_LINKER "lld-link")

# LLD 基础选项
set(LLD_BASE_FLAGS
    /MACHINE:X64                    # 64位目标
    /NOLOGO                         # 不显示版本信息
    /INCREMENTAL:NO                 # 禁用增量链接（更快）
    /OPT:REF                        # 移除未引用的函数
    /OPT:ICF                        # 合并相同的函数（减小体积）
)

# LLD 调试选项
set(LLD_DEBUG_FLAGS
    /DEBUG:FULL                     # 完整调试信息
    /DEBUGTYPE:CV                   # CodeView 调试格式
    /PDB:<TARGET_PDB>               # PDB 文件路径
)

# LLD 发布选项
set(LLD_RELEASE_FLAGS
    /LTCG                           # 链接时代码生成（LTO）
    /OPT:REF                        # 移除未引用代码
    /OPT:ICF                        # 合并相同代码
)

# LLD 性能优化
set(LLD_PERFORMANCE_FLAGS
    /threads:8                      # 使用 8 个线程
    /time                           # 显示链接时间
)

# 符号导出/导入配置
set(LLD_SYMBOL_FLAGS
    /EXPORT:*                       # 导出所有符号（根据需要调整）
    /IMPLIB:<TARGET_IMPLIB>         # 生成导入库
)

# DLL 特定选项
set(LLD_DLL_FLAGS
    /DLL                            # 生成 DLL
    /SUBSYSTEM:WINDOWS              # Windows 子系统
    /DYNAMICBASE                    # 地址空间布局随机化（ASLR）
    /NXCOMPAT                       # 数据执行保护（DEP）
)

# 驱动程序特定选项
set(LLD_DRIVER_FLAGS
    /SUBSYSTEM:NATIVE               # 原生子系统（内核模式）
    /DRIVER                         # 驱动程序
    /ENTRY:DriverEntry              # 入口点
    /NODEFAULTLIB                   # 不链接默认库
)

# 内核特定选项
set(LLD_KERNEL_FLAGS
    /SUBSYSTEM:NATIVE               # 原生子系统
    /ENTRY:KiSystemStartup          # 内核入口点
    /BASE:0x80000000                # 内核基地址
    /FIXED                          # 固定基地址
    /NODEFAULTLIB                   # 不链接默认库
)

# 应用程序特定选项
set(LLD_APP_FLAGS
    /SUBSYSTEM:WINDOWS              # Windows 子系统
    /ENTRY:mainCRTStartup           # 入口点
)

# 根据构建类型设置链接标志
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LLD_BASE_FLAGS} ${LLD_DEBUG_FLAGS}")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${LLD_BASE_FLAGS} ${LLD_DEBUG_FLAGS} ${LLD_DLL_FLAGS}")
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LLD_BASE_FLAGS} ${LLD_RELEASE_FLAGS}")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${LLD_BASE_FLAGS} ${LLD_RELEASE_FLAGS} ${LLD_DLL_FLAGS}")
endif()

# 添加性能优化标志
if(ENABLE_LLD_PERFORMANCE)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LLD_PERFORMANCE_FLAGS}")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${LLD_PERFORMANCE_FLAGS}")
endif()

# 辅助函数：为目标设置链接器选项
function(set_lld_linker_options target)
    cmake_parse_arguments(ARG "DLL;DRIVER;KERNEL;APP" "" "" ${ARGN})
    
    if(ARG_DLL)
        target_link_options(${target} PRIVATE ${LLD_DLL_FLAGS})
    elseif(ARG_DRIVER)
        target_link_options(${target} PRIVATE ${LLD_DRIVER_FLAGS})
    elseif(ARG_KERNEL)
        target_link_options(${target} PRIVATE ${LLD_KERNEL_FLAGS})
    elseif(ARG_APP)
        target_link_options(${target} PRIVATE ${LLD_APP_FLAGS})
    endif()
endfunction()

# 辅助函数：设置符号导出
function(set_symbol_export target def_file)
    target_link_options(${target} PRIVATE /DEF:${def_file})
endfunction()

message(STATUS "LLD linker configuration complete")
message(STATUS "  Base flags: ${LLD_BASE_FLAGS}")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")

