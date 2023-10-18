cmake_minimum_required(VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})

##
# Set build configuration and compiler-specific options.
#

# if building shared libraries, define PDCALC_DLL
if(BUILD_SHARED_LIBS)
    add_compile_definitions(PDCALC_DLL)
endif()
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
        # assignment + move assignment operator implicitly defined as deleted
        /wd4626 /wd5027
        # silence warning about padding
        /wd4820
        # insertion of Spectre mitigation if using /QSpectre
        /wd5045
    )
    # enable AddressSanitizer. note that AddressSanitizer does not seem to
    # integrate well with Google Test, so unit test runners may have issues
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
# determine if building static or shared library
# use raw instead of STL unique_ptr as the PIMPL class pointer
if(PDCALC_RAW_PIMPL)
    message(STATUS "PIMPL: raw pointer")
    add_compile_definitions(PDCALC_RAW_PIMPL)
else()
    message(STATUS "PIMPL: unique_ptr")
endif()
