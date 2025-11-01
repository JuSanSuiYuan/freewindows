# Qt + Vulkan Installation Guide

This guide provides step-by-step instructions for installing all required components for ReactOS Qt + Vulkan development.

## Installation Checklist

- [ ] Qt 6.9 or later
- [ ] Vulkan SDK 1.3 or later
- [ ] CMake 3.20 or later
- [ ] Ninja Build System
- [ ] C++ Compiler (MSVC or Clang)

## 1. Install Qt 6.9+

### Option A: Qt Online Installer (Recommended)

1. Download Qt Online Installer:
   - Visit: https://www.qt.io/download
   - Click "Download the Qt Online Installer"

2. Run the installer:
   - Sign in or create a Qt account (free)
   - Select "Custom Installation"

3. Select components:
   - ✅ Qt 6.9.0 (or latest)
     - ✅ MSVC 2022 64-bit
     - ✅ Qt Quick
     - ✅ Qt 5 Compatibility Module
   - ✅ Developer and Designer Tools
     - ✅ Qt Creator
     - ✅ CMake
     - ✅ Ninja

4. Installation path:
   - Default: `C:\Qt\6.9.0`
   - Remember this path for later

5. Add to PATH:
   ```powershell
   # Add Qt bin directory to PATH
   $qtPath = "C:\Qt\6.9.0\msvc2022_64\bin"
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$qtPath", "User")
   ```

6. Verify installation:
   ```powershell
   qmake -v
   # Should output: Qt version 6.9.0
   ```

### Option B: Qt Maintenance Tool

If you already have Qt installed:

1. Run Qt Maintenance Tool
2. Select "Add or remove components"
3. Ensure Qt 6.9+ is installed with required modules

## 2. Install Vulkan SDK 1.3+

1. Download Vulkan SDK:
   - Visit: https://vulkan.lunarg.com/
   - Download latest SDK for Windows (1.3.xxx or later)

2. Run the installer:
   - Accept license agreement
   - Choose installation directory (default: `C:\VulkanSDK\1.3.xxx.x`)
   - Select all components:
     - ✅ Vulkan Runtime
     - ✅ Vulkan SDK Core
     - ✅ Vulkan Validation Layers
     - ✅ Vulkan Tools (vulkaninfo, etc.)

3. Set environment variable:
   ```powershell
   # The installer should set this automatically
   # If not, set it manually:
   $vulkanPath = "C:\VulkanSDK\1.3.xxx.x"
   [Environment]::SetEnvironmentVariable("VULKAN_SDK", $vulkanPath, "User")
   ```

4. Verify installation:
   ```powershell
   $env:VULKAN_SDK
   # Should output: C:\VulkanSDK\1.3.xxx.x
   
   vulkaninfo
   # Should display Vulkan device information
   ```

## 3. Install CMake 3.20+

### Option A: Via Qt Installer

If you installed Qt with the online installer and selected CMake, it's already installed.

### Option B: Standalone Installation

1. Download CMake:
   - Visit: https://cmake.org/download/
   - Download "Windows x64 Installer"

2. Run the installer:
   - Select "Add CMake to system PATH for all users"

3. Verify installation:
   ```powershell
   cmake --version
   # Should output: cmake version 3.xx.x
   ```

### Option C: Via Chocolatey

```powershell
choco install cmake
```

## 4. Install Ninja Build System

### Option A: Via Qt Installer

If you installed Qt with the online installer and selected Ninja, it's already installed.

### Option B: Via Chocolatey (Recommended)

```powershell
choco install ninja
```

### Option C: Manual Installation

1. Download Ninja:
   - Visit: https://ninja-build.org/
   - Download `ninja-win.zip`

2. Extract to a directory (e.g., `C:\Tools\ninja`)

3. Add to PATH:
   ```powershell
   $ninjaPath = "C:\Tools\ninja"
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$ninjaPath", "User")
   ```

4. Verify installation:
   ```powershell
   ninja --version
   # Should output: 1.xx.x
   ```

## 5. Install C++ Compiler

### Option A: Visual Studio 2022 (Recommended)

1. Download Visual Studio 2022:
   - Visit: https://visualstudio.microsoft.com/downloads/
   - Download "Community" edition (free)

2. Run the installer:
   - Select "Desktop development with C++"
   - Ensure these are checked:
     - ✅ MSVC v143 - VS 2022 C++ x64/x86 build tools
     - ✅ Windows 10/11 SDK
     - ✅ C++ CMake tools for Windows

3. Verify installation:
   ```powershell
   # Open "Developer Command Prompt for VS 2022"
   cl
   # Should display Microsoft C/C++ Compiler version
   ```

### Option B: Clang with MSVC Compatibility

1. Download LLVM:
   - Visit: https://github.com/llvm/llvm-project/releases
   - Download `LLVM-xx.x.x-win64.exe`

2. Run the installer:
   - Select "Add LLVM to system PATH"

3. Verify installation:
   ```powershell
   clang --version
   # Should output: clang version xx.x.x
   ```

## 6. Verify Complete Installation

Run the environment verification script:

```powershell
.\scripts\check-qt-vulkan-environment.ps1
```

Expected output:
```
========================================
Qt + Vulkan Environment Verification
========================================

Checking Qt installation... ✓ Found
  Version: 6.9.0
Checking Vulkan SDK... ✓ Found
  Version: 1.3.xxx.x
Checking CMake... ✓ Found
  Version: 3.xx.x
Checking Ninja... ✓ Found
  Version: 1.xx.x
Checking C++ compiler... ✓ Found (MSVC)
  Version: 19.xx

========================================
Summary
========================================
Total checks: 5
Passed: 5
Failed: 0

✓ All checks passed! Environment is ready for Qt + Vulkan development.
```

## Troubleshooting

### Qt not found after installation

1. Check if qmake is in PATH:
   ```powershell
   where.exe qmake
   ```

2. If not found, add Qt bin directory to PATH manually:
   ```powershell
   $qtPath = "C:\Qt\6.9.0\msvc2022_64\bin"
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$qtPath", "User")
   ```

3. Restart PowerShell and try again

### Vulkan SDK not detected

1. Check if VULKAN_SDK is set:
   ```powershell
   $env:VULKAN_SDK
   ```

2. If not set, set it manually:
   ```powershell
   $vulkanPath = "C:\VulkanSDK\1.3.xxx.x"
   [Environment]::SetEnvironmentVariable("VULKAN_SDK", $vulkanPath, "User")
   ```

3. Restart PowerShell and try again

### CMake not found

1. Check if CMake is in PATH:
   ```powershell
   where.exe cmake
   ```

2. If not found, reinstall CMake and ensure "Add to PATH" is selected

### Compiler not found

For MSVC:
1. Open "Developer Command Prompt for VS 2022"
2. Run the verification script from there

For Clang:
1. Ensure LLVM is in PATH
2. Restart PowerShell

### Permission errors

Run PowerShell as Administrator when setting environment variables.

## Next Steps

After successful installation:

1. Configure the build:
   ```powershell
   .\scripts\configure-qt-subsystem.ps1
   ```

2. Build the project:
   ```powershell
   cmake --build build-qt --parallel
   ```

3. Start developing!

## Additional Resources

- Qt Documentation: https://doc.qt.io/
- Vulkan Tutorial: https://vulkan-tutorial.com/
- CMake Documentation: https://cmake.org/documentation/
- ReactOS Qt Migration Spec: `.kiro/specs/qt-vulkan-migration/`

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Run the environment verification script with `-Detailed` flag
3. Review the error messages carefully
4. Consult the Qt and Vulkan documentation

## Estimated Installation Time

- Qt: 30-60 minutes (depending on internet speed)
- Vulkan SDK: 10-15 minutes
- CMake: 5 minutes
- Ninja: 2 minutes
- Visual Studio: 30-60 minutes

Total: ~1.5-2.5 hours
