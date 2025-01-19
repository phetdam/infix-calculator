/**
 * @file type_traits.hh
 * @author Derek Huang
 * @brief C++ header for general type traits helpers
 * @copyright MIT License
 */

#ifndef PDCALC_TYPE_TRAITS_HH_
#define PDCALC_TYPE_TRAITS_HH_

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

}  // namespace pdcalc

#endif  // PDCALC_TYPE_TRAITS_HH_
