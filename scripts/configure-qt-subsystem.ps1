# Configuration script for ReactOS Qt + Vulkan Subsystem
# This script configures the CMake build for the Qt subsystem

param(
    [ValidateSet("Debug", "Release", "RelWithDebInfo")]
    [string]$BuildType = "Debug",
    
    [string]$BuildDir = "build-qt",
    
    [ValidateSet("Ninja", "Visual Studio 17 2022", "Visual Studio 16 2019")]
    [string]$Generator = "Ninja",
    
    [switch]$Clean = $false,
    
    [switch]$SkipEnvCheck = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ReactOS Qt + Vulkan Subsystem Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check environment first
if (-not $SkipEnvCheck) {
    Write-Host "Checking environment..." -ForegroundColor Yellow
    $envCheckScript = Join-Path $PSScriptRoot "check-qt-vulkan-environment.ps1"
    
    if (Test-Path $envCheckScript) {
        & $envCheckScript
        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "Environment check failed. Please install missing components." -ForegroundColor Red
            Write-Host "Use -SkipEnvCheck to bypass this check." -ForegroundColor Yellow
            exit 1
        }
    }
    else {
        Write-Host "Warning: Environment check script not found" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Clean build directory if requested
if ($Clean -and (Test-Path $BuildDir)) {
    Write-Host "Cleaning build directory: $BuildDir" -ForegroundColor Yellow
    Remove-Item -Path $BuildDir -Recurse -Force
    Write-Host "Build directory cleaned" -ForegroundColor Green
    Write-Host ""
}

# Create build directory
if (-not (Test-Path $BuildDir)) {
    Write-Host "Creating build directory: $BuildDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
}

# Configure CMake
Write-Host "Configuring CMake..." -ForegroundColor Yellow
Write-Host "  Build type: $BuildType" -ForegroundColor Gray
Write-Host "  Generator: $Generator" -ForegroundColor Gray
Write-Host "  Build directory: $BuildDir" -ForegroundColor Gray
Write-Host ""

$cmakeArgs = @(
    "-B", $BuildDir,
    "-S", ".",
    "-G", $Generator,
    "-DCMAKE_BUILD_TYPE=$BuildType",
    "-DBUILD_TESTING=ON"
)

# Use the Qt-specific CMakeLists.txt
$cmakeListsQt = "CMakeLists_Qt.txt"
if (Test-Path $cmakeListsQt) {
    # Copy to CMakeLists.txt temporarily
    $originalCMake = "CMakeLists.txt"
    $backupCMake = "CMakeLists.txt.backup"
    
    if (Test-Path $originalCMake) {
        Write-Host "Backing up original CMakeLists.txt" -ForegroundColor Yellow
        Copy-Item $originalCMake $backupCMake -Force
    }
    
    Write-Host "Using Qt-specific CMakeLists.txt" -ForegroundColor Yellow
    Copy-Item $cmakeListsQt $originalCMake -Force
}

try {
    $output = & cmake @cmakeArgs 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ Configuration successful!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "1. Build the project:" -ForegroundColor White
        Write-Host "   cmake --build $BuildDir --parallel" -ForegroundColor Gray
        Write-Host "2. Run tests:" -ForegroundColor White
        Write-Host "   cd $BuildDir && ctest" -ForegroundColor Gray
        Write-Host ""
        
        # Show configuration summary
        Write-Host "Configuration summary:" -ForegroundColor Cyan
        $output | Select-String "Qt version|Vulkan version|Build type|Build Explorer|Build Taskbar" | ForEach-Object {
            Write-Host "  $_" -ForegroundColor Gray
        }
    }
    else {
        Write-Host ""
        Write-Host "✗ Configuration failed!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Error output:" -ForegroundColor Yellow
        $output | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        exit 1
    }
}
finally {
    # Restore original CMakeLists.txt if we backed it up
    if (Test-Path $backupCMake) {
        Write-Host "Restoring original CMakeLists.txt" -ForegroundColor Yellow
        Move-Item $backupCMake $originalCMake -Force
    }
}
