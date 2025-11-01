# Qt Framework Library
# Core framework for ReactOS Qt applications

add_library(ReactOSFramework SHARED
    # Will be populated in task 2
    # ReactOSApplication.cpp
    # ModernWindow.cpp
    # ThemeManager.cpp
    # VulkanWindow.cpp
    # VulkanRenderer.cpp
)

target_link_libraries(ReactOSFramework
    PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::Widgets
        Vulkan::Vulkan
)

target_include_directories(ReactOSFramework
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

# Export symbols for Windows DLL
target_compile_definitions(ReactOSFramework
    PRIVATE
        REACTOS_FRAMEWORK_LIBRARY
)

install(TARGETS ReactOSFramework
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
