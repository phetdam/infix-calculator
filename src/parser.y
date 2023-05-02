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

    #include "pdcalc/parser.h"
%}

/* C++ LR parser using variants handling complete symbols with error reporting.
 *
 * Requiring Bison 3.2 stops unnecessary stack.hh generation. For Bison 3.6+,
 * it is better for parse.error to have the value of detailed.
 */
%require "3.2"
%language "c++"
%define api.value.type variant
%define api.token.constructor
%define parse.error verbose

/* Token definitions */
%token <double> FLOATING
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
%token LPAREN "("
%token RPAREN ")"
%token EQUALS "=="
%token NOT "!"
%token NOT_EQUALS "!="
%token SEMICOLON ";"

/* Associativity and precedence declarations (C-style) */
%left "|"
%left "^"
%left "&"
%left "==" "!="
%left "<<" ">>"
%left "+" "-"
%left "*" "/" "%"
%right "!" "~"

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
%nterm <int> i_expr

%%

/* Input rule */
input:
  %empty
| input stmt

/* Statement rule */
stmt:
  ";"           /* empty statement */
| i_expr ";"    { std::cout << "<long>   " << $1 << std::endl; }
| d_expr ";"    { std::cout << "<double> " << $1 << std::endl; }
| b_expr ";"    {
                  std::cout << "<bool>   " << std::boolalpha << $1 <<
                    std::noboolalpha << std::endl;
                }

/* Integral expression rule */
i_expr:
  INTEGRAL                          { $$ = $1; }
| "(" i_expr[expr] ")"              { $$ = $expr; }
| i_expr[left] "+" i_expr[right]    { $$ = $left + $right; }
| i_expr[left] "-" i_expr[right]    { $$ = $left - $right; }
| i_expr[left] "*" i_expr[right]    { $$ = $left * $right; }
| i_expr[left] "/" i_expr[right]    { $$ = $left / $right; }
| i_expr[left] "%" i_expr[right]    { $$ = $left % $right; }
| i_expr[left] "&" i_expr[right]    { $$ = $left & $right; }
| i_expr[left] "^" i_expr[right]    { $$ = $left ^ $right; }
| i_expr[left] "|" i_expr[right]    { $$ = $left | $right; }
| "~" i_expr[expr]                  { $$ = ~$expr; }

/* Float arithmetic expression rule */
d_expr:
  FLOATING                          { $$ = $1; }
| "(" d_expr[expr] ")"              { $$ = $expr; }
| d_expr[left] "+" d_expr[right]    { $$ = $left + $right; }
| d_expr[left] "-" d_expr[right]    { $$ = $left - $right; }
| d_expr[left] "*" d_expr[right]    { $$ = $left * $right; }
| d_expr[left] "/" d_expr[right]    { $$ = $left / $right; }
/* promoting right i_expr */
| d_expr[left] "+" i_expr[right]    { $$ = $left + $right; }
| d_expr[left] "-" i_expr[right]    { $$ = $left - $right; }
| d_expr[left] "*" i_expr[right]    { $$ = $left * $right; }
| d_expr[left] "/" i_expr[right]    { $$ = $left / $right; }
/* promoting left i_expr */
| i_expr[left] "+" d_expr[right]    { $$ = $left + $right; }
| i_expr[left] "-" d_expr[right]    { $$ = $left - $right; }
| i_expr[left] "*" d_expr[right]    { $$ = $left * $right; }
| i_expr[left] "/" d_expr[right]    { $$ = $left / $right; }

/* Boolean expression rule */
b_expr:
  TRUTH                               { $$ = $1; }
| "(" b_expr[expr] ")"                { $$ = $expr; }
| d_expr[left] "==" d_expr[right]     { $$ = ($left == $right); }
| d_expr[left] "!=" d_expr[right]     { $$ = ($left != $right); }
| i_expr[left] "==" i_expr[right]     { $$ = ($left == $right); }
| i_expr[left] "!=" i_expr[right]     { $$ = ($left != $right); }
/* d_expr left, i_expr right */
| d_expr[left] "==" i_expr[right]     { $$ = ($left == $right); }
| d_expr[left] "!=" i_expr[right]     { $$ = ($left != $right); }
/* i_expr left, d_expr right */
| i_expr[left] "==" d_expr[right]     { $$ = ($left == $right); }
| i_expr[left] "!=" d_expr[right]     { $$ = ($left != $right); }
| b_expr[left] "==" b_expr[right]     { $$ = ($left == $right); }
| b_expr[left] "!=" b_expr[right]     { $$ = ($left != $right); }
| "!" b_expr[expr]                    { $$ = !$expr; }

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
