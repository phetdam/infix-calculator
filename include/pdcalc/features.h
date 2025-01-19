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
#define PDCALC_HAS_CC_17 1
#endif  // PDCALC_CPLUSPLUS >= 201703L
// C++20
#if PDCALC_CPLUSPLUS >= 202002L
#define PDCALC_HAS_CC_20 1
#endif  // PDCALC_CPLUSPLUS >= 202002L
// C++23
#if PDCALC_CPLUSPLUS >= 202302L
#define PDCALC_HAS_CC_23 1
#endif  // PDCALC_CPLUSPLUS >= 202302L
// C++26 (draft)
#if PDCALC_CPLUSPLUS > 202302L
#define PDCALC_HAS_CC_26 1
#endif  // PDCALC_CPLUSPLUS > 202302L
#endif  // __cplusplus

// always defined if this header is included
#ifndef PDCALC_HAS_CC_17
#define PDCALC_HAS_CC_17 0
#endif  // PDCALC_HAS_CC_17
#ifndef PDCALC_HAS_CC_20
#define PDCALC_HAS_CC_20 0
#endif  // PDCALC_HAS_CC_20
#ifndef PDCALC_HAS_CC_23
#define PDCALC_HAS_CC_23 0
#endif  // PDCALC_HAS_CC_23
#ifndef PDCALC_HAS_CC_26
#define PDCALC_HAS_CC_26 0
#endif  // PDCALC_HAS_CC_26

#endif  // PDCALC_FEATURES_H_
