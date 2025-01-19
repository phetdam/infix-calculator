/**
 * @file common.h
 * @author Derek Huang
 * @brief C/C++ header for common macros
 * @copyright MIT License
 */

#ifndef PDCALC_COMMON_H_
#define PDCALC_COMMON_H_

// C/C++ header compatibility macro
#ifdef __cplusplus
#define PDCALC_EXTERN_C_BEGIN extern "C" {
#define PDCALC_EXTERN_C_END }
#else
#define PDCALC_EXTERN_C_BEGIN
#define PDCALC_EXTERN_C_END
#endif  // __cplusplus

// stringification macros
#define PDCALC_STRINGIFY_I(x) #x
#define PDCALC_STRINGIFY(x) PDCALC_STRINGIFY_I(x)

// C++ version macro that works with MSVC (avoid using /Zc:__cplusplus)
#if defined(_MSVC_LANG)
#define PDCALC_CPLUSPLUS _MSVC_LANG
#elif defined(__cplusplus)
#define PDCALC_CPLUSPLUS __cplusplus
#endif  // !defined(_MSVC_LANG) && !defined(__cplusplus)

// constexpr only if C++20 or above
#ifdef PDCALC_CPLUSPLUS
#if PDCALC_CPLUSPLUS >= 202002L
#define PDCALC_CXX20_CONSTEXPR constexpr
#endif  // PDCALC_CPLUSPLUS >= 202002L
#endif  // PDCALC_CPLUSPLUS

#ifndef PDCALC_CXX20_CONSTEXPR
#define PDCALC_CXX20_CONSTEXPR
#endif  // PDCALC_CXX20_CONSTEXPR

#endif  // PDCALC_COMMON_H_
