cmake_minimum_required(VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})

# add Google Test unit test runner
if(GTest_FOUND)
    add_subdirectory(pdcalc_test)
else()
    message(
        STATUS
        "Skipping pdcalc_test (requires Google Test ${PDCALC_GTEST_VERSION})"
    )
endif()

# test installation dir for test_install tests
set(_test_install_dir ${PDCALC_BINARY_DIR}/test_install)

# pre-install test to remove the previously written test install directory.
# this is to ensure pdcalc_test_install does a clean install each time
pdcalc_add_rmdir_test(
    pdcalc_prepare_test_install ${_test_install_dir}
    SETUP test_install_clean
)

# test that the install command works properly
if(PDCALC_IS_MULTI_CONFIG)
    add_test(
        NAME pdcalc_test_install
        COMMAND ${CMAKE_COMMAND}
                --install ${PDCALC_BINARY_DIR}
                --prefix ${_test_install_dir}
                --config $<CONFIG>
    )
else()
    add_test(
        NAME pdcalc_test_install
        COMMAND ${CMAKE_COMMAND}
                --install ${PDCALC_BINARY_DIR} --prefix ${_test_install_dir}
    )
endif()
# pdcalc_test_install sets up the test_install fixture and depends on the
# test_install_clean fixture so it runs *after* pdcalc_prepare_test_install
set_tests_properties(
    pdcalc_test_install PROPERTIES
    FIXTURES_SETUP test_install
    FIXTURES_REQUIRED test_install_clean
)

# test project build dir for CMake usage tests
set(_test_cmake_binary_dir ${PDCALC_BINARY_DIR}/test_cmake_usage)

# pre-CMake config test to remove the previously written CMake test directory.
# this is to ensure pdcalc_cmake_config_test does a clean config each time
# note: this can be done in parallel to the install dir cleanup
pdcalc_add_rmdir_test(
    pdcalc_prepare_cmake_usage ${_test_cmake_binary_dir}
    SETUP test_cmake_clean
)

# test that an external project can run a CMake configure step successfully
add_test(
    NAME pdcalc_cmake_config_test
    COMMAND ${CMAKE_COMMAND}
            -S ${CMAKE_CURRENT_SOURCE_DIR}/pdcalc_cmake_usage_test
            -B ${_test_cmake_binary_dir}
            -Dpdcalc_ROOT=${_test_install_dir}
            -DPDCALC_FIND_VERSION=${PROJECT_VERSION}
)
# test_install fixture must be set up already
set_tests_properties(
    pdcalc_cmake_config_test PROPERTIES
    FIXTURES_SETUP test_cmake_config
    FIXTURES_REQUIRED "test_install;test_cmake_clean"
)

# test that an external project can build with CMake successfully
# for multi-config --config is required
if(PDCALC_IS_MULTI_CONFIG)
    add_test(
        NAME pdcalc_cmake_build_test
        COMMAND ${CMAKE_COMMAND}
                --build ${_test_cmake_binary_dir} --config $<CONFIG> -j
    )
# for single-config, we test that default config works
else()
    add_test(
        NAME pdcalc_cmake_build_test
        COMMAND ${CMAKE_COMMAND} --build ${_test_cmake_binary_dir} -j
    )
endif()
# CMake build requires CMake config has completed + has its own fixture
set_tests_properties(
    pdcalc_cmake_build_test PROPERTIES
    FIXTURES_SETUP test_cmake_build
    FIXTURES_REQUIRED test_cmake_config
)

# test that an external project can run tests using pdcalc with CTest
# note: using verbose output by default
if(PDCALC_IS_MULTI_CONFIG)
    add_test(
        NAME pdcalc_cmake_ctest_test
        # FIXME: --test-dir requires CMake 3.20 so we need a higher min version
        COMMAND ${CMAKE_CTEST_COMMAND}
                --test-dir ${_test_cmake_binary_dir} -C $<CONFIG> -V
    )
else()
    add_test(
        NAME pdcalc_cmake_ctest_test
        COMMAND ${CMAKE_CTEST_COMMAND} --test-dir ${_test_cmake_binary_dir} -V
    )
endif()
# CTest testing requires CMake config (implicit) + build has completed
set_tests_properties(
    pdcalc_cmake_ctest_test PROPERTIES
    FIXTURES_REQUIRED test_cmake_build
)
