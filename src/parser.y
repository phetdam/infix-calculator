/**
 * parser.y
 *
 * Author: Derek Huang
 * Summary: pdcalc C++ Bison grammar
 * Copyright: MIT License
 */

%{
    #include <ios>
    #include <iostream>

    #include "pdcalc/lexer.h"
%}

/* C++ LR parser using variants.
 *
 * Requiring Bison 3.2 stops unnecessary stack.hh generation.
 */
%require "3.2"
%language "c++"
%define api.value.type variant

/* Token definitions */
%token <double> FLOATING
/* TODO: INTEGRAL unused */
%token <long> INTEGRAL
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
%left "==" "!="
%left "<<" ">>"
%left "+" "-"
%left "*" "/" "%"

/* Non-terminal type declarations.
 *
 * TODO: Add i_expr and implement rules.
 *
 * b_expr -- Boolean expression (bool)
 * d_expr -- Float arithmetic expression (double)
 * i_expr -- Integral arithmetic expression (long)
 */
%nterm <double> d_expr
%nterm <bool> b_expr

%%

/* input rule */
input:
  %empty
| input line

/* line rule */
line:
  "\n"
| d_expr "\n"   { std::cout << $1 << std::endl; }
| b_expr "\n"   {
                  std::cout << std::boolalpha << $1 << std::noboolalpha <<
                    std::endl;
                }

/* TODO: integral expression rule */

/* Float arithmetic expression rule */
d_expr:
  FLOATING                            { $$ = $1; }
| "(" d_expr[expr] ")"              { $$ = $expr; }
| d_expr[left] "+" d_expr[right]    { $$ = $left + $right; }
| d_expr[left] "-" d_expr[right]    { $$ = $left - $right; }
| d_expr[left] "*" d_expr[right]    { $$ = $left * $right; }
| d_expr[left] "/" d_expr[right]    { $$ = $left / $right; }

/* Boolean expression rule */
b_expr:
  TRUTH                               { $$ = $1; }
| "(" b_expr[expr] ")"                { $$ = $expr; }
| d_expr[left] "==" d_expr[right]     { $$ = ($left == $right); }
| d_expr[left] "!=" d_expr[right]     { $$ = ($left != $right); }
/* TODO: add additional truth-testing for d_expr */
| b_expr[left] "==" b_expr[right]     { $$ = ($left == $right); }
| b_expr[left] "!=" b_expr[right]     { $$ = ($left != $right); }

%%

namespace yy {

/**
 * User-defined error handler.
 *
 * Currently, all it does is print the exception message.
 *
 * @param message Bison exception error message
 */
void parser::error(const std::string& message)
{
  std::cerr << "Error: " << message << std::endl;
}

}  // namespace yy
