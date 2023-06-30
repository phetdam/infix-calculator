/**
 * @file warnings.h
 * @author Derek Huang
 * @brief C/C++ header for warnings helpers
 * @copyright MIT License
 */

#ifndef PDCALC_WARNINGS_H_
#define PDCALC_WARNINGS_H_

#include "pdcalc/common.h"

// macros for using _Pragma without needing to explicitly quote
#define PDCALC_PRAGMA_I(x) _Pragma(#x)
#define PDCALC_PRAGMA(x) PDCALC_PRAGMA_I(x)

// helper macros for disabling and re-enabling MSVC warnings
#ifdef _MSC_VER
/**
 * Push warning state.
 */
#define PDCALC_MSVC_WARNING_PUSH() __pragma(warning(push))

/**
 * Disable specified MSVC warnings.
 *
 * @param wnos Warning number(s), e.g. 4242
 */
#define PDCALC_MSVC_WARNING_DISABLE(wnos) __pragma(warning(disable: wnos))

/**
 * Pop warning state.
 */
#define PDCALC_MSVC_WARNING_POP() __pragma(warning(pop))
#else
#define PDCALC_MSVC_WARNING_PUSH()
#define PDCALC_MSVC_WARNING_DISABLE(wnos)
#define PDCALC_MSVC_WARNING_POP()
#endif  // _MSC_VER

// helper macros for disabling and re-enabling GCC/Clang warnings
#ifdef __GNUC__
/**
 * Push warning state.
 */
#define PDCALC_GNU_WARNING_PUSH() PDCALC_PRAGMA(GCC diagnostic push)

/**
 * Disable specified GCC/Clang warning.
 *
 * @param wname GCC/Clang warning name without -W, e.g. self-move, narrowing
 */
#define PDCALC_GNU_WARNING_DISABLE(wname) \
  PDCALC_PRAGMA(GCC diagnostic ignored PDCALC_STRINGIFY(PDCALC_CONCAT(-W, wname)))

/**
 * Pop warning state.
 */
#define PDCALC_GNU_WARNING_POP() PDCALC_PRAGMA(GCC diagnostic pop)
#else
#define PDCALC_GNU_WARNING_PUSH()
#define PDCALC_GNU_WARNING_DISABLE(wname)
#define PDCALC_GNU_WARNING_POP()
#endif  // __GNUC__

// helper macros for disabling and re-enabling Clang warnings. these are useful
// when there are Clang-specific warnings that have no GCC equivalent.
#ifdef __clang__
/**
 * Push warning state.
 */
#define PDCALC_CLANG_WARNING_PUSH() PDCALC_PRAGMA(clang diagnostic push)

/**
 * Disable specified Clang warning.
 *
 * @param wname Clang warning name without -W, e.g. unused-lambda-capture
 */
#define PDCALC_CLANG_WARNING_DISABLE(wname) \
  PDCALC_PRAGMA(clang diagnostic ignored PDCALC_STRINGIFY(PDCALC_CONCAT(-W, wname)))

/**
 * Pop warning state.
 */
#define PDCALC_CLANG_WARNING_POP() PDCALC_PRAGMA(clang diagnostic pop)
#else
#define PDCALC_CLANG_WARNING_PUSH()
#define PDCALC_CLANG_WARNING_DISABLE(wname)
#define PDCALC_CLANG_WARNING_POP()
#endif  // __clang__

#endif  // PDCALC_WARNINGS_H_
