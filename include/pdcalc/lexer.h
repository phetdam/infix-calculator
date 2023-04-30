/**
 * @file lexer.h
 * @author Derek Huang
 * @brief C++ wrapper header for the Flex-generated lexer header
 * @copyright MIT License
 */

#ifndef PDCALC_LEXER_H_
#define PDCALC_LEXER_H_

// MSVC complains that macros for fixed-size integral types are being redefined
#ifdef _WIN32
#include <stdint.h>
#endif  // _WIN32

// note: if compiling lexer as C code, need PDCALC_EXTERN_C_(BEGIM|END) wrapper
#include "pdcalc/lexer.yy.h"

#endif  // PDCALC_LEXER_H_
