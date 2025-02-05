cmake_minimum_required(VERSION 3.16)

# see README.rst for build instructions

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
# indicate build is a true release build, e.g. don't append build info
option(PDCALC_IS_RELEASE "Indicate build is a true release build" OFF)

# find Git for version info
find_package(Git)
if(Git_FOUND)
    message(STATUS "Git version: ${GIT_VERSION_STRING}")
else()
    message(STATUS "Git version: None")
endif()
# no build tag if release
if(PDCALC_IS_RELEASE)
    set(PDCALC_VERSION_INFO "")
    message(STATUS "Build tag: None")
# otherwise, use Git to determine if possible
elseif(Git_FOUND)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-list --max-count=1 --abbrev-commit HEAD
        TIMEOUT 5
        RESULT_VARIABLE _cur_rev_res
        OUTPUT_VARIABLE _cur_rev
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # failed
    if(_cur_rev_res)
        message(WARNING "git rev-list failed; using -DEV as build tag")
    # otherwise, use + print output
    else()
        set(PDCALC_VERSION_INFO "-${_cur_rev}")
        message(STATUS "Build tag: ${PDCALC_VERSION_INFO}")
    endif()
    # unset temps
    unset(_cur_rev_res)
    unset(_cur_rev)
endif()
# if build tag not defined (e.g. no Git, rev-list failed) set to -DEV and print
if(NOT DEFINED PDCALC_VERSION_INFO)
    set(PDCALC_VERSION_INFO "-DEV")
    message(STATUS "Build tag: ${PDCALC_VERSION_INFO}")
endif()

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

# find Flex and Bison
find_package(FLEX 2.6.2 REQUIRED)
message(STATUS "Flex version: ${FLEX_VERSION}")
find_package(BISON 3.5.1 REQUIRED)
message(STATUS "Bison version: ${BISON_VERSION}")
# find Doxygen
find_package(Doxygen 1.9.0)
if(Doxygen_FOUND)
    message(STATUS "Doxygen version: ${DOXYGEN_VERSION}")
else()
    message(STATUS "Doxygen version: None")
endif()
# find Google Test version >= than min. requested version
set(PDCALC_GTEST_VERSION)
find_package(GTest ${PDCALC_GTEST_VERSION})
if(GTest_FOUND)
    message(STATUS "Google Test version: ${GTest_VERSION}")
else()
    message(STATUS "Google Test version: None")
endif()

# set CMake module path
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
# compiler options config + target helpers
include(pdcalc_config_compile)
include(pdcalc_target_helpers)

# configure compile options
pdcalc_config_compile()

# set some variables used for the version + config info
set(PDCALC_MAJOR_VERSION ${PROJECT_VERSION_MAJOR})
set(PDCALC_MINOR_VERSION ${PROJECT_VERSION_MINOR})
set(PDCALC_PATCH_VERSION ${PROJECT_VERSION_PATCH})
set(PDCALC_VERSION ${PROJECT_VERSION}${PDCALC_VERSION_INFO})
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

include(CMakePackageConfigHelpers)
include(CTest)

# relative include for the config header
set(PDCALC_CONFIG_HH include/pdcalc/config.hh)
# generate version header. for multi-config, need a pre-build command
if(PDCALC_IS_MULTI_CONFIG)
    add_custom_target(
        pdcalc_config_hh
        COMMAND
            ${CMAKE_COMMAND}
                -DPDCALC_CONFIG_HH_IN=${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_CONFIG_HH}.in
                -DPDCALC_CONFIG_HH=${PDCALC_BINARY_DIR}/$<CONFIG>/${PDCALC_CONFIG_HH}
                -DPDCALC_BUILD_TYPE=$<CONFIG>
                -DPDCALC_SYSTEM_NAME=${PDCALC_SYSTEM_NAME}
                -DPDCALC_SYSTEM_VERSION=${PDCALC_SYSTEM_VERSION}
                -DPDCALC_SYSTEM_ARCH=${PDCALC_SYSTEM_ARCH}
                -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/pdcalc_generate_config.cmake
        BYPRODUCTS ${PDCALC_BINARY_DIR}/$<CONFIG>/${PDCALC_CONFIG_HH}
        COMMENT "Generating $<CONFIG> ${PDCALC_CONFIG_HH}"
        VERBATIM
        SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_CONFIG_HH}.in
    )
# otherwise, a standard configure_file is enough
else()
    configure_file(
        ${PDCALC_CONFIG_HH}.in ${PDCALC_CONFIG_HH}
        @ONLY NEWLINE_STYLE LF
    )
    message(STATUS "Generated ${PDCALC_CONFIG_HH}")
endif()

# relative include for the version header
set(PDCALC_VERSION_H include/pdcalc/version.h)
# configure the public version header file
configure_file(${PDCALC_VERSION_H}.in ${PDCALC_VERSION_H} @ONLY NEWLINE_STYLE LF)
message(STATUS "Generated ${PDCALC_VERSION_H}")

# build-private include dirs. for multi-config we add the per-config subdir
# before the build root include so that the per-config includes have priority
if(PDCALC_IS_MULTI_CONFIG)
    include_directories(${PDCALC_BINARY_DIR}/$<CONFIG>/include)
endif()
# both single- and multi-config generators may have config-independent includes
include_directories(${PDCALC_BINARY_DIR}/include)

# CMake files relative install prefix
set(PDCALC_CMAKE_PREFIX lib/cmake/pdcalc)

# add src, test (only some tests use Google Test)
add_subdirectory(src)
add_subdirectory(test)

# configure package config file
# note: won't change across build configs so we just put in top-level
set(PDCALC_CONFIG_FILE pdcalc-config.cmake)
configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/${PDCALC_CONFIG_FILE}.in
    ${CMAKE_CURRENT_BINARY_DIR}/${PDCALC_CONFIG_FILE}
    INSTALL_DESTINATION ${PDCALC_CMAKE_PREFIX}
)
# configure version selection file
set(PDCALC_CONFIG_VERSION_FILE pdcalc-config-version.cmake)
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/${PDCALC_CONFIG_VERSION_FILE}
    VERSION ${PDCALC_VERSION}
    COMPATIBILITY AnyNewerVersion
)
# install rule for the config and version config files
install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/${PDCALC_CONFIG_FILE}
        ${CMAKE_CURRENT_BINARY_DIR}/${PDCALC_CONFIG_VERSION_FILE}
    DESTINATION ${PDCALC_CMAKE_PREFIX}
)
