/**
 * @file type_traits_test.cc
 * @author Derek Huang
 * @brief C++ type_traits.hh unit tests
 * @copyright MIT License
 */

#include "pdcalc/type_traits.hh"

#include <string>
#include <type_traits>
#include <utility>

#include <gtest/gtest.h>

namespace {

/**
 * Function that uses `type_identity_t`.
 *
 * This forces the second argument to convert to the first's type. The returned
 * value is a prvalue of `T` constructed from forwarding the converted param.
 *
 * @tparam T type
 */
template <typename T>
auto force_identity(T&& /*a*/, pdcalc::type_identity_t<T> b)
{
  return std::forward<T>(b);
}

/**
 * `TypeIdentityTest` test evaluation type.
 *
 * Uses `force_identity` to evaluate if `type_identity_t` works in `decltype`.
 *
 * @tparam T First type
 * @tparam U Second type, must convert to `T`
 */
template <typename T, typename U, typename = void>
struct type_identity_eval_traits : std::false_type {};

/**
 * Partial specialization if `force_identity` invocation works properly.
 *
 * @tparam T First type
 * @tparam U Second type, must convert to `T`
 */
template <typename T, typename U>
struct type_identity_eval_traits<T, U, std::enable_if_t<std::is_same_v<
  T, decltype(force_identity(std::declval<T>(), std::declval<U>()))>> >
  : std::true_type {};

/**
 * Template test fixture for testing `type_identity`.
 *
 * @tparam T Pair of types
 */
template <typename T>
class TypeIdentityTest;

/**
 * Partial specialization for real `type_identity` tests.
 *
 * @tparam T First type
 * @tparam U Second type, must convert to `T`
 */
template <typename T, typename U>
class TypeIdentityTest<std::pair<T, U>> : public ::testing::Test {
protected:
  // test result
  static constexpr bool result_ = type_identity_eval_traits<T, U>::value;
};

using TypeIdentityTestTypes = ::testing::Types<
  std::pair<double, int>,
  std::pair<long, short>,
  std::pair<std::string, const char*>,
  std::pair<std::string, const char[20]>
>;
TYPED_TEST_SUITE(TypeIdentityTest, TypeIdentityTestTypes);

/**
 * Test that `type_identity_t` is working as expected.
 */
TYPED_TEST(TypeIdentityTest, Test)
{
  EXPECT_TRUE(this->result_);
}

}  // namespace
