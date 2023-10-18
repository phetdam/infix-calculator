/**
 * @file dllexport.h
 * @author Derek Huang
 * @brief C/C++ header for DLL macro export defs
 * @copyright MIT License
 */

#ifndef PDCALC_DLLEXPORT_H_
#define PDCALC_DLLEXPORT_H_

// building pdcalc shared
#if defined(PDCALC_DLL)
// Windows
#if defined(_WIN32)
// export if building DLL, import otherwise
#if defined(PDCALC_BUILD_DLL)
#define PDCALC_API __declspec(dllexport)
#else
#define PDCALC_API __declspec(dllimport)
#endif  // !defined(PDCALC_BUILD_DLL)
#else
// for GCC/Clang, can define as __attribute__((visibility("default"))) if using
// -fvisibility=hidden later on to explicitly mark exported symbols
#define PDCALC_API
#endif  // !defined(_WIN32)
// build pdcalc static
#else
#define PDCALC_API
#endif  // !defined(PDCALC_DLL)

#endif  // PDCALC_DLLEXPORT_H_
