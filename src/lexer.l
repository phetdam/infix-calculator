/**
 * lexer.l
 *
 * Author: Derek Huang
 * Summary: pdcalc C++ Flex input
 * Copyright: MIT License
 */

/* Lexer is never going to be used interactively but is non-reetrant. We don't
 * generate the input() and yyunput() functions since it will not be
 * interactive and must make lexer non-reentrant to work with C++ Bison parser.
 */
%option noinput nounput never-interactive

%{
    #include <stdio.h>

    // MSVC complains that stdint.h is redefining fixed-width integral type
    // macros like INT8_MIN, UINT32_MAX, etc. so disable this warning
    #ifdef _MSC_VER
    #pragma warning (push)
    #pragma warning (disable: 4005)
    #endif  // _MSC_VER

    #include <string>

    #ifdef _MSC_VER
    #pragma warning (pop)
    #endif  // _MSC_VER

    #include "pdcalc/parser.h"

    /**
     * Standard action for a token that echoes it to stdout.
     */
    #define PDCALC_ECHO_TOKEN() printf("A %s\n", yytext)
%}

/* Token definitions */

DIGIT          [0-9]
CHAR           [a-zA-Z]
CHARS          {CHAR}+
MAYBE_CHARS    {CHAR}*
ALNUM          [a-zA-Z0-9]
ALNUMS         {ALNUM}+
MAYBE_ALNUMS   {ALNUM}*
DIGITS         {DIGIT}+
MAYBE_DIGITS   {DIGIT}*
INT            [-+]?{DIGITS}
/* Note that we allow a trailing . here */
FLOAT          {INT}"."{MAYBE_DIGITS}
IDEN           ({CHAR}|_)+({ALNUM}|_)*
/* If we implement commands in the REPL */
COMMAND        @{IDEN}
WHITESPACE     [ \t\r\n]+
LPAREN         "("
RPAREN         ")"


/* Rules */

%%

{INT}           printf("An integer: %s (%ld)\n", yytext, std::stol(yytext));
{FLOAT}         {
                  printf("A float: %s (%g)\n", yytext, std::stod(yytext));
                  // return yy::parser::make_FLOATING(std::stod(yytext));
                }
{COMMAND}       printf("A command name: %s\n", yytext);
{WHITESPACE}
{IDEN}          printf("An identifier: %s\n", yytext);
{LPAREN}        PDCALC_ECHO_TOKEN();
{RPAREN}        PDCALC_ECHO_TOKEN();
"="             PDCALC_ECHO_TOKEN();
.               printf("Unrecognized: %s\n", yytext);
