/**
 * @file testing/gtest.hh
 * @author Derek Huang
 * @brief C++ header for Google Test helpers
 * @copyright MIT License
 */

#ifndef PDCALC_TESTING_GTEST_HH_
#define PDCALC_TESTING_GTEST_HH_

#include <gtest/gtest.h>

namespace pdcalc::testing {

/**
 * Set up a Google Test typed test suite.
 *
 * This also sets up the list of types appropriately. Use `PDCALC_IDENTITY` as
 * necessary to ensure that each type is treated as a single macro argument.
 *
 * @param fixture Test fixture template identifier
 * @param ... Variadic list of types
 */
#define PDCALC_GTEST_TYPED_TEST_SUITE(fixture, ...) \
  using fixture ## Types = ::testing::Types<__VA_ARGS__>; \
  TYPED_TEST_SUITE(fixture, fixture ## Types)

}  // namespace pdcalc::testing

#endif  // PDCALC_TESTING_GTEST_HH_