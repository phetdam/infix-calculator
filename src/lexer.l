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

/* Start conditions */

/* Python-style "#" comment */
%x LINE_COMMENT

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
INT            -?{DIGITS}
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

{INT}                   return yy::parser::make_INTEGRAL(std::stol(yytext));
{FLOAT}                 return yy::parser::make_FLOATING(std::stod(yytext));
"+"                     return yy::parser::make_PLUS();
"-"                     return yy::parser::make_MINUS();
"*"                     return yy::parser::make_STAR();
"/"                     return yy::parser::make_SLASH();
"%"                     return yy::parser::make_PERCENT();
"|"                     return yy::parser::make_PIPE();
"&"                     return yy::parser::make_AMPERSAND();
"^"                     return yy::parser::make_CARET();
"~"                     return yy::parser::make_TILDE();
"<<"                    return yy::parser::make_LSHIFT();
">>"                    return yy::parser::make_RSHIFT();
"true"                  return yy::parser::make_TRUTH(true);
"false"                 return yy::parser::make_TRUTH(false);
";"                     return yy::parser::make_SEMICOLON();
"!"                     return yy::parser::make_NOT();
"#"                     BEGIN(LINE_COMMENT);
<LINE_COMMENT>[^\n]*
<LINE_COMMENT>\n        BEGIN(INITIAL);
  /* {COMMAND}               printf("A command name: %s\n", yytext); */
{WHITESPACE}
  /*{IDEN}                  printf("An identifier: %s\n", yytext); */
"("                     return yy::parser::make_LPAREN();
")"                     return yy::parser::make_RPAREN();
"=="                    return yy::parser::make_EQUALS();
"!="                    return yy::parser::make_NOT_EQUALS();
.                       {
                          throw yy::parser::syntax_error{
                            "Unrecognized token '" + std::string{yytext} + '"'
                          };
                        }
