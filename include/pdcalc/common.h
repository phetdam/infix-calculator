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

// concatenation macros
#define PDCALC_CONCAT_I(x, y) x ## y
#define PDCALC_CONCAT(x, y) PDCALC_CONCAT_I(x, y)

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
#define PDCALC_CC20_CONSTEXPR constexpr
#endif  // PDCALC_CPLUSPLUS >= 202002L
#endif  // PDCALC_CPLUSPLUS

#ifndef PDCALC_CC20_CONSTEXPR
#define PDCALC_CC20_CONSTEXPR
#endif  // PDCALC_CC20_CONSTEXPR

/**
 * Helper macro to wrap variadic arguments and have them expand literally.
 *
 * This is useful for wrapping template type specializations, e.g. something
 * like `std::tuple<T1, T2, ...>`, and ensuring the entire type is treated as a
 * single argument by the preprocessor instead of as multiple tokens.
 */
#define PDCALC_IDENTITY(...) __VA_ARGS__

#endif  // PDCALC_COMMON_H_
