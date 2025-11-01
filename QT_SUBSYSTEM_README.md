# ReactOS Qt + Vulkan Subsystem

This directory contains the Qt + Vulkan subsystem for ReactOS, providing modern UI components and high-performance 3D graphics.

## Prerequisites

### Required Software

1. **Qt 6.9 or later**
   - Download from: https://www.qt.io/download
   - Required modules: Core, Gui, Widgets, Quick
   - Recommended: Qt Creator IDE

2. **Vulkan SDK 1.3 or later**
   - Download from: https://vulkan.lunarg.com/
   - Includes validation layers and tools
   - Set `VULKAN_SDK` environment variable

3. **CMake 3.20 or later**
   - Download from: https://cmake.org/download/

4. **Ninja Build System**
   - Install via: `choco install ninja`
   - Or download from: https://ninja-build.org/

5. **C++ Compiler**
   - Visual Studio 2022 (MSVC) or
   - Clang 14+ with MSVC compatibility

## Quick Start

### 1. Verify Environment

Check if all required tools are installed:

```powershell
.\scripts\check-qt-vulkan-environment.ps1
```

For detailed output:

```powershell
.\scripts\check-qt-vulkan-environment.ps1 -Detailed
```

### 2. Configure Build

Configure the project with default settings (Debug build, Ninja generator):

```powershell
.\scripts\configure-qt-subsystem.ps1
```

Configure for Release build:

```powershell
.\scripts\configure-qt-subsystem.ps1 -BuildType Release
```

Clean and reconfigure:

```powershell
.\scripts\configure-qt-subsystem.ps1 -Clean
```

### 3. Build

Build all components:

```powershell
cmake --build build-qt --parallel
```

Build specific component:

```powershell
cmake --build build-qt --target ReactOSFramework
```

### 4. Run Tests

```powershell
cd build-qt
ctest
```

## Project Structure

```
.
├── CMakeLists_Qt.txt              # Root CMake configuration
├── src/
│   ├── qt_framework/              # Core Qt framework
│   │   ├── ReactOSApplication.*   # Application base class
│   │   ├── ModernWindow.*         # Modern window system
│   │   ├── ThemeManager.*         # Theme management
│   │   ├── VulkanWindow.*         # Vulkan window
│   │   └── VulkanRenderer.*       # Vulkan renderer
│   ├── explorer/                  # Qt Explorer (file manager)
│   ├── taskbar/                   # Qt Taskbar
│   ├── control_panel/             # Qt Control Panel
│   ├── settings/                  # Qt System Settings
│   └── apps/                      # Qt Applications
│       ├── notepad/               # Qt Notepad
│       ├── paint/                 # Qt Paint
│       ├── calculator/            # Qt Calculator
│       └── taskmanager/           # Qt Task Manager
├── tests/                         # Unit and integration tests
└── scripts/                       # Build and utility scripts
    ├── check-qt-vulkan-environment.ps1
    └── configure-qt-subsystem.ps1
```

## Development Workflow

### Phase 1: Core Framework (Current)

1. ✅ Environment setup
2. ⏳ Implement ReactOSApplication
3. ⏳ Implement ModernWindow
4. ⏳ Implement VulkanWindow
5. ⏳ Create theme system

### Phase 2: System Components

1. Migrate File Explorer
2. Migrate Taskbar
3. Migrate Control Panel
4. Migrate System Settings

### Phase 3: Applications

1. Migrate Notepad
2. Migrate Paint
3. Migrate Calculator
4. Migrate Task Manager

## Build Options

Configure build options using CMake variables:

```powershell
# Disable specific components
cmake -B build-qt -DBUILD_EXPLORER=OFF -DBUILD_TASKBAR=OFF

# Disable testing
cmake -B build-qt -DBUILD_TESTING=OFF

# Disable all applications
cmake -B build-qt -DBUILD_APPS=OFF
```

## Troubleshooting

### Qt not found

Ensure Qt is installed and qmake is in your PATH:

```powershell
qmake -v
```

If not found, add Qt bin directory to PATH:

```powershell
$env:PATH += ";C:\Qt\6.9.0\msvc2022_64\bin"
```

### Vulkan SDK not found

Set the VULKAN_SDK environment variable:

```powershell
$env:VULKAN_SDK = "C:\VulkanSDK\1.3.xxx.x"
```

### CMake configuration fails

1. Check environment with: `.\scripts\check-qt-vulkan-environment.ps1`
2. Ensure all prerequisites are installed
3. Try cleaning the build directory: `.\scripts\configure-qt-subsystem.ps1 -Clean`

### Build fails

1. Check compiler is in PATH
2. Ensure Qt and Vulkan are properly configured
3. Check CMake output for specific errors

## Documentation

- [Requirements](../.kiro/specs/qt-vulkan-migration/requirements.md)
- [Design](../.kiro/specs/qt-vulkan-migration/design.md)
- [Tasks](../.kiro/specs/qt-vulkan-migration/tasks.md)

## Contributing

This is part of the ReactOS Qt + Vulkan migration project. See the spec files in `.kiro/specs/qt-vulkan-migration/` for detailed requirements and design.

## License

This project follows the ReactOS licensing model. See LICENSE files for details.
