from conan import ConanFile
from conan.tools.cmake import CMakeToolchain, CMake, cmake_layout


class FreeWindowsConan(ConanFile):
    name = "freeWindows"
    version = "1.0.0"
    package_type = "application"

    # Optional metadata
    license = "MulanPSL-2.0"
    author = "FreeWindows Project"
    url = "https://github.com/freeWindows/freeWindows"
    description = "ReactOS with LLVM toolchain and modern C/C++ standards"
    topics = ("operating-system", "reactos", "llvm", "clang")

    # Binary configuration
    settings = "os", "compiler", "build_type", "arch"

    # Sources are located in the same place as this recipe, copy them to the recipe
    exports_sources = "CMakeLists.txt", "src/*", "cmake/*", "third_party/*"

    def layout(self):
        cmake_layout(self)

    def generate(self):
        tc = CMakeToolchain(self)
        tc.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        cmake = CMake(self)
        cmake.install()

    def requirements(self):
        # Add any external dependencies here
        # For example:
        # self.requires("zlib/1.2.11")
        pass