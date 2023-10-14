/**
 * parser.y
 *
 * Author: Derek Huang
 * Summary: pdcalc C++ Bison grammar
 * Copyright: MIT License
 */

%{
  // user-defined headers typically should not go first, but this only
  // contains macros used for controlling the warning state
  #include "pdcalc/warnings.h"

  // MSVC reports __STDC_WANT_SECURE_LIB__ not defined in limits.h, which it
  // replaces with an #if 0 for the conditional, so we manually suppress this
  PDCALC_MSVC_WARNING_PUSH()
  PDCALC_MSVC_WARNING_DISABLE(4668)
  #include <ios>
  #include <iostream>
  PDCALC_MSVC_WARNING_POP()

  #include <sstream>

  #include "calc_parser_impl.h"

  /**
   * Assign result of division to a target while handling divide by zero.
   *
   * On error, the parse driver's last error is updated.
   *
   * @note This should only be used from within the Bison-generated parser.
   *
   * @param target Target to assign result to
   * @param left Left operand
   * @param right Right operand
   */
  #define PDCALC_YY_SAFE_DIVIDE(target, left, right) \
    do { \
      if (right) \
        target = (left) / (right); \
      else { \
        error( \
          driver.location_, \
          std::to_string(left) + " / " + std::to_string(right) + \
            " is division by zero" \
        ); \
        YYABORT; \
      } \
    } \
    while (0)

  /**
   * Print an expression truth value to stdout as "true" or "false".
   *
   * @param value Boolean value of an expression
   */
  #define PDCALC_YY_PRINT_BOOL(value) \
    std::cout << "<bool> " << std::boolalpha << (value) << std::noboolalpha << \
      std::endl;
%}

/* C++ LR parser using variants handling complete symbols with error reporting.
 *
 * Location tracking is enabled and as recommended by the Bison documentation,
 * the parser's parse() function takes the pdcalc parse driver as a parameter.
 *
 * Requiring Bison 3.2 stops unnecessary stack.hh generation. For Bison 3.6+,
 * it is better for parse.error to have the value of detailed. Lookahead
 * correction enabled for more accurate error reporting of location. The
 * api.location.file %define is used to prevent location.hh generation.
 */
%require "3.2"
%language "c++"
%define api.value.type variant
%define api.token.constructor
%define parse.error verbose
%define parse.lac full
%define parse.trace
%locations
%define api.location.file none
%param { pdcalc::calc_parser_impl& driver }

/* Token definitions */
%token <double> FLOATING
%token <long> INTEGRAL
%token <bool> TRUTH
%token PIPE "|"
%token CARET "^"
%token AMPERSAND "&"
%token TILDE "~"
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
%token AND "&&"
%token OR "||"
%token NOT "!"
%token LANGLE "<"
%token RANGLE ">"
%token LEQUALS "<="
%token GEQUALS ">="
%token NOT_EQUALS "!="
%token SEMICOLON ";"

/* Associativity and precedence declarations (C-style) */
%left "||"
%left "&&"
%left "|"
%left "^"
%left "&"
%left "==" "!="
%left "<" "<=" ">" ">="
%left "<<" ">>"
%left "+" "-"
%left "*" "/" "%"
%right "!" "~"

/* Non-terminal type declarations.
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
  ";"
| i_expr ";"    { std::cout << "<long> " << $1 << std::endl; }
| d_expr ";"    { std::cout << "<double> " << $1 << std::endl; }
| b_expr ";"    { PDCALC_YY_PRINT_BOOL($1); }

/* Integral expression rule */
i_expr:
  INTEGRAL              { $$ = $1; }
| "(" i_expr ")"        { $$ = $2; }
| i_expr "+" i_expr     { $$ = $1 + $3; }
| i_expr "-" i_expr     { $$ = $1 - $3; }
| i_expr "*" i_expr     { $$ = $1 * $3; }
| i_expr "/" i_expr     { PDCALC_YY_SAFE_DIVIDE($$, $1, $3); }
| i_expr "%" i_expr     { $$ = $1 % $3; }
| i_expr "&" i_expr     { $$ = $1 & $3; }
| i_expr "^" i_expr     { $$ = $1 ^ $3; }
| i_expr "|" i_expr     { $$ = $1 | $3; }
| "~" i_expr            { $$ = ~$2; }
| i_expr "<<" i_expr    { $$ = $1 << $3; }
| i_expr ">>" i_expr    { $$ = $1 >> $3; }

/* Float arithmetic expression rule */
d_expr:
  FLOATING             { $$ = $1; }
| "(" d_expr ")"       { $$ = $2; }
| d_expr "+" d_expr    { $$ = $1 + $3; }
| d_expr "-" d_expr    { $$ = $1 - $3; }
| d_expr "*" d_expr    { $$ = $1 * $3; }
| d_expr "/" d_expr    { PDCALC_YY_SAFE_DIVIDE($$, $1, $3); }
/* promoting right i_expr */
| d_expr "+" i_expr    { $$ = $1 + $3; }
| d_expr "-" i_expr    { $$ = $1 - $3; }
| d_expr "*" i_expr    { $$ = $1 * $3; }
| d_expr "/" i_expr    { PDCALC_YY_SAFE_DIVIDE($$, $1, $3); }
/* promoting left i_expr */
| i_expr "+" d_expr    { $$ = $1 + $3; }
| i_expr "-" d_expr    { $$ = $1 - $3; }
| i_expr "*" d_expr    { $$ = $1 * $3; }
| i_expr "/" d_expr    { PDCALC_YY_SAFE_DIVIDE($$, $1, $3); }

/* Boolean expression rule */
b_expr:
  TRUTH                 { $$ = $1; }
| "(" b_expr ")"        { $$ = $2; }
/* b_expr comparisons */
| b_expr "==" b_expr    { $$ = ($1 == $3); }
| b_expr "!=" b_expr    { $$ = ($1 == $3); }
| b_expr "||" b_expr    { $$ = ($1 || $3); }
| b_expr "&&" b_expr    { $$ = ($1 && $3); }
| "!" b_expr            { $$ = !$2; }
/* d_expr, i_expr comparisons */
| d_expr "==" d_expr    { $$ = ($1 == $3); }
| d_expr "!=" d_expr    { $$ = ($1 != $3); }
| i_expr "==" i_expr    { $$ = ($1 == $3); }
| i_expr "!=" i_expr    { $$ = ($1 != $3); }
| d_expr "<" d_expr     { $$ = ($1 < $3); }
| d_expr ">" d_expr     { $$ = ($1 > $3); }
| d_expr "<=" d_expr    { $$ = ($1 <= $3); }
| d_expr ">=" d_expr    { $$ = ($1 >= $3); }
| i_expr "<" i_expr     { $$ = ($1 < $3); }
| i_expr ">" i_expr     { $$ = ($1 > $3); }
| i_expr "<=" i_expr    { $$ = ($1 <= $3); }
| i_expr ">=" i_expr    { $$ = ($1 >= $3); }
/* d_expr left, i_expr right */
| d_expr "==" i_expr    { $$ = ($1 == $3); }
| d_expr "!=" i_expr    { $$ = ($1 != $3); }
| d_expr "<" i_expr     { $$ = ($1 < $3); }
| d_expr ">" i_expr     { $$ = ($1 > $3); }
| d_expr "<=" i_expr    { $$ = ($1 <= $3); }
| d_expr ">=" i_expr    { $$ = ($1 >= $3); }
/* i_expr left, d_expr right */
| i_expr "==" d_expr    { $$ = ($1 == $3); }
| i_expr "!=" d_expr    { $$ = ($1 != $3); }
| i_expr "<" d_expr     { $$ = ($1 < $3); }
| i_expr ">" d_expr     { $$ = ($1 > $3); }
| i_expr "<=" d_expr    { $$ = ($1 <= $3); }
| i_expr ">=" d_expr    { $$ = ($1 >= $3); }

%%

namespace yy {

/**
 * User-defined error handler.
 *
 * The parse driver's last error member is updated with location + error.
 *
 * @param loc Bison error location
 * @param msg Bison exception error message
 */
void parser::error(const parser::location_type& loc, const std::string& msg)
{
  std::stringstream ss;
  ss << loc << ": " << msg;
  driver.last_error_ = ss.str();
}

}  // namespace yy
