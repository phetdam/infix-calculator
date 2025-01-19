/**
 * @file features.h
 * @author Derek Huang
 * @brief C/C++ header for feature detection macros
 * @copyright MIT License
 */

#ifndef PDCALC_FEATURES_H_
#define PDCALC_FEATURES_H_

#include "pdcalc/common.h"

// C++ standards support
#ifdef __cplusplus
// C++17
#if PDCALC_CPLUSPLUS >= 201703L
#define PDCALC_HAS_CC17 1
#endif  // PDCALC_CPLUSPLUS >= 201703L
// C++20
#if PDCALC_CPLUSPLUS >= 202002L
#define PDCALC_HAS_CC20 1
#endif  // PDCALC_CPLUSPLUS >= 202002L
// C++23
#if PDCALC_CPLUSPLUS >= 202302L
#define PDCALC_HAS_CC23 1
#endif  // PDCALC_CPLUSPLUS >= 202302L
// C++26 (draft)
#if PDCALC_CPLUSPLUS > 202302L
#define PDCALC_HAS_CC26 1
#endif  // PDCALC_CPLUSPLUS > 202302L
#endif  // __cplusplus

// always defined if this header is included
#ifndef PDCALC_HAS_CC17
#define PDCALC_HAS_CC17 0
#endif  // PDCALC_HAS_CC17
#ifndef PDCALC_HAS_CC20
#define PDCALC_HAS_CC20 0
#endif  // PDCALC_HAS_CC20
#ifndef PDCALC_HAS_CC23
#define PDCALC_HAS_CC23 0
#endif  // PDCALC_HAS_CC23
#ifndef PDCALC_HAS_CC26
#define PDCALC_HAS_CC26 0
#endif  // PDCALC_HAS_CC26

#endif  // PDCALC_FEATURES_H_
