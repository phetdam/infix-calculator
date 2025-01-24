/**
 * @file type_traits.hh
 * @author Derek Huang
 * @brief C++ header for general type traits helpers
 * @copyright MIT License
 */

#ifndef PDCALC_TYPE_TRAITS_HH_
#define PDCALC_TYPE_TRAITS_HH_

#include <cstdint>
#include <tuple>
#include <type_traits>
#include <utility>
#include <variant>

namespace pdcalc {

/**
 * Type identity traits for establishing non-deduced contexts.
 *
 * This should be used unless `type_identity` is available as in C++20.
 *
 * @tparam T type
 */
template <typename T>
struct type_identity {
  using type = T;
};

/**
 * Type alias for establishing a non-deduced context for a type.
 *
 * @tparam T type
 */
template <typename T>
using type_identity_t = typename type_identity<T>::type;

/**
 * Traits class to determine if a type is in the type list of a `std::tuple`.
 *
 * @tparam T `std::tuple<Ts...>` type
 * @tparam U Type candidate
 */
template <typename T, typename U>
struct tuple_contains : std::false_type {};

/**
 * Partial specializaton to determine if `T` is the in list of tuple types.
 *
 * @tparam Ts... Tuple type pack
 * @tparam T Target type
 */
template <typename... Ts, typename T>
struct tuple_contains<std::tuple<Ts...>, T>
  : std::bool_constant<(std::is_same_v<T, Ts> || ...)> {};

/**
 * Indicate that a target type is in the list of tuple types.
 *
 * @tparam T `std::tuple<Ts...>` type
 * @tparam U Type candidate
 */
template <typename T, typename U>
constexpr bool tuple_contains_v = tuple_contains<T, U>::value;

/**
 * Traits class to extract the type pack of a `std::variant` into a tuple.
 *
 * @tparam T type
 */
template <typename T>
struct variant_alternatives {};

/**
 * Partial specialization for a `std::variant<Ts...>`.
 *
 * @tparam Ts... types
 */
template <typename... Ts>
struct variant_alternatives<std::variant<Ts...>> {
  using type = std::tuple<Ts...>;
};

/**
 * SFINAE-capable type alias for a tuple of variant alternative types.
 *
 * @tparam T type
 */
template <typename T>
using variant_alternatives_t = typename variant_alternatives<T>::type;

/**
 * Traits class to check if a type is storable in the given `std::variant`.
 *
 * @tparam V Variant type
 * @tparam T Type candidate
 */
template <typename V, typename T>
struct is_variant_alternative : std::false_type {};

/**
 * Partial specialization for a `std::variant<Ts...>`.
 *
 * @tparam Ts... Variant types
 * @tparam T Type candidate
 */
template <typename... Ts, typename T>
struct is_variant_alternative<std::variant<Ts...>, T> : std::bool_constant<
  tuple_contains_v<variant_alternatives_t<std::variant<Ts...>>, T> > {};

/**
 * Indicate a given type is one of the variant's alternative types.
 *
 * @tparam T Target type
 * @tparam Ts... Variant alternatives
 */
template <typename T, typename... Ts>
constexpr bool
is_variant_alternative_v = is_variant_alternative<std::variant<Ts...>, T>::value;

/**
 * SFINAE helper for checking if a type is a variant's alternative type.
 *
 * @tparam T Target type
 * @tparam Ts... Variant alternatives
 */
template <typename T, typename... Ts>
using is_variant_alternative_t = std::
  enable_if_t<is_variant_alternative_v<std::variant<Ts...>, T>>;

}  // namespace pdcalc

#endif  // PDCALC_TYPE_TRAITS_HH_
