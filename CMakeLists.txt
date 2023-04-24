cmake_minimum_required(VERSION 3.16)

##
# Build instructions
#
# It is assumed that Flex and Bison have been appropriately installed on your
# *nix system through your system package manager. On Windows, it's easiest to
# get a WinFlexBison release and define PDCALC_FLEX_PATH and PDCALC_BISON_PATH
# in the CMake generate command. Alternatively, you can manually update your
# PATH with the WinFlexBison release install directory.
#
# Windows:
#   cmake -S . -B build_windows -G Ninja && cmake --build build_windows -j
#
# *nix:
#   cmake -S . -B build && cmake --build build -j
#

# major, minor, patch versions
set(PDCALC_MAJOR_VERSION 0)
set(PDCALC_MINOR_VERSION 1)
set(PDCALC_PATCH_VERSION 0)

project(
    pdcalc
    VERSION
        ${PDCALC_MAJOR_VERSION}.${PDCALC_MINOR_VERSION}.${PDCALC_PATCH_VERSION}
    DESCRIPTION "An infix calculator written with flex + bison"
    HOMEPAGE_URL https://github.com/phetdam/infix-calculator
    # TODO: maybe this will be a C-only project
    LANGUAGES C CXX
)

# enforce our C/C++ standards
set(CMAKE_C_STANDARD C11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# set CMake module path
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# find Flex + Bison
include(FindFlexBison)

# path to include directory
set(PDCALC_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include)
include_directories(${PDCALC_INCLUDE_DIR})
# path to source directory
set(PDCALC_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src)

add_subdirectory(src)
