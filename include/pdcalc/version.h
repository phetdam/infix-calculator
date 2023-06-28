/**
 * @file version.h
 * @author Derek Huang
 * @brief C++ header for pdcalc versioning
 * @copyright MIT License
 *
 * @note This header is essentially a refactored version of the `version.h`
 *  header from my xkcd-alt project. Not much has changed beyond the names.
 */

#ifndef PDCALC_VERSION_H_
#define PDCALC_VERSION_H_

#include <string>

// major, minor, patch version defaults. values should be defined during build
#ifndef PDCALC_MAJOR_VERSION
#define PDCALC_MAJOR_VERSION 0
#endif  // PDCALC_MAJOR_VERSION
#ifndef PDCALC_MINOR_VERSION
#define PDCALC_MINOR_VERSION 0
#endif  // PDCALC_MINOR_VERSION
#ifndef PDCALC_PATCH_VERSION
#define PDCALC_PATCH_VERSION 0
#endif  // PDCALC_PATCH_VERSION

namespace pdcalc {

/**
 * Version string.
 */
inline const std::string version{
  std::to_string(PDCALC_MAJOR_VERSION) + "." +
  std::to_string(PDCALC_MINOR_VERSION) + "." +
  std::to_string(PDCALC_PATCH_VERSION)
};

/**
 * Version as a C string.
 */
inline const char* c_version = version.c_str();

}  // namespace pdcalc

// version as a macro, using the C string
#define PDCALC_VERSION pdcalc::c_version

// build type, real build defines as CMake CMAKE_BUILD_TYPE
#ifndef PDCALC_BUILD_TYPE
#define PDCALC_BUILD_TYPE "Debug"
#endif  // PDCALC_BUILD_TYPE

namespace pdcalc {

/*
 * Build type string.
 */
inline const std::string build_type{PDCALC_BUILD_TYPE};

}  // namespace pdcalc

// system name, real build defines using CMAKE_SYSTEM_NAME
#ifndef PDCALC_SYSTEM_NAME
// try to guess if not defined
#if defined(_WIN32)
#define PDCALC_SYSTEM_NAME "Windows"
#elif defined(__APPLE__) && defined(__MACH__)
#define PDCALC_SYSTEM_NAME "MacOS"
#elif defined(__CYGWIN__)
#define PDCALC_SYSTEM_NAME "Cygwin"
#elif defined(__linux__)
#define PDCALC_SYSTEM_NAME "Linux"
#else
#define PDCALC_SYSTEM_NAME "unknown"
#endif
#endif  // PDCALC_SYSTEM_NAME

// system version, hard to determine. real build uses CMAKE_SYSTEM_VERSION
#ifndef PDCALC_SYSTEM_VERSION
#define PDCALC_SYSTEM_VERSION "unknown"
#endif  // PDCALC_SYSTEM_VERSION

// system arch, hard to determine. real build uses CMAKE_SYSTEM_PROCESSOR
#ifndef PDCALC_SYSTEM_ARCH
#if defined(_WIN32)
#ifdef _WIN64
#define PDCALC_SYSTEM_ARCH "AMD64"
#else
#define PDCALC_SYSTEM_ARCH "x86"
#endif  // !_WIN64
#elif defined(__linux__)
#define PDCALC_SYSTEM_ARCH "x86_64"
#else
#define PDCALC_SYSTEM_ARCH "unknown"
#endif
#endif  // PDCALC_SYSTEM_ARCH

namespace pdcalc {

/*
 * System name string.
 */
inline const std::string system_name{PDCALC_SYSTEM_NAME};

/**
 * System version string.
 */
inline const std::string system_version{PDCALC_SYSTEM_VERSION};

/**
 * System architecture string.
 */
inline const std::string system_arch{PDCALC_SYSTEM_ARCH};

}  // namespace pdcalc

#endif  // PDCALC_VERSION_H_
