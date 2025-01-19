/**
 * @file string.hh
 * @author Derek Huang
 * @brief C++ header with string-related helpers
 * @copyright MIT License
 */

#ifndef PDCALC_STRING_HH_
#define PDCALC_STRING_HH_

#include "pdcalc/features.h"  // for PDCALC_HAS_CC26

#if !PDCALC_HAS_CC26
#include <string>
#include <string_view>

#include "pdcalc/common.h"
#include "pdcalc/type_traits.hh"
#endif  // !PDCALC_HAS_CC26

#if !PDCALC_HAS_CC26

// for ADL to work these operators are defined in std::
namespace std {
/**
 * Return a new string from a string and string view.
 *
 * @note This is listed as part of the C++26 draft standard.
 *
 * @tparam CharT Char type
 * @tparam Traits Char traits
 * @tparam Alloc Allocator type
 *
 * @param lhs String
 * @param rhs String view (non-deduced)
 */
template <typename CharT, typename Traits, typename Alloc>
PDCALC_CC20_CONSTEXPR auto operator+(
  const basic_string<CharT, Traits, Alloc>& lhs,
  pdcalc::type_identity_t<basic_string_view<CharT, Traits>> rhs)
{
  auto res = lhs;
  res.append(rhs);
  return res;
}

/**
 * Return a new string from a string view and a string.
 *
 * @note This is listed a part of the C++26 draft standard.
 *
 * @tparam CharT Char type
 * @tparam Traits Char traits
 * @tparam Alloc Allocator type
 *
 * @param lhs String view (non-deduced)
 * @param rhs String
 */
template <typename CharT, typename Traits, typename Alloc>
PDCALC_CC20_CONSTEXPR auto operator+(
  pdcalc::type_identity_t<basic_string_view<CharT, Traits>> lhs,
  const basic_string<CharT, Traits, Alloc>& rhs)
{
  return rhs + lhs;
}

}  // namespace std

#endif  // !PDCALC_HAS_CC26

#endif  // PDCALC_STRING_HH_
