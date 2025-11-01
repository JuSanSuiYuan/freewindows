# Environment Verification Script for Qt + Vulkan Development
# This script checks if all required tools and libraries are installed

param(
    [switch]$Detailed = $false
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Qt + Vulkan Environment Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allChecks = @()
$passedChecks = 0
$failedChecks = 0

function Test-Command {
    param(
        [string]$Name,
        [string]$Command,
        [string]$VersionArg = "--version",
        [string]$Description
    )
    
    Write-Host "Checking $Name..." -NoNewline
    
    try {
        $output = & $Command $VersionArg 2>&1
        $version = ""
        
        if ($output -match "(\d+\.\d+(\.\d+)?)") {
            $version = $matches[1]
        }
        
        Write-Host " ✓ Found" -ForegroundColor Green
        if ($version) {
            Write-Host "  Version: $version" -ForegroundColor Gray
        }
        if ($Detailed -and $output) {
            Write-Host "  Details: $($output[0])" -ForegroundColor Gray
        }
        
        $script:passedChecks++
        return @{
            Name = $Name
            Status = "Pass"
            Version = $version
            Description = $Description
        }
    }
    catch {
        Write-Host " ✗ Not found" -ForegroundColor Red
        Write-Host "  $Description" -ForegroundColor Yellow
        
        $script:failedChecks++
        return @{
            Name = $Name
            Status = "Fail"
            Version = ""
            Description = $Description
        }
    }
}

function Test-QtInstallation {
    Write-Host "Checking Qt installation..." -NoNewline
    
    # Try to find qmake
    $qmakePaths = @(
        "qmake",
        "C:\Qt\6.9.0\msvc2022_64\bin\qmake.exe",
        "C:\Qt\6.8.0\msvc2022_64\bin\qmake.exe",
        "C:\Qt\6.7.0\msvc2022_64\bin\qmake.exe"
    )
    
    foreach ($qmakePath in $qmakePaths) {
        try {
            $output = & $qmakePath -v 2>&1
            if ($output -match "Qt version (\d+\.\d+\.\d+)") {
                $version = $matches[1]
                Write-Host " ✓ Found" -ForegroundColor Green
                Write-Host "  Version: $version" -ForegroundColor Gray
                Write-Host "  Path: $qmakePath" -ForegroundColor Gray
                
                # Check Qt version
                if ($version -match "^6\.([0-9]+)") {
                    $minorVersion = [int]$matches[1]
                    if ($minorVersion -ge 9) {
                        Write-Host "  Qt version is 6.9 or later ✓" -ForegroundColor Green
                    } else {
                        Write-Host "  Warning: Qt 6.9+ recommended (found $version)" -ForegroundColor Yellow
                    }
                }
                
                $script:passedChecks++
                return @{
                    Name = "Qt"
                    Status = "Pass"
                    Version = $version
                    Path = $qmakePath
                }
            }
        }
        catch {
            continue
        }
    }
    
    Write-Host " ✗ Not found" -ForegroundColor Red
    Write-Host "  Please install Qt 6.9 or later from https://www.qt.io/download" -ForegroundColor Yellow
    
    $script:failedChecks++
    return @{
        Name = "Qt"
        Status = "Fail"
        Version = ""
    }
}

function Test-VulkanSDK {
    Write-Host "Checking Vulkan SDK..." -NoNewline
    
    # Check environment variable
    $vulkanSdk = $env:VULKAN_SDK
    
    if ($vulkanSdk) {
        Write-Host " ✓ Found" -ForegroundColor Green
        Write-Host "  Path: $vulkanSdk" -ForegroundColor Gray
        
        # Check version
        $versionFile = Join-Path $vulkanSdk "version.txt"
        if (Test-Path $versionFile) {
            $version = Get-Content $versionFile -First 1
            Write-Host "  Version: $version" -ForegroundColor Gray
        }
        
        # Check for vulkaninfo
        $vulkanInfo = Join-Path $vulkanSdk "Bin\vulkaninfo.exe"
        if (Test-Path $vulkanInfo) {
            Write-Host "  vulkaninfo.exe found ✓" -ForegroundColor Green
        }
        
        # Check for validation layers
        $layersPath = Join-Path $vulkanSdk "Bin"
        if (Test-Path $layersPath) {
            $layers = Get-ChildItem $layersPath -Filter "VkLayer*.dll"
            if ($layers.Count -gt 0) {
                Write-Host "  Validation layers found ($($layers.Count) layers) ✓" -ForegroundColor Green
            }
        }
        
        $script:passedChecks++
        return @{
            Name = "Vulkan SDK"
            Status = "Pass"
            Version = $version
            Path = $vulkanSdk
        }
    }
    else {
        Write-Host " ✗ Not found" -ForegroundColor Red
        Write-Host "  Please install Vulkan SDK 1.3+ from https://vulkan.lunarg.com/" -ForegroundColor Yellow
        Write-Host "  Set VULKAN_SDK environment variable" -ForegroundColor Yellow
        
        $script:failedChecks++
        return @{
            Name = "Vulkan SDK"
            Status = "Fail"
            Version = ""
        }
    }
}

function Test-CMake {
    $result = Test-Command -Name "CMake" -Command "cmake" -VersionArg "--version" `
        -Description "Install CMake from https://cmake.org/download/"
    return $result
}

function Test-Ninja {
    $result = Test-Command -Name "Ninja" -Command "ninja" -VersionArg "--version" `
        -Description "Install Ninja: choco install ninja or download from https://ninja-build.org/"
    return $result
}

function Test-Compiler {
    Write-Host "Checking C++ compiler..." -NoNewline
    
    # Try MSVC
    try {
        $output = & cl 2>&1
        if ($output -match "Microsoft.*C/C\+\+.*(\d+\.\d+)") {
            $version = $matches[1]
            Write-Host " ✓ Found (MSVC)" -ForegroundColor Green
            Write-Host "  Version: $version" -ForegroundColor Gray
            
            $script:passedChecks++
            return @{
                Name = "C++ Compiler"
                Status = "Pass"
                Version = $version
                Type = "MSVC"
            }
        }
    }
    catch {}
    
    # Try Clang
    try {
        $output = & clang --version 2>&1
        if ($output -match "clang version (\d+\.\d+\.\d+)") {
            $version = $matches[1]
            Write-Host " ✓ Found (Clang)" -ForegroundColor Green
            Write-Host "  Version: $version" -ForegroundColor Gray
            
            $script:passedChecks++
            return @{
                Name = "C++ Compiler"
                Status = "Pass"
                Version = $version
                Type = "Clang"
            }
        }
    }
    catch {}
    
    Write-Host " ✗ Not found" -ForegroundColor Red
    Write-Host "  Please install Visual Studio 2022 or Clang" -ForegroundColor Yellow
    
    $script:failedChecks++
    return @{
        Name = "C++ Compiler"
        Status = "Fail"
        Version = ""
    }
}

# Run all checks
Write-Host "Running environment checks..." -ForegroundColor Cyan
Write-Host ""

$allChecks += Test-QtInstallation
$allChecks += Test-VulkanSDK
$allChecks += Test-CMake
$allChecks += Test-Ninja
$allChecks += Test-Compiler

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total checks: $($passedChecks + $failedChecks)" -ForegroundColor White
Write-Host "Passed: $passedChecks" -ForegroundColor Green
Write-Host "Failed: $failedChecks" -ForegroundColor Red
Write-Host ""

if ($failedChecks -eq 0) {
    Write-Host "✓ All checks passed! Environment is ready for Qt + Vulkan development." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Configure the build:" -ForegroundColor White
    Write-Host "   cmake -B build-qt -S . -G Ninja -DCMAKE_BUILD_TYPE=Debug" -ForegroundColor Gray
    Write-Host "2. Build the project:" -ForegroundColor White
    Write-Host "   cmake --build build-qt --parallel" -ForegroundColor Gray
    exit 0
}
else {
    Write-Host "✗ Some checks failed. Please install missing components." -ForegroundColor Red
    Write-Host ""
    Write-Host "Failed checks:" -ForegroundColor Yellow
    foreach ($check in $allChecks) {
        if ($check.Status -eq "Fail") {
            Write-Host "  - $($check.Name)" -ForegroundColor Red
            if ($check.Description) {
                Write-Host "    $($check.Description)" -ForegroundColor Gray
            }
        }
    }
    exit 1
}
