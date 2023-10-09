/**
 * @file calc_parser_test.cc
 * @author Derek Huang
 * @brief calc_parser.h unit tests
 * @copyright MIT License
 */

#include "pdcalc/calc_parser.h"

#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <string_view>

#include <gtest/gtest.h>

// test data directory. this default value is defined during compile time but
// can be overridden by the corresponding environment variable.
#ifndef PDCALC_TEST_DATA_DIR
#define PDCALC_TEST_DATA_DIR ""
#endif  // PDCALC_TEST_DATA_DIR

namespace {

/**
 * Calc parser base test fixture.
 */
class CalcParserTest : public ::testing::Test {
protected:
  /**
   * Test suite setup function.
   *
   * Checks that `test_data_dir_` is valid, and if not, skips the tests.
   */
  static void SetUpTestSuite()
  {
    // path doesn't exist
    if (!std::filesystem::exists(test_data_dir_))
      skip_reason_ = "PDCALC_TEST_DATA_DIR " +
        std::string{PDCALC_TEST_DATA_DIR} + " does not exist";
    // not a directory
    else if (!std::filesystem::is_directory(test_data_dir_))
      skip_reason_ = "PDCALC_TEST_DATA_DIR " +
        std::string{PDCALC_TEST_DATA_DIR} + " is not a directory";
  }

  /**
   * Test setup function.
   *
   * If `test_data_dir_` is invalid, the test is skipped.
   */
  void SetUp() override
  {
    if (skip_reason_.size())
      GTEST_SKIP() << skip_reason_;
  }

  // absolute path to test data directory
  static inline const std::filesystem::path test_data_dir_{
    []
    {
      // if defined in environment, use
      auto test_dir = std::getenv("PDCALC_TEST_DATA_DIR");
      if (test_dir)
        return std::filesystem::path{test_dir};
      // else if defined, use, otherwise return empty path
      if (std::strlen(PDCALC_TEST_DATA_DIR))
        return std::filesystem::path{PDCALC_TEST_DATA_DIR};
      return std::filesystem::path{};
    }()
  };
  // reason to skip tests if test_data_dir_ is not properly defined
  static inline std::string skip_reason_;
};

/**
 * Calc parser parameterized test fixture.
 */
class CalcParserPureTest
  : public CalcParserTest,
    public ::testing::WithParamInterface<std::string_view> {};

/**
 * Test that parsing succeeds on the given input file.
 */
TEST_P(CalcParserPureTest, PureParseTest)
{
  pdcalc::calc_parser parser;
  EXPECT_TRUE(parser(test_data_dir_ / GetParam()));
}

INSTANTIATE_TEST_SUITE_P(
  BaseSuite,
  CalcParserPureTest,
  ::testing::Values("sample.in.1", "sample.in.2")
);

}  // namespace
