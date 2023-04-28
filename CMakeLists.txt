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

# major, minor, patch versions + version string
set(PDCALC_MAJOR_VERSION 0)
set(PDCALC_MINOR_VERSION 1)
set(PDCALC_PATCH_VERSION 0)
set(
    PDCALC_VERSION
    ${PDCALC_MAJOR_VERSION}.${PDCALC_MINOR_VERSION}.${PDCALC_PATCH_VERSION}
)

project(
    pdcalc
    VERSION ${PDCALC_VERSION}
    DESCRIPTION "An infix calculator written with Flex + Bison"
    HOMEPAGE_URL https://github.com/phetdam/infix-calculator
    # TODO: maybe this will be a C-only project
    LANGUAGES C CXX
)

# default build type is Debug
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()
# we use lowercase build type in the project
string(TOLOWER ${CMAKE_BUILD_TYPE} PDCALC_BUILD_TYPE)

# set some system information variables used for the version info
set(PDCALC_SYSTEM_NAME ${CMAKE_SYSTEM_NAME})
set(PDCALC_SYSTEM_VERSION ${CMAKE_SYSTEM_VERSION})
set(PDCALC_SYSTEM_ARCH ${CMAKE_SYSTEM_PROCESSOR})

# enforce our C/C++ standards
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# set CMake module path
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
# find Flex + Bison
include(FindFlexBison)
# set compiler options
include(ConfigCompile)

# macro definitions for versioning
add_compile_definitions(
    PDCALC_MAJOR_VERSION=${PDCALC_MAJOR_VERSION}
    PDCALC_MINOR_VERSION=${PDCALC_MINOR_VERSION}
    PDCALC_PATCH_VERSION=${PDCALC_PATCH_VERSION}
    # need double quotes for CMake to pass as a string
    PDCALC_BUILD_TYPE="${PDCALC_BUILD_TYPE}"
    PDCALC_SYSTEM_NAME="${PDCALC_SYSTEM_NAME}"
    PDCALC_SYSTEM_VERSION="${PDCALC_SYSTEM_VERSION}"
    PDCALC_SYSTEM_ARCH="${PDCALC_SYSTEM_ARCH}"
)
# path to include directory
set(PDCALC_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include)
include_directories(${PDCALC_INCLUDE_DIR})
# path to source directory
set(PDCALC_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src)

add_subdirectory(src)
