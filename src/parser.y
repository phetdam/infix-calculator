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

#include "calc_parser_impl.hh"

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
  while (false)

/**
 * Print an expression truth value to stdout as "true" or "false".
 *
 * @param value Boolean value of an expression
 */
#define PDCALC_YY_PRINT_BOOL(value) \
  driver.sink() << "<bool> " << std::boolalpha << (value) << \
    std::noboolalpha << std::endl

/**
 * Report an undefined symbol error.
 *
 * @param iden `std::string` symbol identifier
 */
#define PDCALC_YY_UNDEFINED_SYMBOL(iden) \
  error(driver.location_, "Undefined symbol '" + (iden) + "'")

/**
 * Extract the value of a defined symbol.
 *
 * We do not need to check if the symbol exists or not as the lexer has already
 * done that for us (symbol is not unknown and is a typed symbol).
 *
 * @note Safety check is still included but is probably unnecessary.
 *
 * @param out Semantic value to assign to
 * @param iden Symbol identifier
 * @param type Symbol value C++ type
 */
#define PDCALC_YY_GET_SYMBOL_VALUE(out, iden, type) \
  do { \
    /* lookup symbol */ \
    auto sym = driver.get_symbol(iden); \
    /* doesn't exist, so report error and abort */ \
    if (!sym) { \
      PDCALC_YY_UNDEFINED_SYMBOL(iden); \
      YYABORT; \
    } \
    /* otherwise, assign the value. no need to check type (lexer handled) */ \
    out = sym->get<type>(); \
  } \
  while (false)
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
%token ASSIGN "="
%token ASSIGN_PLUS "+="
%token ASSIGN_MINUS "-="
%token ASSIGN_MULTIPLY "*="
%token ASSIGN_DIVIDE "/="
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
 * will perform this lookup to disambiguate the identifier type.
 */
%token <std::string> BOOL_IDEN
%token <std::string> LONG_IDEN
%token <std::string> DOUBLE_IDEN
%token <std::string> UNKNOWN_IDEN
/* Built-in function names */
%token F_EXP "exp"
%token F_LOG "log"
%token F_LOG2 "log2"
%token F_LOG10 "log10"
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
 * Enable identifier assignment. This does not result in a printout but will
 * update the calc_parser_impl symbol table.
 */
stmt:
  ";"
/* printing literal expressions */
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
/* assigning new identifiers */
| UNKNOWN_IDEN "=" i_expr ";"
  {
    driver.add_symbol($1, $3);
  }
| UNKNOWN_IDEN "=" d_expr ";"
  {
    driver.add_symbol($1, $3);
  }
| UNKNOWN_IDEN "=" b_expr ";"
  {
    driver.add_symbol($1, $3);
  }
/* rebinding existing identifiers (note: can result in type change) */
| LONG_IDEN "=" i_expr ";"
  {
    driver.add_symbol($1, $3);
  }
| LONG_IDEN "=" d_expr ";"
  {
    driver.add_symbol($1, $3);
  }
| LONG_IDEN "=" b_expr ";"
  {
    driver.add_symbol($1, $3);
  }
| DOUBLE_IDEN "=" i_expr ";"
  {
    driver.add_symbol($1, $3);
  }
| DOUBLE_IDEN "=" d_expr ";"
  {
    driver.add_symbol($1, $3);
  }
| DOUBLE_IDEN "=" b_expr ";"
  {
    driver.add_symbol($1, $3);
  }
| BOOL_IDEN "=" i_expr ";"
  {
    driver.add_symbol($1, $3);
  }
| BOOL_IDEN "=" d_expr ";"
  {
    driver.add_symbol($1, $3);
  }
| BOOL_IDEN "=" b_expr ";"
  {
    driver.add_symbol($1, $3);
  }
/* modifying existing identifiers (note: can result in type change) */
| LONG_IDEN "+=" i_expr ";"
  {
    driver.add_symbol($1, driver.get_symbol($1)->get<long>() + $3);
  }
| LONG_IDEN "+=" d_expr ";"
  {
    driver.add_symbol($1, driver.get_symbol($1)->get<long>() + $3);
  }
| LONG_IDEN "-=" i_expr ";"
  {
    driver.add_symbol($1, driver.get_symbol($1)->get<long>() - $3);
  }
| LONG_IDEN "-=" d_expr ";"
  {
    driver.add_symbol($1, driver.get_symbol($1)->get<long>() - $3);
  }
| LONG_IDEN "*=" i_expr ";"
  {
    driver.add_symbol($1, driver.get_symbol($1)->get<long>() * $3);
  }
| LONG_IDEN "*=" d_expr ";"
  {
    driver.add_symbol($1, driver.get_symbol($1)->get<long>() * $3);
  }
| LONG_IDEN "/=" i_expr ";"
  {
    long res;
    PDCALC_YY_SAFE_DIVIDE(res, driver.get_symbol($1)->get<long>(), $3);
    driver.add_symbol($1, res);
  }
| LONG_IDEN "/=" d_expr ";"
  {
    double res;
    PDCALC_YY_SAFE_DIVIDE(res, driver.get_symbol($1)->get<long>(), $3);
    driver.add_symbol($1, res);
  }
| DOUBLE_IDEN "+=" i_expr ";"
  {
    driver.add_symbol($1, driver.get_symbol($1)->get<double>() + $3);
  }
| DOUBLE_IDEN "+=" d_expr ";"
  {
    driver.add_symbol($1, driver.get_symbol($1)->get<double>() + $3);
  }
| DOUBLE_IDEN "-=" i_expr ";"
  {
    driver.add_symbol($1, driver.get_symbol($1)->get<double>() - $3);
  }
| DOUBLE_IDEN "-=" d_expr ";"
  {
    driver.add_symbol($1, driver.get_symbol($1)->get<double>() - $3);
  }
| DOUBLE_IDEN "*=" i_expr ";"
  {
    driver.add_symbol($1, driver.get_symbol($1)->get<double>() * $3);
  }
| DOUBLE_IDEN "*=" d_expr ";"
  {
    driver.add_symbol($1, driver.get_symbol($1)->get<double>() * $3);
  }
| DOUBLE_IDEN "/=" i_expr ";"
  {
    double res;
    PDCALC_YY_SAFE_DIVIDE(res, driver.get_symbol($1)->get<double>(), $3);
    driver.add_symbol($1, res);
  }
| DOUBLE_IDEN "/=" d_expr ";"
  {
    double res;
    PDCALC_YY_SAFE_DIVIDE(res, driver.get_symbol($1)->get<double>(), $3);
    driver.add_symbol($1, res);
  }

/* Integral expression rule */
i_expr:
  INTEGRAL
  {
    $$ = $1;
  }
| LONG_IDEN
  {
    PDCALC_YY_GET_SYMBOL_VALUE($$, $1, long);
  }
| "(" i_expr ")"
  {
    $$ = $2;
  }
| "-" i_expr
  {
    $$ = -$2;
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
| DOUBLE_IDEN
  {
    PDCALC_YY_GET_SYMBOL_VALUE($$, $1, double);
  }
| "(" d_expr ")"
  {
    $$ = $2;
  }
| "-" d_expr
  {
    $$ = -$2;
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
| "exp" "(" d_expr ")"
  {
    $$ = std::exp($3);
  }
| "exp" "(" i_expr ")"
  {
    $$ = std::exp($3);
  }
| "log" "(" d_expr ")"
  {
    $$ = std::log($3);
  }
| "log" "(" i_expr ")"
  {
    $$ = std::log($3);
  }
| "log2" "(" d_expr ")"
  {
    $$ = std::log2($3);
  }
| "log2" "(" i_expr ")"
  {
    $$ = std::log2($3);
  }
| "log10" "(" d_expr ")"
  {
    $$ = std::log10($3);
  }
| "log10" "(" i_expr ")"
  {
    $$ = std::log10($3);
  }
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
| BOOL_IDEN
  {
    PDCALC_YY_GET_SYMBOL_VALUE($$, $1, bool);
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
