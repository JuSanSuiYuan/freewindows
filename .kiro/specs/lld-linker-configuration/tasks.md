# Implementation Plan: LLD Linker Configuration

## Task Overview

This implementation plan breaks down the LLD linker configuration into discrete, manageable coding tasks. Each task builds incrementally on previous work, ensuring the system remains functional throughout development.

---

- [ ] 1. Create linker detection infrastructure
  - Create `cmake/modules/FindLLD.cmake` module to detect lld-link and ld.lld executables
  - Implement version detection and validation (minimum 10.0.0)
  - Add platform-specific path detection (Windows/Linux/macOS)
  - Create error messages for missing linker
  - _Requirements: 1.1, 1.2, 1.3, 10.1, 10.2, 10.3_

- [ ] 1.1 Implement LLD executable detection
  - Write CMake code to search for lld-link.exe in LLVM installation paths
  - Write CMake code to search for ld.lld in LLVM installation paths
  - Handle both system PATH and explicit LLVM_DIR locations
  - _Requirements: 1.1, 1.2_

- [ ] 1.2 Add version validation logic
  - Execute linker with --version flag to get version string
  - Parse version number from output
  - Compare against minimum required version (10.0.0)
  - Set LLD_VERSION CMake variable
  - _Requirements: 1.3_

- [ ] 1.3 Create detection status reporting
  - Set LLD_FOUND variable based on detection results
  - Generate informative status messages
  - Provide installation instructions if not found
  - _Requirements: 1.3, 9.4_

---

- [ ] 2. Implement linker configuration module
  - Create `cmake/modules/ConfigureLLD.cmake` with configuration functions
  - Implement MSVC-mode configuration (lld-link flags)
  - Implement GNU-mode configuration (ld.lld flags)
  - Add optimization level configuration
  - Add debug information configuration
  - _Requirements: 1.4, 1.5, 4.1, 4.2, 6.1, 6.3_

- [ ] 2.1 Create MSVC-mode linker configuration
  - Define function `configure_lld_for_msvc_mode()`
  - Set /MACHINE flag based on target architecture
  - Configure /NOLOGO, /NXCOMPAT, /DYNAMICBASE flags
  - Set up debug flags (/DEBUG, /PDB)
  - Set up release flags (/OPT:REF, /OPT:ICF, /LTCG)
  - _Requirements: 1.4, 4.1, 4.3, 6.3_

- [ ] 2.2 Create GNU-mode linker configuration
  - Define function `configure_lld_for_gnu_mode()`
  - Set -m flag for target emulation
  - Configure --gc-sections, --icf flags
  - Set up debug flags (--build-id)
  - Set up release flags (--lto-O2)
  - _Requirements: 1.5, 4.1_

- [ ] 2.3 Add helper macros for target-specific configuration
  - Create `add_lld_link_options(target options)` macro
  - Create `set_lld_optimization_level(target level)` function
  - Create `set_lld_debug_info(target enabled)` function
  - _Requirements: 6.1, 6.3, 6.4_

---

- [ ] 3. Implement symbol export/import management
  - Create `cmake/modules/SymbolManagement.cmake` module
  - Implement DEF file handling for exports
  - Implement __declspec(dllexport) support
  - Create import library generation logic
  - Add delay-load DLL support
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.4_

- [ ] 3.1 Implement DEF file export handling
  - Create `add_dll_exports(target def_file)` function
  - Add /DEF flag for MSVC mode
  - Add --output-def flag for GNU mode
  - Validate DEF file exists before linking
  - _Requirements: 2.1, 2.4_

- [ ] 3.2 Implement import library generation
  - Create `generate_import_library(target)` function
  - Set IMPORT_LIBRARY property on DLL targets
  - Configure output path for .lib files
  - Handle both MSVC (.lib) and GNU (.dll.a) formats
  - _Requirements: 2.3, 3.1_

- [ ] 3.3 Add delay-load DLL support
  - Create `add_delay_load_dll(target dll_name)` function
  - Add /DELAYLOAD flag for specified DLLs
  - Link against delayimp.lib
  - _Requirements: 3.2_

- [ ] 3.4 Implement export validation
  - Create function to verify exports are generated
  - Parse linker output for export warnings
  - Report missing or duplicate exports
  - _Requirements: 2.5, 7.2_

---

- [ ] 4. Implement PE format configuration
  - Create `cmake/modules/PEConfiguration.cmake` module
  - Implement subsystem configuration
  - Implement base address configuration
  - Implement stack/heap size configuration
  - Add section alignment configuration
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 5.2, 5.3, 5.4_

- [ ] 4.1 Create subsystem configuration function
  - Define `set_pe_subsystem(target subsystem)` function
  - Support CONSOLE, WINDOWS, NATIVE, POSIX, EFI_APPLICATION
  - Add /SUBSYSTEM flag for MSVC mode
  - Add --subsystem flag for GNU mode
  - _Requirements: 4.3_

- [ ] 4.2 Create base address configuration
  - Define `set_pe_base_address(target address)` function
  - Add /BASE flag with specified address
  - Validate address is properly aligned
  - _Requirements: 5.2_

- [ ] 4.3 Create stack and heap size configuration
  - Define `set_pe_stack_size(target size)` function
  - Define `set_pe_heap_size(target size)` function
  - Add /STACK and /HEAP flags
  - _Requirements: 5.2_

- [ ] 4.4 Add section alignment configuration
  - Define `set_pe_section_alignment(target alignment)` function
  - Add /ALIGN flag
  - _Requirements: 5.3_

- [ ] 4.5 Implement PDB generation for debugging
  - Configure /DEBUG:FULL flag for debug builds
  - Set PDB output path
  - Ensure PDB compatibility with Windows debuggers
  - _Requirements: 4.5_

---

- [ ] 5. Implement linker script management
  - Create `cmake/modules/LinkerScripts.cmake` module
  - Implement custom linker script support
  - Create linker script templates for kernel/drivers
  - Add memory map generation
  - _Requirements: 5.1, 5.4, 5.5_

- [ ] 5.1 Create linker script support function
  - Define `add_linker_script(target script_file)` function
  - Add /SCRIPT flag for custom linker scripts
  - Validate script file exists
  - _Requirements: 5.1_

- [ ] 5.2 Create kernel linker script template
  - Write linker script for ReactOS kernel (ntoskrnl)
  - Define memory layout starting at 0x80000000
  - Specify section ordering (.text, .data, .bss)
  - Add section alignment directives
  - _Requirements: 5.1, 5.4_

- [ ] 5.3 Create driver linker script template
  - Write linker script for kernel drivers
  - Define appropriate base addresses
  - Configure section properties
  - _Requirements: 5.1_

- [ ] 5.4 Implement memory map generation
  - Define `generate_memory_map(target)` function
  - Add /MAP flag to generate link map file
  - Parse map file for symbol addresses
  - _Requirements: 9.3_

---

- [ ] 6. Update toolchain files for LLD integration
  - Modify `cmake/toolchains/clang-cl.cmake` to use LLD
  - Modify `cmake/toolchains/reactos-clang-cl.cmake` to use LLD
  - Include new LLD modules
  - Set CMAKE_LINKER to lld-link or ld.lld
  - Configure linker command templates
  - _Requirements: 1.1, 1.2, 1.4, 1.5_

- [ ] 6.1 Update clang-cl.cmake toolchain
  - Include FindLLD module
  - Set CMAKE_LINKER to lld-link
  - Update CMAKE_C_LINK_EXECUTABLE template
  - Update CMAKE_CXX_LINK_EXECUTABLE template
  - Update CMAKE_SHARED_LINKER_FLAGS
  - _Requirements: 1.4_

- [ ] 6.2 Update reactos-clang-cl.cmake toolchain
  - Include ConfigureLLD module
  - Include SymbolManagement module
  - Include PEConfiguration module
  - Call configure_lld_for_msvc_mode()
  - _Requirements: 1.4_

- [ ] 6.3 Add linker flag variables
  - Define LLD_GLOBAL_FLAGS variable
  - Define LLD_DEBUG_FLAGS variable
  - Define LLD_RELEASE_FLAGS variable
  - Apply flags based on CMAKE_BUILD_TYPE
  - _Requirements: 6.1, 6.3_

---

- [ ] 7. Implement error handling and diagnostics
  - Add undefined symbol detection and reporting
  - Add duplicate symbol detection
  - Add missing import library detection
  - Create verbose linking mode
  - _Requirements: 7.1, 7.2, 7.3, 9.1, 9.2_

- [ ] 7.1 Create undefined symbol error handler
  - Parse linker output for "undefined reference" errors
  - Extract symbol names and source files
  - Generate helpful error messages with suggestions
  - _Requirements: 7.1_

- [ ] 7.2 Create duplicate symbol error handler
  - Parse linker output for "duplicate symbol" errors
  - Report all locations where symbol is defined
  - Suggest resolution strategies
  - _Requirements: 7.2_

- [ ] 7.3 Create missing library error handler
  - Detect "cannot find library" errors
  - Check if import library should exist
  - Suggest building dependency first
  - _Requirements: 3.3, 7.3_

- [ ] 7.4 Implement verbose linking mode
  - Add option to enable verbose linker output
  - Log complete linker command line
  - Log all input files and libraries
  - _Requirements: 9.1, 9.2_

---

- [ ] 8. Create compatibility layer for MSVC/MinGW libraries
  - Implement MSVC import library compatibility checks
  - Implement MinGW library compatibility checks
  - Add library format conversion if needed
  - _Requirements: 7.4, 7.5_

- [ ] 8.1 Add MSVC library compatibility validation
  - Check MSVC .lib files are compatible with LLD
  - Test linking against MSVC-generated import libraries
  - Document any incompatibilities
  - _Requirements: 7.4_

- [ ] 8.2 Add MinGW library compatibility validation
  - Check MinGW .a files are compatible with LLD
  - Test linking against MinGW-generated libraries
  - Document any incompatibilities
  - _Requirements: 7.5_

---

- [ ] 9. Implement testing infrastructure
  - Create unit tests for linker detection
  - Create integration tests for symbol management
  - Create runtime tests for binary execution
  - Create regression tests comparing with MSVC builds
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 9.1 Create linker detection tests
  - Write test to verify LLD is found
  - Write test to verify version detection
  - Write test for error handling when LLD is missing
  - _Requirements: 8.1_

- [ ] 9.2 Create symbol export/import tests
  - Create test DLL with exports
  - Create test executable that imports from DLL
  - Verify exports are generated correctly
  - Verify imports resolve at runtime
  - _Requirements: 8.2_

- [ ] 9.3 Create PE format validation tests
  - Use dumpbin or objdump to inspect generated binaries
  - Verify subsystem is set correctly
  - Verify base address is correct
  - Verify exports/imports tables are valid
  - _Requirements: 8.1, 8.3_

- [ ] 9.4 Create runtime execution tests
  - Build minimal ReactOS components (ntdll, kernel32)
  - Test that DLLs load correctly
  - Test that executables run without errors
  - _Requirements: 8.3_

- [ ] 9.5 Create regression tests
  - Compare LLD-linked binaries with MSVC-linked binaries
  - Verify binary sizes are similar
  - Verify export tables match
  - Verify import tables match
  - _Requirements: 8.4_

---

- [ ] 10. Add performance optimizations
  - Enable parallel linking
  - Configure incremental linking for debug builds
  - Enable LTO for release builds
  - Add symbol stripping for release builds
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ] 10.1 Enable parallel linking
  - Add /threads flag with processor count
  - Measure linking time improvement
  - _Requirements: 6.1_

- [ ] 10.2 Configure incremental linking
  - Enable /INCREMENTAL for debug builds
  - Disable /INCREMENTAL for release builds
  - _Requirements: 6.2_

- [ ] 10.3 Enable link-time optimization
  - Set CMAKE_INTERPROCEDURAL_OPTIMIZATION for release
  - Add /LTCG flag for release builds
  - Measure binary size reduction
  - _Requirements: 6.3_

- [ ] 10.4 Implement symbol stripping
  - Add /DEBUG:NONE for release builds
  - Remove unnecessary debug information
  - Measure binary size reduction
  - _Requirements: 6.4_

---

- [ ] 11. Add security features
  - Enable ASLR (Address Space Layout Randomization)
  - Enable DEP (Data Execution Prevention)
  - Enable Control Flow Guard (if supported)
  - Enable Safe SEH for 32-bit builds
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [ ] 11.1 Enable ASLR
  - Add /DYNAMICBASE flag to all executables and DLLs
  - Verify ASLR is enabled in generated binaries
  - _Requirements: 4.1_

- [ ] 11.2 Enable DEP
  - Add /NXCOMPAT flag to all executables and DLLs
  - Verify DEP is enabled in generated binaries
  - _Requirements: 4.2_

- [ ] 11.3 Enable Control Flow Guard
  - Check LLD version supports CFG (11.0.0+)
  - Add /GUARD:CF flag if supported
  - _Requirements: 4.3_

- [ ] 11.4 Enable Safe SEH
  - Add /SAFESEH flag for 32-bit builds
  - Verify Safe SEH is enabled
  - _Requirements: 4.4_

---

- [ ] 12. Create documentation and examples
  - Write LLD configuration guide
  - Create troubleshooting documentation
  - Write migration guide from MSVC/GNU ld
  - Create example projects demonstrating features
  - _Requirements: 9.1, 9.2, 9.3, 9.5_

- [ ] 12.1 Write LLD configuration guide
  - Document all CMake modules and functions
  - Provide usage examples for each feature
  - Explain configuration options
  - _Requirements: 9.3_

- [ ] 12.2 Create troubleshooting guide
  - Document common linking errors and solutions
  - Provide debugging techniques
  - List known issues and workarounds
  - _Requirements: 9.2_

- [ ] 12.3 Write migration guide
  - Document differences between LLD and MSVC link.exe
  - Document differences between LLD and GNU ld
  - Provide migration checklist
  - _Requirements: 9.5_

- [ ] 12.4 Create example projects
  - Create simple DLL export/import example
  - Create kernel driver example
  - Create GUI application example
  - _Requirements: 9.3_

---

- [ ] 13. Integrate with ReactOS build system
  - Test linking ReactOS ntdll.dll
  - Test linking ReactOS kernel32.dll
  - Test linking ReactOS ntoskrnl.exe
  - Test linking ReactOS drivers
  - Test linking ReactOS GUI applications
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ] 13.1 Link ReactOS core DLLs
  - Configure ntdll.dll with LLD
  - Configure kernel32.dll with LLD
  - Verify exports are correct
  - Verify import libraries are generated
  - _Requirements: 8.2_

- [ ] 13.2 Link ReactOS kernel
  - Configure ntoskrnl.exe with LLD
  - Apply kernel linker script
  - Set base address to 0x80000000
  - Verify kernel loads in VM
  - _Requirements: 8.3_

- [ ] 13.3 Link ReactOS drivers
  - Configure sample driver with LLD
  - Set NATIVE subsystem
  - Verify driver loads correctly
  - _Requirements: 8.3_

- [ ] 13.4 Link ReactOS applications
  - Configure explorer.exe with LLD
  - Configure cmd.exe with LLD
  - Set WINDOWS/CONSOLE subsystems
  - Verify applications run correctly
  - _Requirements: 8.3_

---

- [ ] 14. Perform full system integration test
  - Build complete ReactOS with LLD
  - Generate bootable ISO image
  - Test boot in QEMU
  - Test boot in VirtualBox
  - Run ReactOS test suite
  - _Requirements: 8.3, 8.4, 8.5_

- [ ] 14.1 Build complete ReactOS
  - Configure full ReactOS build with LLD
  - Build all components (kernel, drivers, DLLs, apps)
  - Verify no linking errors
  - _Requirements: 8.1, 8.2_

- [ ] 14.2 Generate ISO image
  - Use mkisofs to create bootable ISO
  - Verify ISO structure is correct
  - _Requirements: 8.3_

- [ ] 14.3 Test in virtual machines
  - Boot ISO in QEMU
  - Boot ISO in VirtualBox
  - Verify system boots to desktop
  - Test basic functionality (file manager, command prompt)
  - _Requirements: 8.3, 8.4_

- [ ] 14.4 Run test suite
  - Execute ReactOS automated tests
  - Compare results with MSVC build
  - Document any failures
  - _Requirements: 8.5_

---

## Notes

- All tasks should be completed in order, as later tasks depend on earlier ones
- Each task should include appropriate error handling and logging
- All code should follow ReactOS coding standards
- All changes should be documented in migration log
- Testing should be performed after each major task completion

---

**Document Version:** 1.0  
**Last Updated:** 2025-10-30  
**Total Tasks:** 14 major tasks, 60+ subtasks  
**Estimated Duration:** 3 weeks
