/**
 * @file dllexport.h
 * @author Derek Huang
 * @brief C/C++ header for DLL macro export defs
 * @copyright MIT License
 */

#ifndef PDCALC_DLLEXPORT_H_
#define PDCALC_DLLEXPORT_H_

#ifdef _WIN32
// all DLLs should be built with PDCALC_BUILD_DLL defined
#ifdef PDCALC_BUILD_DLL
// use to handle import/export automatically
#define PDCALC_API __declspec(dllexport)
#else
#define PDCALC_API __declspec(dllimport)
#endif  // PDCALC_BUILD_DLL
#else
#define PDCALC_API
#endif  // _WIN32

#endif  // PDCALC_DLLEXPORT_H_
