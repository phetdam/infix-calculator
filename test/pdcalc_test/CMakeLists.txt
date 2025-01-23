cmake_minimum_required(VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})

# pdcalc_test: pdcalc unit test runner
add_executable(pdcalc_test calc_parser_test.cc)
# currently, only calc_parser_test.cc needs the PDCALC_TEST_DATA_DIR definition
set_source_files_properties(
    calc_parser_test.cc PROPERTIES
    COMPILE_DEFINITIONS PDCALC_TEST_DATA_DIR="${PDCALC_TEST_DATA_DIR}"
)
target_link_libraries(pdcalc_test PRIVATE GTest::gtest_main pdcalc_lib)
# Windows-specific configuration
if(WIN32)
    # Google Test fixture classes cause MSVC to emit these warnings with /Wall on
    target_compile_options(
        pdcalc_test
        PRIVATE
            # copy ctor implicitly defined as deleted
            /wd4625
            # move ctor implicitly defined as deleted
            /wd5026
    )
    # need to copy dependent DLLs to build directory on Win32
    if(BUILD_SHARED_LIBS)
        add_custom_command(
            TARGET pdcalc_test POST_BUILD
            COMMAND
                ${CMAKE_COMMAND} -E copy_if_different
                    $<TARGET_RUNTIME_DLLS:pdcalc_test>
                    $<TARGET_FILE_DIR:pdcalc_test>
            COMMAND_EXPAND_LISTS
        )
    endif()
endif()

# make Google Test tests known to CTest
gtest_discover_tests(pdcalc_test)
