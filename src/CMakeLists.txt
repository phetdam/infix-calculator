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
# MSVC complains that a conditional expression in the Bison-generated parser
# source is constant, so we silence it just for this source file
if(MSVC)
    set_source_files_properties(
        ${PDCALC_PARSER_SOURCE} PROPERTIES
        COMPILE_OPTIONS "/wd4127"
    )
endif()
add_executable(pdcalc main.cc ${PDCALC_LEXER_SOURCE} ${PDCALC_PARSER_SOURCE})
