cmake_minimum_required(VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})

##
# Find Flex + Bison paths given path(s) to the Flex + Bison binary directories.
#
# These can also be set as environment variables.
#

# set directory containing Flex/Bison executables. for example, if using
# WinFlexBison on Windows, set this to the path of the release directory
if(DEFINED ENV{PDCALC_FLEX_BISON_DIR})
    message(
        STATUS
        "Using PDCALC_FLEX_BISON_DIR $ENV{PDCALC_FLEX_BISON_DIR} from env"
    )
    set(PDCALC_FLEX_BISON_DIR $ENV{PDCALC_FLEX_BISON_DIR})
endif()
# can be left undefined if Flex + Bison are on system PATH
if(NOT DEFINED PDCALC_FLEX_BISON_DIR)
    message(STATUS "PDCALC_FLEX_BISON_DIR not defined, treating as empty")
    set(PDCALC_FLEX_BISON_DIR "")
else()
    message(STATUS "PDCALC_FLEX_BISON_DIR detected: ${PDCALC_FLEX_BISON_DIR}")
endif()
# set independent directory locations for Flex/Bison. these take the value of
# PDCALC_FLEX_BISON_DIR if it is not empty and they are not explicitly defined.
if(DEFINED ENV{PDCALC_FLEX_DIR})
    message(STATUS "Using PDCALC_FLEX_DIR $ENV{PDCALC_FLEX_DIR} from env")
    set(PDCALC_FLEX_DIR $ENV{PDCALC_FLEX_DIR})
endif()
# can be left undefined and use PDCALC_FLEX_BISON_DIR or be left empty
if(NOT DEFINED PDCALC_FLEX_DIR)
    if(DEFINED PDCALC_FLEX_BISON_DIR)
        message(
            STATUS
            "PDCALC_FLEX_DIR not defined, using PDCALC_FLEX_BISON_DIR "
"(${PDCALC_FLEX_BISON_DIR})"
        )
        set(PDCALC_FLEX_DIR ${PDCALC_FLEX_BISON_DIR})
    else()
        message(STATUS "PDCALC_FLEX_DIR not defined, treating as empty")
        set(PDCALC_FLEX_DIR "")
    endif()
else()
    message(STATUS "PDCALC_FLEX_DIR detected: ${PDCALC_FLEX_DIR}")
endif()
if(DEFINED ENV{PDCALC_BISON_DIR})
    message(STATUS "Using PDCALC_BISON_DIR $ENV{PDCALC_BISON_DIR} from env")
    set(PDCALC_BISON_DIR $ENV{PDCALC_BISON_DIR})
endif()
# can be left undefined and use PDCALC_FLEX_BISON_DIR or be left empty
if(NOT DEFINED PDCALC_BISON_DIR)
    if(DEFINED PDCALC_FLEX_BISON_DIR)
        message(
            STATUS
            "PDCALC_BISON_DIR not defined, using PDCALC_FLEX_BISON_DIR "
"(${PDCALC_FLEX_BISON_DIR})"
        )
        set(PDCALC_BISON_DIR ${PDCALC_FLEX_BISON_DIR})
    else()
        message(STATUS "PDCALC_BISON_DIR not defined, treating as empty")
        set(PDCALC_BISON_DIR "")
    endif()
else()
    message(STATUS "PDCALC_BISON_DIR detected: ${PDCALC_BISON_DIR}")
endif()
# find Flex and Bison. don't proceed if we have failed
find_program(PDCALC_FLEX NAMES flex win_flex HINTS ${PDCALC_FLEX_DIR})
if(PDCALC_FLEX STREQUAL "PDCALC_FLEX-NOTFOUND")
    message(
        FATAL_ERROR
        "Failed to find Flex. Please set PDCALC_FLEX_BISON_DIR or "
"PDCALC_FLEX_DIR"
    )
else()
    message(STATUS "Found Flex: ${PDCALC_FLEX}")
endif()
find_program(PDCALC_BISON NAMES bison win_bison HINTS ${PDCALC_BISON_DIR})
if(PDCALC_BISON STREQUAL "PDCALC_BISON-NOTFOUND")
    message(
        FATAL_ERROR
        "Failed to find Bison. Please set PDCALC_FLEX_BISON_DIR or "
"PDCALC_BISON_DIR"
    )
else()
    message(STATUS "Found Bison: ${PDCALC_BISON}")
endif()
