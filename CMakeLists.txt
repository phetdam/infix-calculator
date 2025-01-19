cmake_minimum_required(VERSION 3.16)

##
# Build instructions
#
# Note: The following build instructions are out of date.
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

project(
    pdcalc
    VERSION 0.1.0
    DESCRIPTION "An infix calculator written with Flex + Bison"
    HOMEPAGE_URL https://github.com/phetdam/infix-calculator
    LANGUAGES C CXX
)

# build support library as shared by default
option(BUILD_SHARED_LIBS "Build pdcalc library as shared" ON)
# use raw pointer instead of unique_ptr for pdcalc parser PIMPL
option(
    PDCALC_RAW_PIMPL
    "Use raw pointer instead of unique_ptr for parser PIMPL" OFF
)

# indicate if generator is multi-config
get_property(PDCALC_IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(PDCALC_IS_MULTI_CONFIG)
    message(STATUS "Build config: Multi")
else()
    # default build type is Debug
    if(NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE Debug)
    endif()
    message(STATUS "Build config: ${CMAKE_BUILD_TYPE}")
endif()
# used to use lowercase, now we just assign to PDCALC_BUILD_TYPE
# FIXME: when version header generation is done this need only be set for the
# single-config generators. this is defined differently for multi-config
set(PDCALC_BUILD_TYPE ${CMAKE_BUILD_TYPE})

# config messages
if(BUILD_SHARED_LIBS)
    message(STATUS "Build libraries: Shared")
else()
    message(STATUS "Build libraries: Static")
endif()
if(PDCALC_RAW_PIMPL)
    message(STATUS "PIMPL method: raw pointer")
else()
    message(STATUS "PIMPL method: unique_ptr")
endif()

# current top-level build directory
set(PDCALC_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

# build all artifacts in top-level build directory. multi-config generators
# like Visual Studio will have a per-config subdirectory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PDCALC_BINARY_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PDCALC_BINARY_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PDCALC_BINARY_DIR})

# enforce our C/C++ standards
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# set CMake module path
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
# find Flex + Bison
# FIXME: need to also report the version since we assume some min versions
include(FindFlexBison)
# find Google Test
find_package(GTest 1.10)
if(GTest_FOUND)
    message(STATUS "Google Test version: ${GTest_VERSION}")
else()
    message(STATUS "Google Test version: None")
endif()

# set compiler options
include(ConfigCompile)

# set some variables used for the version info
set(PDCALC_MAJOR_VERSION ${PROJECT_VERSION_MAJOR})
set(PDCALC_MINOR_VERSION ${PROJECT_VERSION_MINOR})
set(PDCALC_PATCH_VERSION ${PROJECT_VERSION_PATCH})
set(PDCALC_VERSION ${PROJECT_VERSION})
set(PDCALC_SYSTEM_NAME ${CMAKE_SYSTEM_NAME})
set(PDCALC_SYSTEM_VERSION ${CMAKE_SYSTEM_VERSION})
set(PDCALC_SYSTEM_ARCH ${CMAKE_SYSTEM_PROCESSOR})

# path to project include directory
set(PDCALC_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)
# name of namespaced include directory
set(PDCALC_NAMESPACE_INCLUDE_DIR ${PDCALC_INCLUDE_DIR}/pdcalc)
# path to source directory (note: currently unused)
set(PDCALC_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
# path to test data directory
set(PDCALC_TEST_DATA_DIR ${CMAKE_CURRENT_SOURCE_DIR}/data)

include(CTest)

# relative include for the version header + extra helper
set(PDCALC_VERSION_H include/pdcalc/version.h)
# generate version header. for multi-config, need a pre-build command
# FIXME: this will be repurposed for config.hh which is per-config and internal
if(PDCALC_IS_MULTI_CONFIG)
    add_custom_target(
        pdcalc_version_h
        COMMAND
            ${CMAKE_COMMAND}
                -DPDCALC_VERSION_H_IN=${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_VERSION_H}.in
                -DPDCALC_VERSION_H=${PDCALC_BINARY_DIR}/$<CONFIG>/${PDCALC_VERSION_H}
                -DPDCALC_MAJOR_VERSION=${PDCALC_MAJOR_VERSION}
                -DPDCALC_MINOR_VERSION=${PDCALC_MINOR_VERSION}
                -DPDCALC_PATCH_VERSION=${PDCALC_PATCH_VERSION}
                -DPDCALC_VERSION=${PDCALC_VERSION}
                -DPDCALC_BUILD_TYPE=$<CONFIG>
                -DPDCALC_SYSTEM_NAME=${PDCALC_SYSTEM_NAME}
                -DPDCALC_SYSTEM_VERSION=${PDCALC_SYSTEM_VERSION}
                -DPDCALC_SYSTEM_ARCH=${PDCALC_SYSTEM_ARCH}
                -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/pdcalc_config_version.cmake
        BYPRODUCTS ${PDCALC_BINARY_DIR}/$<CONFIG>/${PDCALC_VERSION_H}
        COMMENT "Generating $<CONFIG> ${PDCALC_VERSION_H}"
        VERBATIM
        SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_VERSION_H}.in
    )
# otherwise, a standard configure_file is enough
else()
    configure_file(
        ${PDCALC_VERSION_H}.in ${PDCALC_VERSION_H}
        @ONLY NEWLINE_STYLE LF
    )
    message(STATUS "Generated ${PDCALC_VERSION_H}")
endif()

# build-private include dirs. for multi-config there is per-config subdir
if(PDCALC_IS_MULTI_CONFIG)
    include_directories(${PDCALC_BINARY_DIR}/$<CONFIG>/include)
else()
    include_directories(${PDCALC_BINARY_DIR}/include)
endif()

# add src, add test only if Google Test is found
add_subdirectory(src)

if(GTest_FOUND)
    add_subdirectory(test)
else()
    message(STATUS "Skipping tests as Google Test ${GTest_VERSION} was not found")
endif()
