# Requirements Document: LLD Linker Configuration for ReactOS

## Introduction

This specification defines the requirements for configuring the LLD (LLVM Linker) to successfully link the complete ReactOS operating system. The goal is to replace the traditional GNU ld or MSVC link.exe with LLD while maintaining full compatibility with ReactOS's linking requirements, including proper symbol export/import handling, subsystem configuration, and Windows-specific linking features.

## Glossary

- **LLD**: LLVM Linker, a modern linker that is part of the LLVM project
- **System**: The FreeWindows build system using Clang/LLVM toolchain
- **ReactOS**: The open-source Windows-compatible operating system being compiled
- **Symbol Export**: Making functions/variables available to other modules
- **Symbol Import**: Using functions/variables from other modules
- **DEF File**: Module definition file specifying exports/imports
- **Subsystem**: Windows executable subsystem (console, GUI, native, etc.)
- **PE Format**: Portable Executable, the Windows executable file format
- **Import Library**: Library file (.lib) containing import information
- **DLL**: Dynamic Link Library, Windows shared library format

---

## Requirements

### Requirement 1: LLD Linker Integration

**User Story:** As a build system developer, I want to configure LLD as the default linker for ReactOS, so that the entire system can be linked using LLVM toolchain.

#### Acceptance Criteria

1. WHEN the System configures the build, THE System SHALL detect and use lld-link.exe for MSVC-compatible linking
2. WHEN the System configures the build, THE System SHALL detect and use ld.lld for GNU-compatible linking
3. WHEN LLD is not available, THE System SHALL report a clear error message indicating the missing linker
4. WHERE Clang-CL toolchain is used, THE System SHALL configure lld-link with MSVC-compatible command-line syntax
5. WHERE Clang-GNU toolchain is used, THE System SHALL configure ld.lld with GNU ld-compatible command-line syntax

---

### Requirement 2: Symbol Export Configuration

**User Story:** As a ReactOS developer, I want DLL symbol exports to work correctly with LLD, so that modules can expose their APIs to other components.

#### Acceptance Criteria

1. WHEN a module defines exports via DEF file, THE System SHALL pass the DEF file to LLD using appropriate flags
2. WHEN a module uses __declspec(dllexport), THE System SHALL ensure LLD generates correct export tables
3. WHEN linking a DLL, THE System SHALL generate an import library (.lib) for use by dependent modules
4. WHEN multiple export methods are used, THE System SHALL prioritize DEF file exports over __declspec annotations
5. WHEN export symbols contain name mangling, THE System SHALL preserve or correctly demangle symbol names

---

### Requirement 3: Symbol Import Configuration

**User Story:** As a ReactOS developer, I want DLL symbol imports to resolve correctly with LLD, so that modules can use APIs from other components.

#### Acceptance Criteria

1. WHEN a module imports symbols via __declspec(dllimport), THE System SHALL resolve imports against import libraries
2. WHEN a module uses delay-load imports, THE System SHALL configure LLD to support delay-loaded DLLs
3. WHEN import libraries are missing, THE System SHALL report clear error messages indicating which libraries are needed
4. WHEN circular dependencies exist, THE System SHALL handle them using appropriate LLD flags
5. WHEN importing from system DLLs, THE System SHALL use correct import library paths

---

### Requirement 4: PE Format Configuration

**User Story:** As a build system developer, I want LLD to generate correct PE format executables, so that ReactOS binaries are compatible with Windows loaders.

#### Acceptance Criteria

1. WHEN linking an executable, THE System SHALL configure LLD to generate PE32 format for 32-bit targets
2. WHEN linking an executable, THE System SHALL configure LLD to generate PE32+ format for 64-bit targets
3. WHEN specifying subsystem, THE System SHALL pass correct /SUBSYSTEM flag to LLD (CONSOLE, WINDOWS, NATIVE, etc.)
4. WHEN setting entry point, THE System SHALL configure LLD with correct /ENTRY flag
5. WHEN generating debug information, THE System SHALL configure LLD to produce PDB files compatible with Windows debuggers

---

### Requirement 5: Linker Script and Memory Layout

**User Story:** As a kernel developer, I want to control memory layout and section placement, so that ReactOS kernel and drivers load at correct addresses.

#### Acceptance Criteria

1. WHEN linking kernel components, THE System SHALL apply custom linker scripts defining memory layout
2. WHEN specifying base addresses, THE System SHALL configure LLD with /BASE flag for DLLs and executables
3. WHEN aligning sections, THE System SHALL use /ALIGN flag to ensure proper section alignment
4. WHEN merging sections, THE System SHALL configure LLD to merge compatible sections (e.g., .rdata into .text)
5. WHEN ordering sections, THE System SHALL ensure correct section ordering for bootable components

---

### Requirement 6: Optimization and Performance

**User Story:** As a build system developer, I want to optimize linking performance, so that build times are minimized.

#### Acceptance Criteria

1. WHEN linking large binaries, THE System SHALL enable LLD's parallel linking capabilities
2. WHEN performing incremental builds, THE System SHALL configure LLD for incremental linking where supported
3. WHEN optimizing for size, THE System SHALL enable LLD's size optimization flags (/OPT:REF, /OPT:ICF)
4. WHEN generating release builds, THE System SHALL strip unnecessary symbols and debug information
5. WHEN measuring performance, THE System SHALL log linking time for each major component

---

### Requirement 7: Compatibility and Error Handling

**User Story:** As a ReactOS developer, I want clear error messages when linking fails, so that I can quickly identify and fix issues.

#### Acceptance Criteria

1. WHEN LLD encounters undefined symbols, THE System SHALL report which symbols are missing and from which modules
2. WHEN LLD detects duplicate symbols, THE System SHALL report all locations where symbols are defined
3. WHEN LLD fails due to incompatible flags, THE System SHALL suggest correct flag alternatives
4. WHEN linking with MSVC-generated libraries, THE System SHALL ensure LLD compatibility with MSVC import libraries
5. WHEN linking with MinGW-generated libraries, THE System SHALL ensure LLD compatibility with GNU-style libraries

---

### Requirement 8: Testing and Validation

**User Story:** As a quality assurance engineer, I want to verify that LLD-linked binaries work correctly, so that we can ensure system stability.

#### Acceptance Criteria

1. WHEN a binary is linked with LLD, THE System SHALL verify that all imports are correctly resolved
2. WHEN a DLL is linked with LLD, THE System SHALL verify that exports are accessible to dependent modules
3. WHEN running linked executables, THE System SHALL verify that they load and execute without errors
4. WHEN comparing with reference builds, THE System SHALL verify that LLD-linked binaries have equivalent functionality
5. WHEN testing in virtual machines, THE System SHALL verify that ReactOS boots and runs correctly with LLD-linked components

---

### Requirement 9: Documentation and Logging

**User Story:** As a build system maintainer, I want comprehensive logging of linker operations, so that I can debug linking issues.

#### Acceptance Criteria

1. WHEN linking fails, THE System SHALL log the complete LLD command line used
2. WHEN verbose mode is enabled, THE System SHALL log all linker flags and input files
3. WHEN generating link maps, THE System SHALL configure LLD to produce detailed map files showing symbol addresses
4. WHEN documenting the build, THE System SHALL record which linker version was used
5. WHEN troubleshooting, THE System SHALL provide a summary of linking statistics (time, binary size, symbol count)

---

### Requirement 10: Cross-Platform Considerations

**User Story:** As a developer on different platforms, I want the build system to work consistently, so that I can build ReactOS on Windows, Linux, or macOS.

#### Acceptance Criteria

1. WHEN building on Windows, THE System SHALL use lld-link.exe with Windows-style paths
2. WHEN building on Linux, THE System SHALL use ld.lld with Unix-style paths
3. WHEN building on macOS, THE System SHALL use ld.lld with Unix-style paths
4. WHEN handling path separators, THE System SHALL normalize paths for the target platform
5. WHEN using host tools, THE System SHALL detect and use the correct LLD variant for the host platform

---

## Constraints

- LLD version MUST be 10.0.0 or higher for full PE format support
- All linker configurations MUST maintain compatibility with existing ReactOS build scripts
- Symbol export/import mechanisms MUST be compatible with Windows loader expectations
- Linked binaries MUST be bootable and executable on real hardware and virtual machines
- Build system changes MUST NOT require modifications to ReactOS source code (zero-modification principle)

---

## Success Criteria

- ✅ All ReactOS components (kernel, drivers, DLLs, executables) link successfully with LLD
- ✅ Generated binaries pass all existing ReactOS test suites
- ✅ ReactOS boots successfully in QEMU/VirtualBox with LLD-linked components
- ✅ Linking performance is equal to or better than GNU ld or MSVC link.exe
- ✅ All symbol exports and imports resolve correctly at runtime
- ✅ Build system documentation is updated with LLD configuration details

---

**Document Version:** 1.0  
**Last Updated:** 2025-10-30  
**Status:** Draft - Ready for Review
