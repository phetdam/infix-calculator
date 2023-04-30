/**
 * parser.y
 *
 * Author: Derek Huang
 * Summary: pdcalc C++ Bison grammar
 * Copyright: MIT License
 */

%{
    #include "pdcalc/lexer.h"
%}

/* C++ using variants. 3.2 gets stops stack.hh generation. */
%require "3.2"
%language "c++"
%define api.value.type variant

/* Token definitions */
%token <double> NUMBER
/* TODO: not implemented */
%token <bool> TRUTH
%token PIPE "|"
%token CARET "^"
%token AMPERSAND "&"
%token LSHIFT "<<"
%token RSHIFT ">>"
%token PLUS "+"
%token MINUS "-"
%token STAR "*"
%token SLASH "/"
%token PERCENT "%"

/* Associativity and precedence declarations (C-style) */
%left "|"
%left "^"
%left "&"
%left "<<" ">>"
%left "+" "-"
%left "*" "/" "%"

%%

/* input rule */
input:
  %empty
| input line

/* line rule. TODO: make rule actually useful*/
line:
  "\n"
| NUMBER "\n"

%%

namespace yy {

/**
 * Do-nothing error handler user must define.
 *
 * @param message Bison exception error message
 */
void parser::error(const std::string& message) {}

}  // namespace yy
