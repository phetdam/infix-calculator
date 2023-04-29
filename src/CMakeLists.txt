cmake_minimum_required(VERSION ${CMAKE_MINIMUM_REQUIRED_VERSION})

# file prefixes and names for the lexer and parser
set(PDCALC_LEXER_PREFIX lexer)
set(PDCALC_LEXER_INPUT ${PDCALC_LEXER_PREFIX}.l)
set(PDCALC_LEXER_HEADER ${PDCALC_LEXER_PREFIX}.yy.h)
set(PDCALC_LEXER_SOURCE ${PDCALC_LEXER_PREFIX}.yy.c)
set(PDCALC_PARSER_PREFIX parser)
set(PDCALC_PARSER_SOURCE ${PDCALC_PARSER_PREFIX}.yy.c)

# generate scanner using Flex. header goes to include dir, source to src dir
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_LEXER_SOURCE}
    # TODO: add --bison-bridge to work with Bison parser
    # don't define yywrap, just assume EOF is end of input. --nounistd without
    # --never-interactive means isatty() is still used to handle interactive
    # input and will result in -Wimplicit-function-declaration.
    COMMAND
        ${PDCALC_FLEX} -R -CFe --noyywrap --nounistd --warn --never-interactive
            --header-file=${PDCALC_NAMESPACE_INCLUDE_DIR}/${PDCALC_LEXER_HEADER}
            -o ${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_LEXER_SOURCE}
            ${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_LEXER_INPUT}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${PDCALC_LEXER_INPUT}
    COMMENT "Running Flex to build lexer ${PDCALC_LEXER_SOURCE}"
    VERBATIM
)
add_executable(pdcalc main.cc ${PDCALC_LEXER_SOURCE})
