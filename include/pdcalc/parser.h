/**
 * @file parser.h
 * @author Derek Huang
 * @brief C++ API header for the Bison-generated parser header
 * @copyright MIT License
 */

#ifndef PDCALC_PARSER_H_
#define PDCALC_PARSER_H_

/**
 * The C++ header generated by Bison defining the parsing class.
 *
 * We need this in order to use `YY_DECL`, and so this must be included first.
 */
#include "pdcalc/parser.yy.h"

/**
 * Macro declaring `yylex` in the format the Bison parser expects.
 *
 * The corresponding parser handles complete symbols and uses variant values.
 */
#define YY_DECL yy::parser::symbol_type yylex(void)

/**
 * `yylex` declaration compatible with C++ Bison parser.
 */
YY_DECL;

#endif  // PDCALC_PARSER_H_
