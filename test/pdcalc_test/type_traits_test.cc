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
#include <variant>

#include <gtest/gtest.h>

#include "pdcalc/common.h"
#include "pdcalc/testing/gtest.hh"

namespace {

// shorter name for PDCALC_IDENTITY
#define I_ PDCALC_IDENTITY

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

PDCALC_GTEST_TYPED_TEST_SUITE(
  TypeIdentityTest,
  I_(std::pair<double, int>),
  I_(std::pair<long, short>),
  I_(std::pair<std::string, const char*>),
  I_(std::pair<std::string, const char[20]>)
);

/**
 * Test that `type_identity_t` is working as expected.
 */
TYPED_TEST(TypeIdentityTest, Test)
{
  EXPECT_TRUE(this->result_);
}

/**
 * Template test fixture for testing `tuple_contains`.
 *
 * @tparam T Tuple of truth type, input type, and tuple type
 */
template <typename T>
class TupleContainsTest;

/**
 * Partial specialization for real `tuple_contains` tests.
 *
 * @tparam R Truth type
 * @tparam T Input type
 * @tparam Ts... Tuple types
 */
template <typename R, typename T, typename... Ts>
class TupleContainsTest<std::tuple<R, T, std::tuple<Ts...>>>
  : public ::testing::Test {
protected:
  // expected and actual result
  static constexpr bool expected_ = R::value;
  static constexpr bool actual_ = pdcalc::tuple_contains_v<std::tuple<Ts...>, T>;
};

PDCALC_GTEST_TYPED_TEST_SUITE(
  TupleContainsTest,
  I_(std::tuple<std::true_type, int, std::tuple<double, char, int>>),
  I_(std::tuple<std::true_type, unsigned, std::tuple<unsigned, char, int>>),
  I_(std::tuple<std::false_type, int, std::tuple<char, unsigned>>),
  I_(std::tuple<std::true_type, void*, std::tuple<char, const char*, void*>>)
);

/**
 * Test that `tuple_contains_v` works as expected.
 */
TYPED_TEST(TupleContainsTest, Test)
{
  EXPECT_EQ(this->expected_, this->actual_);
}

/**
 * Template test fixture for testing `is_variant_alternative`.
 *
 * @tparam T Tuple of truth type, input type, and variant type
 */
template <typename T>
class IsVariantAltTest;

/**
 * Partial specialization for real `is_variant_alternative` tests.
 *
 * @tparam R Truth type
 * @tparam T Input type
 * @tparam Ts.. Variant alternative types
 */
template <typename R, typename T, typename... Ts>
class IsVariantAltTest<std::tuple<R, T, std::variant<Ts...>>>
  : public ::testing::Test {
protected:
  using vtype = std::variant<Ts...>;
  // expected and actual result
  static constexpr bool expected_ = R::value;
  static constexpr bool actual_ = pdcalc::is_variant_alternative_v<vtype, T>;
};

PDCALC_GTEST_TYPED_TEST_SUITE(
  IsVariantAltTest,
  I_(std::tuple<std::true_type, int, std::variant<double, int, char>>),
  I_(std::tuple<std::false_type, void*, std::variant<int, unsigned>>),
  I_(std::tuple<std::true_type, double, std::variant<double, char*, char>>)
);

/**
 * Test that `is_variant_alternative_v` works as expected.
 */
TYPED_TEST(IsVariantAltTest, Test)
{
  EXPECT_EQ(this->expected_, this->actual_);
}

}  // namespace
