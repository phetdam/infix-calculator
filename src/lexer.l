/**
 * lexer.l
 *
 * Author: Derek Huang
 * Summary: pdcalc Flex input
 * Copyright: MIT License
 */

/* lexer is never going to be used interactively and is reentrant. we don't
 * generate the input() and yyunput() functions as well for this reason.
 */
%option noinput nounput never-interactive reentrant

%{
    #include <stdio.h>
    #include <stdlib.h>

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
/* note that we allow a trailing . here */
FLOAT          {INT}"."{MAYBE_DIGITS}
IDEN           ({CHAR}|_)+({ALNUM}|_)*
/* if we implement commands in the REPL */
COMMAND        @{IDEN}
WHITESPACE     [ \t\r\n]+
LPAREN         "("
RPAREN         ")"


/* Rules */

%%

{INT}           printf("An integer: %s (%ld)\n", yytext, atol(yytext));
{FLOAT}         printf("A float: %s (%g)\n", yytext, atof(yytext));
{COMMAND}       printf("A command name: %s\n", yytext);
{WHITESPACE}
{IDEN}          printf("An identifier: %s\n", yytext);
{LPAREN}        PDCALC_ECHO_TOKEN();
{RPAREN}        PDCALC_ECHO_TOKEN();
"="             PDCALC_ECHO_TOKEN();
.               printf("Unrecognized: %s\n", yytext);
