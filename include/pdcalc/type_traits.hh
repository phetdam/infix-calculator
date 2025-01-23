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
struct in_tuple_types : std::false_type {};

namespace detail {

/**
 * Implenentation class to check if a type is in the tuple's list of types.
 *
 * @tparam I `std::index_sequence<Is...>` with indices 0 until number of types
 * @tparam T `std::tuple<Ts...>`
 * @tparam U Target type
 */
template <typename I, typename T, typename U>
struct in_tuple_types_impl : std::false_type {};

/**
 * Partial specialization with actual checking logic.
 *
 * Checks that `U` matches at least one of the tuple types.
 *
 * @tparam Is... Indices `0` through `sizeof...(Ts) - 1`
 * @tparam Ts... Tuple type pack
 * @tparam U Target type
 */
template <std::size_t... Is, typename... Ts, typename U>
struct in_tuple_types_impl<std::index_sequence<Is...>, std::tuple<Ts...>, U>
  : std::bool_constant<
      (std::is_same_v<std::tuple_element_t<Is, std::tuple<Ts...>>, U> || ...)> {};

}  // namespace detail

/**
 * Partial specializaton to determine if `T` is the in list of tuple types.
 *
 * @tparam Ts... Tuple type pack
 * @tparam T Target type
 */
template <typename... Ts, typename T>
struct in_tuple_types<std::tuple<Ts...>, T> : detail::in_tuple_types_impl<
  std::index_sequence_for<Ts...>, std::tuple<Ts...>, T> {};

/**
 * Indicate that a target type is in the list of tuple types.
 *
 * @tparam T Target type
 * @tparam Ts... Tuple type pack
 */
template <typename T, typename... Ts>
constexpr bool in_tuple_types_v = in_tuple_types<std::tuple<Ts...>, T>::value;

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
  in_tuple_types_v<variant_alternatives_t<std::variant<Ts...>>, T> > {};

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
