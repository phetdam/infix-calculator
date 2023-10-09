cmake_minimum_required(VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})

add_executable(pdcalc_test calc_parser_test.cc)
# currently, only calc_parser_test.cc needs the PDCALC_TEST_DATA_DIR definition
set_source_files_properties(
    calc_parser_test.cc PROPERTIES
    COMPILE_DEFINITIONS PDCALC_TEST_DATA_DIR="${PDCALC_TEST_DATA_DIR}"
)
target_link_libraries(pdcalc_test PRIVATE GTest::gtest_main pdcalc_lib)
