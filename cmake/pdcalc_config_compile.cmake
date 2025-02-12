cmake_minimum_required(VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})

##
# pdcalc_config_compile.cmake
#
# Provides a macro to set build configuration and compiler-specific options.
#

##
# Set project-wide private compile/link options.
#
macro(pdcalc_config_compile)
    if(MSVC)
        # stop MSVC from warning about unsafe functions, C is unsafe by nature
        add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
        # CMake adds /O2 by default for release version, /Od for debug
        add_compile_options(
            /Wall
            # enumerator not explicitly handled by case label (parser.yy.h)
            /wd4061
            # switch with default but no labels (parser.yy.h)
            /wd4065
            # unreferenced inline function removed
            /wd4514
            # copy/move assignment operators implicitly defined as deleted
            /wd4626 /wd5027
            # function not inlined + function selected for inline expansion
            /wd4710 /wd4711
            # silence warning about padding
            /wd4820
            # insertion of Spectre mitigation if using /QSpectre
            /wd5045
        )
        # enable AddressSanitizer. note that AddressSanitizer does not seem to
        # integrate well with Google Test, so unit test runners may have issues
        # TODO: set CMake option for this and print on/off status up front
        if(ENABLE_ASAN)
            message(STATUS "Enabling AddressSanitizer (/fsanitize=address)")
            add_compile_options(/fsanitize=address)
        endif()
    # GCC/Clang for *nix systems
    else()
        # CMake adds -g by default for debug builds
        add_compile_options(-Wall $<$<NOT:$<CONFIG:Debug>>:-O3>)
        # enable AddressSanitizer
        if(ENABLE_ASAN)
            message(STATUS "Enabling AddressSanitizer (-fsanitize=address)")
            add_compile_options(-fsanitize=address)
            add_link_options(-fsanitize=address)
        endif()
    endif()
endmacro()
