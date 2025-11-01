# Design Document: LLD Linker Configuration for ReactOS

## Overview

This design document describes the architecture and implementation approach for integrating the LLD (LLVM Linker) into the FreeWindows/ReactOS build system. The design focuses on creating a robust, maintainable linker configuration that supports both MSVC-compatible (lld-link) and GNU-compatible (ld.lld) linking modes while maintaining full compatibility with ReactOS's existing build infrastructure.

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    FreeWindows Build System                  │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐         ┌──────────────┐                  │
│  │   CMake      │────────▶│  Toolchain   │                  │
│  │ Configuration│         │    Files     │                  │
│  └──────────────┘         └──────┬───────┘                  │
│                                   │                          │
│                                   ▼                          │
│                          ┌────────────────┐                  │
│                          │ LLD Linker     │                  │
│                          │ Configuration  │                  │
│                          └────────┬───────┘                  │
│                                   │                          │
│                    ┌──────────────┴──────────────┐           │
│                    │                             │           │
│                    ▼                             ▼           │
│           ┌────────────────┐          ┌────────────────┐    │
│           │   lld-link     │          │    ld.lld      │    │
│           │ (MSVC mode)    │          │  (GNU mode)    │    │
│           └────────┬───────┘          └────────┬───────┘    │
│                    │                           │             │
│                    └───────────┬───────────────┘             │
│                                │                             │
│                                ▼                             │
│                    ┌───────────────────────┐                 │
│                    │  Symbol Management    │                 │
│                    │  - Export Tables      │                 │
│                    │  - Import Libraries   │                 │
│                    │  - DEF Files          │                 │
│                    └───────────┬───────────┘                 │
│                                │                             │
│                                ▼                             │
│                    ┌───────────────────────┐                 │
│                    │   PE Binary Output    │                 │
│                    │  - EXE / DLL / SYS    │                 │
│                    │  - Debug Info (PDB)   │                 │
│                    └───────────────────────┘                 │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Components and Interfaces

### 1. Linker Detection Module

**Purpose:** Detect and validate LLD linker availability

**Location:** `cmake/modules/FindLLD.cmake`

**Interface:**
```cmake
# Input Variables:
#   - CMAKE_C_COMPILER_ID
#   - CMAKE_CXX_COMPILER_ID
#
# Output Variables:
#   - LLD_LINK_EXECUTABLE (path to lld-link)
#   - LD_LLD_EXECUTABLE (path to ld.lld)
#   - LLD_VERSION (detected version)
#   - LLD_FOUND (boolean)
#
# Functions:
#   - find_lld_linker()
#   - validate_lld_version()
```

**Key Features:**
- Auto-detect LLD from LLVM installation
- Validate minimum version (10.0.0+)
- Provide fallback error messages
- Support cross-platform detection

---

### 2. Linker Configuration Module

**Purpose:** Configure LLD with appropriate flags for ReactOS

**Location:** `cmake/modules/ConfigureLLD.cmake`

**Interface:**
```cmake
# Functions:
#   - configure_lld_for_msvc_mode()
#   - configure_lld_for_gnu_mode()
#   - set_lld_optimization_flags()
#   - set_lld_debug_flags()
#
# Macros:
#   - add_lld_link_options(target options...)
#   - set_lld_subsystem(target subsystem)
```

**Configuration Options:**

**MSVC Mode (lld-link):**
```cmake
/MACHINE:X64              # Target architecture
/SUBSYSTEM:CONSOLE        # Subsystem type
/ENTRY:mainCRTStartup     # Entry point
/DEBUG                    # Generate PDB
/OPT:REF                  # Remove unreferenced code
/OPT:ICF                  # Identical COMDAT folding
/LTCG                     # Link-time code generation
/MANIFEST:NO              # Disable manifest
/INCREMENTAL:NO           # Disable incremental linking
```

**GNU Mode (ld.lld):**
```cmake
-m i386pep                # Target emulation (64-bit)
--subsystem console       # Subsystem type
-e _mainCRTStartup        # Entry point
--gc-sections             # Remove unused sections
--icf=all                 # Identical code folding
--lto-O2                  # LTO optimization level
--build-id                # Generate build ID
```

---

### 3. Symbol Export/Import Handler

**Purpose:** Manage DLL symbol exports and imports

**Location:** `cmake/modules/SymbolManagement.cmake`

**Interface:**
```cmake
# Functions:
#   - add_dll_exports(target def_file)
#   - generate_import_library(target)
#   - add_delay_load_dll(target dll_name)
#   - set_export_all_symbols(target)
#
# Variables:
#   - EXPORT_DEF_FILE
#   - IMPORT_LIBRARY_OUTPUT
```

**Export Mechanisms:**

1. **DEF File Method:**
```cmake
add_dll_exports(mylib mylib.def)
# Generates: /DEF:mylib.def (MSVC mode)
#           --output-def mylib.def (GNU mode)
```

2. **__declspec Method:**
```cmake
target_compile_definitions(mylib PRIVATE MYLIB_EXPORTS)
# In code: __declspec(dllexport) void MyFunction();
```

3. **Import Library Generation:**
```cmake
generate_import_library(mylib)
# Output: mylib.lib (MSVC) or libmylib.dll.a (GNU)
```

---

### 4. PE Format Configuration

**Purpose:** Configure PE-specific binary properties

**Location:** `cmake/modules/PEConfiguration.cmake`

**Interface:**
```cmake
# Functions:
#   - set_pe_subsystem(target subsystem)
#   - set_pe_base_address(target address)
#   - set_pe_stack_size(target size)
#   - set_pe_heap_size(target size)
#   - add_pe_section(target name flags)
#
# Subsystems:
#   - CONSOLE, WINDOWS, NATIVE, POSIX, EFI_APPLICATION
```

**Example Usage:**
```cmake
# Kernel driver
set_pe_subsystem(ntoskrnl NATIVE)
set_pe_base_address(ntoskrnl 0x80000000)

# GUI application
set_pe_subsystem(explorer WINDOWS)
set_pe_stack_size(explorer 1048576)  # 1MB
```

---

### 5. Linker Script Manager

**Purpose:** Manage custom linker scripts for kernel/drivers

**Location:** `cmake/modules/LinkerScripts.cmake`

**Interface:**
```cmake
# Functions:
#   - add_linker_script(target script_file)
#   - generate_memory_map(target)
#   - set_section_alignment(target section alignment)
```

**Linker Script Template:**
```ld
/* ReactOS Kernel Linker Script */
SECTIONS
{
    . = 0x80000000;
    
    .text : {
        *(.text .text.*)
        *(.rodata .rodata.*)
    }
    
    .data : {
        *(.data .data.*)
    }
    
    .bss : {
        *(.bss .bss.*)
        *(COMMON)
    }
    
    /DISCARD/ : {
        *(.note.*)
        *(.comment)
    }
}
```

---

### 6. Build Integration Layer

**Purpose:** Integrate LLD into existing ReactOS build system

**Location:** `cmake/toolchains/reactos-clang-cl-lld.cmake`

**Key Integration Points:**

1. **Toolchain File Updates:**
```cmake
# Set linker
set(CMAKE_LINKER lld-link)
set(CMAKE_C_LINK_EXECUTABLE 
    "<CMAKE_LINKER> <FLAGS> <LINK_FLAGS> <OBJECTS> /out:<TARGET> <LINK_LIBRARIES>")

# Import LLD modules
include(FindLLD)
include(ConfigureLLD)
include(SymbolManagement)
include(PEConfiguration)
```

2. **Target-Specific Configuration:**
```cmake
# For each ReactOS component
add_library(ntdll SHARED ${SOURCES})
add_dll_exports(ntdll ntdll.def)
set_pe_subsystem(ntdll NATIVE)
target_link_options(ntdll PRIVATE /BASE:0x77000000)
```

---

## Data Models

### 1. Linker Configuration Data

```cmake
# Global linker settings
set(LLD_GLOBAL_FLAGS
    /NOLOGO
    /NXCOMPAT
    /DYNAMICBASE
    /MANIFEST:NO
)

# Per-configuration flags
set(LLD_DEBUG_FLAGS
    /DEBUG:FULL
    /INCREMENTAL:NO
)

set(LLD_RELEASE_FLAGS
    /OPT:REF
    /OPT:ICF
    /LTCG
)
```

### 2. Symbol Export Data

```cmake
# Export table structure
struct ExportEntry {
    string name;           # Symbol name
    int ordinal;          # Export ordinal
    bool noname;          # Export by ordinal only
    string forward;       # Forward to another DLL
}

# DEF file parser output
list(APPEND EXPORTS
    "MyFunction @1"
    "MyVariable @2 DATA"
    "ForwardedFunc = other.dll.RealFunc"
)
```

### 3. Import Library Data

```cmake
# Import library metadata
struct ImportLibrary {
    string name;          # Library name (e.g., "kernel32")
    string path;          # Full path to .lib file
    list symbols;         # Imported symbols
    bool delay_load;      # Delay-load flag
}
```

---

## Error Handling

### 1. Linker Not Found

```cmake
if(NOT LLD_FOUND)
    message(FATAL_ERROR 
        "LLD linker not found. Please install LLVM 10.0.0 or higher.\n"
        "Download from: https://github.com/llvm/llvm-project/releases\n"
        "Ensure lld-link.exe is in your PATH.")
endif()
```

### 2. Undefined Symbols

```cmake
# Enable verbose undefined symbol reporting
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_link_options(/VERBOSE:LIB)  # Show library search
    add_link_options(/VERBOSE:REF)  # Show symbol references
endif()
```

### 3. Symbol Conflicts

```cmake
# Detect duplicate symbols
add_link_options(/FORCE:MULTIPLE)  # Allow multiple definitions (with warning)
# Or fail with clear error:
add_link_options(/WX)  # Treat linker warnings as errors
```

### 4. Import Library Missing

```cmake
function(check_import_libraries target)
    get_target_property(LINK_LIBS ${target} LINK_LIBRARIES)
    foreach(lib ${LINK_LIBS})
        if(NOT EXISTS ${lib})
            message(FATAL_ERROR 
                "Import library not found: ${lib}\n"
                "Required by target: ${target}\n"
                "Please build the dependency first.")
        endif()
    endforeach()
endfunction()
```

---

## Testing Strategy

### 1. Unit Tests

**Test Linker Detection:**
```cmake
# tests/linker/test_lld_detection.cmake
include(FindLLD)
if(NOT LLD_FOUND)
    message(FATAL_ERROR "LLD detection failed")
endif()
message(STATUS "LLD version: ${LLD_VERSION}")
```

**Test Symbol Export:**
```cmake
# tests/linker/test_exports.cmake
add_library(test_dll SHARED test.c)
add_dll_exports(test_dll test.def)
# Verify export table in generated DLL
```

### 2. Integration Tests

**Test Full System Link:**
```cmake
# Build minimal ReactOS subset
add_subdirectory(ntdll)
add_subdirectory(kernel32)
add_subdirectory(ntoskrnl)

# Verify all link successfully
add_test(NAME test_system_link
    COMMAND ${CMAKE_COMMAND} --build . --target all)
```

### 3. Runtime Tests

**Test Binary Execution:**
```powershell
# tests/runtime/test_execution.ps1
$binaries = @("ntdll.dll", "kernel32.dll", "cmd.exe")
foreach ($bin in $binaries) {
    # Check PE format
    dumpbin /headers $bin
    
    # Check exports
    dumpbin /exports $bin
    
    # Check imports
    dumpbin /imports $bin
}
```

### 4. Regression Tests

**Compare with Reference Build:**
```cmake
# Compare LLD build with MSVC build
add_test(NAME test_binary_compatibility
    COMMAND ${CMAKE_COMMAND} 
        -P ${CMAKE_SOURCE_DIR}/tests/compare_binaries.cmake
        -DLLD_BINARY=${LLD_BUILD_DIR}/ntdll.dll
        -DMSVC_BINARY=${MSVC_BUILD_DIR}/ntdll.dll)
```

---

## Performance Considerations

### 1. Parallel Linking

```cmake
# Enable LLD parallel linking
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /threads:${PROCESSOR_COUNT}")
```

### 2. Incremental Linking

```cmake
# Disable for release (faster full link)
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} /INCREMENTAL:NO")

# Enable for debug (faster iteration)
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG} /INCREMENTAL")
```

### 3. Link-Time Optimization

```cmake
# Enable LTO for release builds
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)
add_link_options($<$<CONFIG:Release>:/LTCG>)
```

### 4. Symbol Stripping

```cmake
# Strip debug symbols in release
add_link_options($<$<CONFIG:Release>:/DEBUG:NONE>)
```

---

## Security Considerations

### 1. ASLR (Address Space Layout Randomization)

```cmake
add_link_options(/DYNAMICBASE)  # Enable ASLR
```

### 2. DEP (Data Execution Prevention)

```cmake
add_link_options(/NXCOMPAT)  # Enable DEP
```

### 3. Control Flow Guard

```cmake
if(LLD_VERSION VERSION_GREATER_EQUAL "11.0.0")
    add_link_options(/GUARD:CF)  # Enable CFG
endif()
```

### 4. Safe SEH

```cmake
add_link_options(/SAFESEH)  # Enable Safe SEH (32-bit only)
```

---

## Deployment Strategy

### Phase 1: Infrastructure Setup (Week 1)
- Create CMake modules (FindLLD, ConfigureLLD, etc.)
- Update toolchain files
- Add linker detection logic

### Phase 2: Symbol Management (Week 1-2)
- Implement DEF file handling
- Create import library generation
- Add export/import validation

### Phase 3: PE Configuration (Week 2)
- Implement subsystem configuration
- Add base address management
- Configure section properties

### Phase 4: Testing (Week 2-3)
- Create unit tests
- Run integration tests
- Perform runtime validation

### Phase 5: Documentation (Week 3)
- Update build documentation
- Create troubleshooting guide
- Write migration notes

---

## Rollback Plan

If LLD linking fails:

1. **Immediate Fallback:**
```cmake
if(LLD_LINK_FAILED)
    message(WARNING "LLD linking failed, falling back to MSVC linker")
    set(CMAKE_LINKER link.exe)
endif()
```

2. **Selective Rollback:**
```cmake
# Use LLD for most targets, MSVC for problematic ones
set_target_properties(problematic_target PROPERTIES LINKER link.exe)
```

3. **Complete Rollback:**
```cmake
# Revert to original toolchain
set(USE_LLD OFF CACHE BOOL "Use LLD linker")
```

---

## Success Metrics

- ✅ All ReactOS components link successfully with LLD
- ✅ Link time ≤ MSVC link time
- ✅ Binary size within 5% of MSVC binaries
- ✅ All exports/imports resolve correctly
- ✅ ReactOS boots in VM with LLD-linked binaries
- ✅ Zero linker errors in CI/CD pipeline

---

**Document Version:** 1.0  
**Last Updated:** 2025-10-30  
**Status:** Ready for Implementation
