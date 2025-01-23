/**
 * parser.y
 *
 * Author: Derek Huang
 * Summary: pdcalc C++ Bison grammar
 * Copyright: MIT License
 */

%{
  // MSVC reports __STDC_WANT_SECURE_LIB__ not defined in limits.h, but this is
  // defined to 1 in corecrt.h, hence the conditional inclusion.
  #ifdef _WIN32
  #include <corecrt.h>
  #endif  // _WIN32

  #include <algorithm>
  #include <cmath>
  #include <ios>
  #include <iostream>
  #include <sstream>
  #include <string>

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
    driver.sink() << "<bool> " << std::boolalpha << (value) << \
      std::noboolalpha << std::endl;
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
/* %token ASSIGN "=" */
%token AND "&&"
%token OR "||"
%token NOT "!"
%token LANGLE "<"
%token RANGLE ">"
%token LEQUALS "<="
%token GEQUALS ">="
%token NOT_EQUALS "!="
%token SEMICOLON ";"
%token COMMA ","
/* Identifiers
 *
 * We have typed identifiers, which are intended to be verified by actually
 * looking up the parser table of symbols for the valid identifier. The lexer
 * will perform this lookup using and disambiguate the identifier type.
 */
%token <std::string> BOOL_IDEN
%token <std::string> LONG_IDEN
%token <std::string> DOUBLE_IDEN
/* Type tokens */
/* %token T_LONG "long" */
/* %token T_BOOL "bool" */
/* %token T_DOUBLE "double" */
/* Built-in function names */
%token F_SQRT "sqrt"
%token F_MAX "max"
%token F_MIN "min"
%token F_SIN "sin"
%token F_COS "cos"
%token F_TAN "tan"

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
%nterm <long> i_expr

%%

/* Input rule */
input:
  %empty
| input stmt

/* Statement rule
 *
 * TODO:
 *
 * Consider using a std::variant<bool, long, double> to hold the result of the
 * operation for further processing. Per-statement results can be held in a
 * std::vector which would allow us to better test outputs and/or begin to
 * support variable assignment (which definitely requires state management).
 */
stmt:
  ";"
| i_expr ";"
  {
    driver.sink() << "<long> " << $1 << std::endl;
  }
| d_expr ";"
  {
    driver.sink() << "<double> " << $1 << std::endl;
  }
| b_expr ";"
  {
    PDCALC_YY_PRINT_BOOL($1);
  }

/* Integral expression rule */
i_expr:
  INTEGRAL
  {
    $$ = $1;
  }
/*
| LONG_IDEN
  {
    // perform lookup (e.g. if we use std::optional<calc_symbol>)
    auto maybe_sym = driver.find_symbol($1);
    if (!maybe_sym) {
      error(driver.location_, "Identifier " + $1 + " not defined yet");
      YYABORT;
    }
    // otherwise, we can assign the value. no need to check type (lexer handled)
    // TODO: may consider using visitor to abstract this
    $$ = maybe_sym->get<long>();
  }
*/
| "(" i_expr ")"
  {
    $$ = $2;
  }
| i_expr "+" i_expr
  {
    $$ = $1 + $3;
  }
| i_expr "-" i_expr
  {
    $$ = $1 - $3;
  }
| i_expr "*" i_expr
  {
    $$ = $1 * $3;
  }
| i_expr "/" i_expr
  {
    PDCALC_YY_SAFE_DIVIDE($$, $1, $3);
  }
| i_expr "%" i_expr
  {
    $$ = $1 % $3;
  }
| i_expr "&" i_expr
  {
    $$ = $1 & $3;
  }
| i_expr "^" i_expr
  {
    $$ = $1 ^ $3;
  }
| i_expr "|" i_expr
  {
    $$ = $1 | $3;
  }
| "~" i_expr
  {
    $$ = ~$2;
  }
| i_expr "<<" i_expr
  {
    $$ = $1 << $3;
  }
| i_expr ">>" i_expr
  {
    $$ = $1 >> $3;
  }
/* Binary function calls */
| "max" "(" i_expr "," i_expr ")"
  {
    $$ = std::max($3, $5);
  }
| "min" "(" i_expr "," i_expr ")"
  {
    $$ = std::min($3, $5);
  }

/* Float arithmetic expression rule */
d_expr:
  FLOATING
  {
    $$ = $1;
  }
| "(" d_expr ")"
  {
    $$ = $2;
  }
| d_expr "+" d_expr
  {
    $$ = $1 + $3;
  }
| d_expr "-" d_expr
  {
    $$ = $1 - $3;
  }
| d_expr "*" d_expr
  {
    $$ = $1 * $3;
  }
| d_expr "/" d_expr
  {
    PDCALC_YY_SAFE_DIVIDE($$, $1, $3);
  }
/* promoting right i_expr */
| d_expr "+" i_expr
  {
    $$ = $1 + $3;
  }
| d_expr "-" i_expr
  {
    $$ = $1 - $3;
  }
| d_expr "*" i_expr
  {
    $$ = $1 * $3;
  }
| d_expr "/" i_expr
  {
    PDCALC_YY_SAFE_DIVIDE($$, $1, $3);
  }
/* promoting left i_expr */
| i_expr "+" d_expr
  {
    $$ = $1 + $3;
  }
| i_expr "-" d_expr
  {
    $$ = $1 - $3;
  }
| i_expr "*" d_expr
  {
    $$ = $1 * $3;
  }
| i_expr "/" d_expr
  {
    PDCALC_YY_SAFE_DIVIDE($$, $1, $3);
  }
/* Unary function calls */
| "sqrt" "(" d_expr ")"
  {
    $$ = std::sqrt($3);
  }
| "sqrt" "(" i_expr ")"
  {
    $$ = std::sqrt($3);
  }
| "sin" "(" d_expr ")"
  {
    $$ = std::sin($3);
  }
| "sin" "(" i_expr ")"
  {
    $$ = std::sin($3);
  }
| "cos" "(" d_expr ")"
  {
    $$ = std::cos($3);
  }
| "cos" "(" i_expr ")"
  {
    $$ = std::cos($3);
  }
| "tan" "(" d_expr ")"
  {
    $$ = std::tan($3);
  }
| "tan" "(" i_expr ")"
  {
    $$ = std::tan($3);
  }
/*
 * Binary function calls.
 *
 * Note that in some cases, explicit template type is specified since the min +
 * max templates have a (const T& a, const T& b) signature.
 */
| "max" "(" d_expr "," d_expr ")"
  {
    $$ = std::max($3, $5);
  }
| "max" "(" d_expr "," i_expr ")"
  {
    $$ = std::max<double>($3, $5);
  }
| "max" "(" i_expr "," d_expr ")"
  {
    $$ = std::max<double>($3, $5);
  }
| "min" "(" d_expr "," d_expr ")"
  {
    $$ = std::min($3, $5);
  }
| "min" "(" d_expr "," i_expr ")"
  {
    $$ = std::min<double>($3, $5);
  }
| "min" "(" i_expr "," d_expr ")"
  {
    $$ = std::min<double>($3, $5);
  }

/* Boolean expression rule */
b_expr:
  TRUTH
  {
    $$ = $1;
  }
| "(" b_expr ")"
  {
    $$ = $2;
  }
/* b_expr comparisons */
| b_expr "==" b_expr
  {
    $$ = ($1 == $3);
  }
| b_expr "!=" b_expr
  {
    $$ = ($1 == $3);
  }
| b_expr "||" b_expr
  {
    $$ = ($1 || $3);
  }
| b_expr "&&" b_expr
  {
    $$ = ($1 && $3);
  }
| "!" b_expr
  {
    $$ = !$2;
  }
/* d_expr, i_expr comparisons */
| d_expr "==" d_expr
  {
    $$ = ($1 == $3);
  }
| d_expr "!=" d_expr
  {
    $$ = ($1 != $3);
  }
| i_expr "==" i_expr
  {
    $$ = ($1 == $3);
  }
| i_expr "!=" i_expr
  {
    $$ = ($1 != $3);
  }
| d_expr "<" d_expr
  {
    $$ = ($1 < $3);
  }
| d_expr ">" d_expr
  {
    $$ = ($1 > $3);
  }
| d_expr "<=" d_expr
  {
    $$ = ($1 <= $3);
  }
| d_expr ">=" d_expr
  {
    $$ = ($1 >= $3);
  }
| i_expr "<" i_expr
  {
    $$ = ($1 < $3);
  }
| i_expr ">" i_expr
  {
    $$ = ($1 > $3);
  }
| i_expr "<=" i_expr
  {
    $$ = ($1 <= $3);
  }
| i_expr ">=" i_expr
  {
    $$ = ($1 >= $3);
  }
/* d_expr left, i_expr right */
| d_expr "==" i_expr
  {
    $$ = ($1 == $3);
  }
| d_expr "!=" i_expr
  {
    $$ = ($1 != $3);
  }
| d_expr "<" i_expr
  {
    $$ = ($1 < $3);
  }
| d_expr ">" i_expr
  {
    $$ = ($1 > $3);
  }
| d_expr "<=" i_expr
  {
    $$ = ($1 <= $3);
  }
| d_expr ">=" i_expr
  {
    $$ = ($1 >= $3);
  }
/* i_expr left, d_expr right */
| i_expr "==" d_expr
  {
    $$ = ($1 == $3);
  }
| i_expr "!=" d_expr
  {
    $$ = ($1 != $3);
  }
| i_expr "<" d_expr
  {
    $$ = ($1 < $3);
  }
| i_expr ">" d_expr
  {
    $$ = ($1 > $3);
  }
| i_expr "<=" d_expr
  {
    $$ = ($1 <= $3);
  }
| i_expr ">=" d_expr
  {
    $$ = ($1 >= $3);
  }

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
