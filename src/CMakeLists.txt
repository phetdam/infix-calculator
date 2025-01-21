cmake_minimum_required(VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})

# file prefixes and names for the lexer and parser
set(PDCALC_LEXER_PREFIX lexer)
set(PDCALC_LEXER_INPUT ${PDCALC_LEXER_PREFIX}.l)
set(PDCALC_LEXER_HEADER ${PDCALC_LEXER_PREFIX}.yy.h)
set(PDCALC_LEXER_SOURCE ${PDCALC_LEXER_PREFIX}.yy.cc)
set(PDCALC_PARSER_PREFIX parser)
set(PDCALC_PARSER_INPUT ${PDCALC_PARSER_PREFIX}.y)
set(PDCALC_PARSER_HEADER ${PDCALC_PARSER_PREFIX}.yy.h)
set(PDCALC_PARSER_SOURCE ${PDCALC_PARSER_PREFIX}.yy.cc)

# generated lexer/parser files
set(PDCALC_LEXER_OUTPUT ${PDCALC_BINARY_DIR}/src/${PDCALC_LEXER_SOURCE})
set(PDCALC_PARSER_OUTPUT ${PDCALC_BINARY_DIR}/src/${PDCALC_PARSER_SOURCE})
# add targets for lexer and parser + ensure CMake knows parser requires lexer
FLEX_TARGET(
    pdcalc_lexer
    ${PDCALC_LEXER_INPUT} ${PDCALC_LEXER_OUTPUT}
    # don't define yywrap, just assume EOF is end of input. note Flex input
    # sets never-interactive as without it, isatty() is still used to handle
    # interactive input and will result in -Wimplicit-function-declaration.
    # also no need for bison-bridge if we are using the C++ Bison parser.
    COMPILE_FLAGS "-CFe --noyywrap --nounistd --warn"
)
BISON_TARGET(
    pdcalc_parser
    ${PDCALC_PARSER_INPUT} ${PDCALC_PARSER_OUTPUT}
    COMPILE_FLAGS "-Wall -Wno-precedence"
    # note: for Bison 3.5.1, should be using --defines instead of --header
    DEFINES_FILE ${PDCALC_BINARY_DIR}/src/${PDCALC_PARSER_HEADER}
)
ADD_FLEX_BISON_DEPENDENCY(pdcalc_lexer pdcalc_parser)

# MSVC-specific warnings that are generated from generated parser with /Wall on
if(MSVC)
    set_source_files_properties(
        ${PDCALC_PARSER_SOURCE} PROPERTIES
        # C4127: conditional expression is constant
        # C4365: signed/unsigned mismatch
        COMPILE_OPTIONS "/wd4127;/wd4365"
    )
endif()

# pdcalc library implementing parser
add_library(
    pdcalc_lib
        # note: could use FLEX_pdcalc_lexer_OUTPUTS and
        # BISON_pdcalc_parser_OUTPUTS but we only care about the source files
        ${PDCALC_LEXER_OUTPUT}
        ${PDCALC_PARSER_OUTPUT}
        calc_parser.cc
        calc_parser_impl.cc
)
set_target_properties(
    pdcalc_lib PROPERTIES
    # both exported target name and output file are just pdcalc
    EXPORT_NAME pdcalc
    OUTPUT_NAME pdcalc
    DEFINE_SYMBOL PDCALC_BUILD_DLL
    # add "d" suffix for debug libraries
    DEBUG_POSTFIX d
)
# when building shared PDCALC_DLL is part of the compile interface
if(BUILD_SHARED_LIBS)
    target_compile_definitions(pdcalc_lib PUBLIC PDCALC_DLL)
endif()
# if using raw PIMPL then PDCALC_RAW_PIMPL is part of the compile interface
if(PDCALC_RAW_PIMPL)
    target_compile_definitions(pdcalc_lib PUBLIC PDCALC_RAW_PIMPL)
endif()
# need to add current directory to includes for calc_parser_impl.hh and add
# the src subdir of the build root for parser.yy.h
target_include_directories(
    pdcalc_lib PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR} ${PDCALC_BINARY_DIR}/src
)
# include directories interface changes based on build vs. install
target_include_directories(
    pdcalc_lib PUBLIC
    $<BUILD_INTERFACE:${PDCALC_INCLUDE_DIR}>
    $<INSTALL_INTERFACE:include>
)
# for multi-config generators config header generation is a pre-build step
if(PDCALC_IS_MULTI_CONFIG)
    add_dependencies(pdcalc_lib pdcalc_config_hh)
endif()
# set public headers for pdcalc_lib
set(
    PDCALC_PUBLIC_HEADERS
    ${PDCALC_INCLUDE_DIR}/pdcalc/calc_parser.h
    ${PDCALC_INCLUDE_DIR}/pdcalc/common.h
    ${PDCALC_INCLUDE_DIR}/pdcalc/dllexport.h
    ${PDCALC_INCLUDE_DIR}/pdcalc/features.h
    ${PDCALC_BINARY_DIR}/${PDCALC_VERSION_H}
    ${PDCALC_INCLUDE_DIR}/pdcalc/warnings.h
)
set_target_properties(
    pdcalc_lib PROPERTIES
    # must expand as semicolon-separated string
    PUBLIC_HEADER "${PDCALC_PUBLIC_HEADERS}"
)
# installation rule + export installation rule
install(
    TARGETS pdcalc_lib
    EXPORT pdcalc_lib_export
    PUBLIC_HEADER DESTINATION include/pdcalc
)
install(
    EXPORT pdcalc_lib_export
    DESTINATION lib/cmake/pdcalc
    NAMESPACE pdcalc::
    FILE pdcalc-targets.cmake
)

# pdcalc CLI frontend
add_executable(pdcalc_bin main.cc)
target_link_libraries(pdcalc_bin PRIVATE pdcalc_lib)
set_target_properties(pdcalc_bin PROPERTIES OUTPUT_NAME pdcalc)
# installation rule
install(TARGETS pdcalc_bin)
