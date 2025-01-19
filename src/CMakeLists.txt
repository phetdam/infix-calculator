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

# generate parser using Bison. header goes to include dir, source to src dir
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_PARSER_SOURCE}
    COMMAND
        # TODO: use no-precedence until all operators are defined
        ${PDCALC_BISON} -Wall -Wno-precedence
            # use historical --defines for Bison 3.5.1. Bison requires that the
            # header is in the same directory as the generated source, so after
            # generation, we then copy the header to the include dir
            --defines=${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_PARSER_HEADER}
            -o ${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_PARSER_SOURCE}
            ${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_PARSER_INPUT}
    COMMAND
        ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_PARSER_HEADER}
            ${PDCALC_NAMESPACE_INCLUDE_DIR}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_PARSER_INPUT}
    COMMENT "Running Bison to build parser ${PDCALC_PARSER_SOURCE}"
    VERBATIM
)
# generate scanner using Flex. source goes to src dir
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_LEXER_SOURCE}
    # don't define yywrap, just assume EOF is end of input. note Flex input
    # sets never-interactive as without it, isatty() is still used to handle
    # interactive input and will result in -Wimplicit-function-declaration.
    # also no need for bison-bridge if we are using the C++ Bison parser.
    COMMAND
        ${PDCALC_FLEX} -CFe --noyywrap --nounistd --warn
            -o ${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_LEXER_SOURCE}
            ${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_LEXER_INPUT}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_LEXER_INPUT}
    COMMENT "Running Flex to build lexer ${PDCALC_LEXER_SOURCE}"
    VERBATIM
)
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
        ${PDCALC_LEXER_SOURCE}
        ${PDCALC_PARSER_SOURCE}
        calc_parser.cc
        calc_parser_impl.cc
)
set_target_properties(
    pdcalc_lib PROPERTIES
        OUTPUT_NAME pdcalc
        DEFINE_SYMBOL PDCALC_BUILD_DLL
)
# include directories interface changes based on build vs. install
target_include_directories(
    pdcalc_lib PUBLIC
    $<BUILD_INTERFACE:${PDCALC_INCLUDE_DIR}>
    $<INSTALL_INTERFACE:include>
)
# pdcalc CLI frontend
add_executable(pdcalc_bin main.cc)
target_link_libraries(pdcalc_bin PRIVATE pdcalc_lib)
set_target_properties(pdcalc_bin PROPERTIES OUTPUT_NAME pdcalc)
