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
