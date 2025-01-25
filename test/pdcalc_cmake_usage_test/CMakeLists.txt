cmake_minimum_required(VERSION 3.16)

##
# pdcalcCMakeUsageTest
#
# Simple CMake project to test that pdcalc can be correctly used from CMake.
#
# Tests that using find_package and linking against targets works properly.
#
# External CMake variables required:
#
#   pdcalc_ROOT                 Test installation root directory
#   PDCALC_FIND_VERSION         Requested version to find
#

project(
    pdcalcCMakeUsageTest
    VERSION 0.1.0
    DESCRIPTION "pdcalc CMake usage test"
    LANGUAGES CXX
)

##
# Check if a variable is defined and not false.
#
# Arguments:
#   var     Variable name
#
function(check_var var)
    if(NOT DEFINED ${var})
        message(FATAL_ERROR "${var} not defined")
    endif()
    if(NOT ${var})
        message(FATAL_ERROR "${var} (${${var}}) evaluates to false in if")
    endif()
endfunction()

# check + print root
check_var(pdcalc_ROOT)
check_var(PDCALC_FIND_VERSION)
message(STATUS "pdcalc_ROOT: ${pdcalc_ROOT}")

# find package
find_package(pdcalc ${PDCALC_FIND_VERSION} REQUIRED)
# if not found, error (if found, should be true)
check_var(pdcalc_FOUND)
# should have version and it should be compatible
check_var(pdcalc_VERSION)
if(pdcalc_VERSION VERSION_GREATER PDCALC_FIND_VERSION)
    message(FATAL_ERROR "pdcalc_VERSION ${pdcalc_VERSION} > ${PDCALC_FIND_VERSION}")
endif()
# print version info
message(
    STATUS
    "pdcalc version: ${pdcalc_VERSION} (requested ${PDCALC_FIND_VERSION})"
)

# set C++ standards
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# set compile options
if(MSVC)
    add_compile_options(/Wall)
else()
    add_compile_options(-Wall)
endif()

include(CTest)

# test: add pdcalc library test program
add_executable(pdcalc_demo pdcalc_demo.cc)
target_link_libraries(pdcalc_demo PRIVATE pdcalc::pdcalc)
# on Windows, copy DLL to build directory if necessary
if(WIN32)
    add_custom_command(
        TARGET pdcalc_demo POST_BUILD
        COMMAND ${CMAKE_COMMAND}
                -E copy_if_different
                $<TARGET_RUNTIME_DLLS:pdcalc_demo> $<TARGET_FILE_DIR:pdcalc_demo>
        COMMENT "Copying pdcalc_demo runtime DLLs"
        VERBATIM
        COMMAND_EXPAND_LISTS
    )
endif()

# add CTest test to run the program
add_test(NAME pdcalc_demo_test COMMAND pdcalc_demo)
