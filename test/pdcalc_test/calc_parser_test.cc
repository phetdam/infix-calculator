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
#include <ostream>

#include <gtest/gtest.h>

#include "pdcalc/common.h"

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
#define PDCALC_TEST_DATA_DIR_MESSAGE \
  PDCALC_STRINGIFY_I(PDCALC_TEST_DATA_DIR) " " PDCALC_TEST_DATA_DIR
    // path doesn't exist
    if (!std::filesystem::exists(test_data_dir_))
      skip_reason_ = PDCALC_TEST_DATA_DIR_MESSAGE " does not exist";
    // not a directory
    else if (!std::filesystem::is_directory(test_data_dir_))
      skip_reason_ = PDCALC_TEST_DATA_DIR_MESSAGE " is not a directory";
#undef PDCALC_TETS_DATA_DIR_MESSAGE
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

  // no-op stream
  static inline std::ostream null_stream{nullptr};
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
 *
 * @note It has been observed that a Windows build of Google Test 1.10.0 seems
 *  to have issues properly displaying the `GetParam()` values properly when
 *  the value type is a string view. For example, instead of having
 *  `"sample.in.1"` as the reported `GetParam()` value for the first value, we
 *  get `{ 's' (115, 0x73), 'a' (97, 0x61), 'm' (109, 0x6D), 'p' (112, 0x70),
 *  'l' (108, 0x6C), 'e' (101, 0x65), '.' (46, 0x2E), 'i' (105, 0x69),
 *  'n' (110, 0x6E), '.' (46, 0x2E), '1' (49, 0x31) }` instead. This is not an
 *  issue for Google Test 1.11.0 but to work around this in a consistent manner
 *  we just use `const char*` instead.
 */
class CalcParserPureTest
  : public CalcParserTest, public ::testing::WithParamInterface<const char*> {};

/**
 * Test that parsing succeeds on the given input file.
 *
 * `null_stream` is used as the output stream so suppress all printing.
 */
TEST_P(CalcParserPureTest, PureParseTest)
{
  pdcalc::calc_parser parser{null_stream};
  EXPECT_TRUE(parser(test_data_dir_ / GetParam()));
}

INSTANTIATE_TEST_SUITE_P(
  BaseSuite,
  CalcParserPureTest,
  ::testing::Values("sample.in.1", "sample.in.2", "sample.in.3")
);

}  // namespace
