/**
 * @file lexer.h
 * @author Derek Huang
 * @brief C++ API header for the Flex-generated lexer header
 * @copyright MIT License
 */

#ifndef PDCALC_LEXER_H_
#define PDCALC_LEXER_H_

#include "pdcalc/common.h"
#include "pdcalc/parser.h"

// generated Flex C API header does not have extern "C" guards. note that this
// must be included AFTER parser.h to pick up the custom YY_DECL declaration.
#include "pdcalc/lexer.yy.h"

#endif  // PDCALC_LEXER_H_
