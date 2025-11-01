# 符号导出/导入配置
# 处理 Windows DLL 的符号导出和导入

# 符号可见性宏定义
set(SYMBOL_EXPORT_DEFINITIONS
    -DEXPORT=__declspec(dllexport)
    -DIMPORT=__declspec(dllimport)
)

# 为 Clang 设置符号可见性
if(CMAKE_C_COMPILER_ID MATCHES "Clang")
    # Clang 支持 GCC 风格的可见性属性
    list(APPEND SYMBOL_EXPORT_DEFINITIONS
        -DVISIBLE=__attribute__((visibility("default")))
        -DHIDDEN=__attribute__((visibility("hidden")))
    )
endif()

# 辅助函数：生成 DEF 文件
function(generate_def_file target)
    cmake_parse_arguments(ARG "" "OUTPUT;LIBRARY" "EXPORTS" ${ARGN})
    
    if(NOT ARG_OUTPUT)
        set(ARG_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${target}.def")
    endif()
    
    if(NOT ARG_LIBRARY)
        set(ARG_LIBRARY ${target})
    endif()
    
    # 生成 DEF 文件内容
    set(DEF_CONTENT "LIBRARY ${ARG_LIBRARY}\n")
    set(DEF_CONTENT "${DEF_CONTENT}EXPORTS\n")
    
    foreach(export ${ARG_EXPORTS})
        set(DEF_CONTENT "${DEF_CONTENT}    ${export}\n")
    endforeach()
    
    file(WRITE ${ARG_OUTPUT} ${DEF_CONTENT})
    
    # 将 DEF 文件添加到目标
    target_sources(${target} PRIVATE ${ARG_OUTPUT})
    
    message(STATUS "Generated DEF file: ${ARG_OUTPUT}")
endfunction()

# 辅助函数：从源文件提取导出符号
function(extract_exports_from_source target source_file)
    # 读取源文件
    file(READ ${source_file} SOURCE_CONTENT)
    
    # 查找所有 __declspec(dllexport) 标记的函数
    string(REGEX MATCHALL "__declspec\\(dllexport\\)[^;]*" EXPORTS ${SOURCE_CONTENT})
    
    # 提取函数名
    set(EXPORT_LIST "")
    foreach(export ${EXPORTS})
        string(REGEX MATCH "[a-zA-Z_][a-zA-Z0-9_]*\\(" FUNC_NAME ${export})
        if(FUNC_NAME)
            string(REGEX REPLACE "\\(" "" FUNC_NAME ${FUNC_NAME})
            list(APPEND EXPORT_LIST ${FUNC_NAME})
        endif()
    endforeach()
    
    # 生成 DEF 文件
    if(EXPORT_LIST)
        generate_def_file(${target} EXPORTS ${EXPORT_LIST})
    endif()
endfunction()

# 辅助函数：设置 DLL 导出
function(set_dll_exports target)
    cmake_parse_arguments(ARG "" "DEF_FILE" "EXPORTS" ${ARGN})
    
    if(ARG_DEF_FILE)
        # 使用现有的 DEF 文件
        target_link_options(${target} PRIVATE /DEF:${ARG_DEF_FILE})
        message(STATUS "Using DEF file for ${target}: ${ARG_DEF_FILE}")
    elseif(ARG_EXPORTS)
        # 生成新的 DEF 文件
        generate_def_file(${target} EXPORTS ${ARG_EXPORTS})
    else()
        # 自动导出所有符号
        target_link_options(${target} PRIVATE /EXPORT:*)
        message(STATUS "Auto-exporting all symbols for ${target}")
    endif()
    
    # 添加符号定义
    target_compile_definitions(${target} PRIVATE ${SYMBOL_EXPORT_DEFINITIONS})
endfunction()

# 辅助函数：设置导入库
function(set_import_library target import_lib)
    target_link_options(${target} PRIVATE /IMPLIB:${import_lib})
    message(STATUS "Import library for ${target}: ${import_lib}")
endfunction()

# 辅助函数：链接导入库
function(link_import_library target import_lib)
    target_link_libraries(${target} PRIVATE ${import_lib})
endfunction()

# 辅助函数：处理循环依赖
function(handle_circular_dependencies target)
    # LLD 支持 --start-group 和 --end-group 来处理循环依赖
    # 但在 MSVC 模式下，我们使用多次链接
    cmake_parse_arguments(ARG "" "" "LIBRARIES" ${ARGN})
    
    foreach(lib ${ARG_LIBRARIES})
        target_link_libraries(${target} PRIVATE ${lib})
    endforeach()
    
    # 再次链接以解决循环依赖
    foreach(lib ${ARG_LIBRARIES})
        target_link_libraries(${target} PRIVATE ${lib})
    endforeach()
endfunction()

message(STATUS "Symbol export/import configuration loaded")

