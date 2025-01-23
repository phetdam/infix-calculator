cmake_minimum_required(VERSION 3.15)

##
# pdcalc_target_helpers.cmake
#
# CMake module with some project-specific helpers.
#

##
# Add a CTest test that removes the specified directory.
#
# The test can be optionally used to define a setup/cleanup test fixture.
#
# Arguments:
#   test_name
#       CTest test name
#   dir_path
#       Absolute directory path to remove
#   [SETUP setup_fixture]
#       Register the test as a setup step for the fixture
#   [CLEANUP cleanup_fixture]
#       Register the test as as cleanup step for the fixture
#
function(pdcalc_add_rmdir_test test_name dir_path)
    # parse keyword arguments
    set(keyword_args SETUP CLEANUP)
    cmake_parse_arguments(_arg "" "${keyword_args}" "" ${ARGN})
    # error if keyword are missing args
    if(DEFINED _arg_KEYWORDS_MISSING_VALUES)
        message(FATAL_ERROR "Keyword ${_arg_KEYWORDS_MISSING_VALUES} missing value")
    endif()
    # note: cmake -E rm is preferred for CMake 3.17
    if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.17)
        add_test(
            NAME ${test_name}
            # note: using -f to ensure success if dir_path doesn't exist
            COMMAND ${CMAKE_COMMAND} -E rm -rf ${dir_path}
        )
    else()
        message(
            WARNING
            "${test_name} using cmake -E remove_directory instead "
    "of the preferred cmake -E rm -rf as CMake version is ${CMAKE_VERSION} < 3.17"
        )
        add_test(
            NAME ${test_name}
            COMMAND ${CMAKE_COMMAND} -E remove_directory ${dir_path}
        )
    endif()
    # if SETUP provided, register as fixture setup test
    if(DEFINED _arg_SETUP)
        set_tests_properties(${test_name} PROPERTIES FIXTURES_SETUP ${_arg_SETUP})
    endif()
    # if CLEANUP provided, register as fixture cleanup test
    if(DEFINED _arg_CLEANUP)
        set_tests_properties(
            ${test_name} PROPERTIES
            FIXTURES_CLEANUP ${_arg_CLEANUP}
        )
    endif()
endfunction()
