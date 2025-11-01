cmake_minimum_required(VERSION 3.20)
project(Material3Demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 查找 Qt
find_package(Qt6 COMPONENTS Core Gui Widgets QUIET)
if(NOT Qt6_FOUND)
    find_package(Qt5 COMPONENTS Core Gui Widgets REQUIRED)
endif()

# 源文件
add_executable(Material3Demo
    main.cpp
    modernwindow.h
    modernwindow.cpp
)

# 链接 Qt
if(Qt6_FOUND)
    target_link_libraries(Material3Demo
        Qt6::Core
        Qt6::Gui
        Qt6::Widgets
    )
else()
    target_link_libraries(Material3Demo
        Qt5::Core
        Qt5::Gui
        Qt5::Widgets
    )
endif()

# Windows 特定设置
if(WIN32)
    set_target_properties(Material3Demo PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
endif()
