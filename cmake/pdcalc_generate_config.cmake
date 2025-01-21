cmake_minimum_required(VERSION 3.13)

##
# pdcalc_generate_config.cmake
#
# This CMake module is intended to be run in script mode as a pre-build step
# for multi-config generators so that each build config gets its own config.hh
# with proper per-config configured variables. Running configure_file once at
# configure time is not sufficient for multi-config generators.
#
# The technique used here has been used before in the xkcd-alt project.
#
# CMake variables consumed that should be externally defined are:
#
#   PDCALC_CONFIG_HH_IN
#   PDCALC_CONFIG_HH
#   PDCALC_BUILD_TYPE
#   PDCALC_SYSTEM_NAME
#   PDCALC_SYSTEM_VERSION
#   PDCALC_SYSTEM_ARCH
#

##
# Helper function to check that a variable is defined and not the empty string.
#
# Arguments:
#   var     Variable name
function(check_version_var var)
    if(NOT DEFINED ${var})
        message(FATAL_ERROR "${var} is not defined")
    endif()
    if(${var} STREQUAL "")
        message(FATAL_ERROR "${var} is the empty string")
    endif()
endfunction()

# run only in script mode
if(CMAKE_SCRIPT_MODE_FILE)
    # check variables
    check_version_var(PDCALC_CONFIG_HH_IN)
    check_version_var(PDCALC_CONFIG_HH)
    check_version_var(PDCALC_BUILD_TYPE)
    check_version_var(PDCALC_SYSTEM_NAME)
    check_version_var(PDCALC_SYSTEM_VERSION)
    check_version_var(PDCALC_SYSTEM_ARCH)
    # both paths should be absolute paths. the output path should be in the
    # build directory (with per-config subdirectory)
    configure_file(
        ${PDCALC_CONFIG_HH_IN} ${PDCALC_CONFIG_HH}
        @ONLY NEWLINE_STYLE LF
    )
endif()
