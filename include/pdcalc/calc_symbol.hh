/**
 * @file calc_symbol.hh
 * @author Derek Huang
 * @brief C++ header for the infix calculator symbol type
 * @copyright MIT License
 */

#ifndef PDCALC_CALC_SYMBOL_HH_
#define PDCALC_CALC_SYMBOL_HH_

#include <string>
#include <string_view>
#include <utility>
#include <variant>

#include "pdcalc/type_traits.hh"

namespace pdcalc {

/**
 * Calculator symbol entry.
 *
 * This simply holds an identifier and a variant for the value.
 */
class calc_symbol {
public:
  using value_type = std::variant<bool, long, double>;

  /**
   * Ctor.
   *
   * Create a symbol from the given identifier with the long value 0.
   *
   * @param iden String identifier (symbol name)
   */
  calc_symbol(std::string_view iden) noexcept : calc_symbol(iden, 0L) {}

  /**
   * Ctor.
   *
   * Create a symbol from the given identifier and value.
   *
   * @note All types in `value_type` have non-throwing move.
   *
   * @tparam T type
   *
   * @param iden String identifier (symbol name)
   * @param value Symbol value
   */
  calc_symbol(std::string_view iden, value_type value) noexcept
    : iden_{iden}, value_{std::move(value)}
  {}

  /**
   * Get the symbol's identifier.
   */
  const auto& iden() const noexcept { return iden_; }

  /**
   * Get the variant value for the symbol.
   */
  const auto& value() const noexcept { return value_; }

  /**
   * Get a pointer to the held alternative if contained otherwise `nullptr`.
   *
   * @tparam T type
   */
  template <typename T, typename = is_variant_alternative_t<value_type, T>>
  auto get_if() const noexcept
  {
    return std::get_if<T>(&value_);
  }

  /**
   * Get a const reference to the held alternative if contained.
   *
   * @tparam T type
   */
  template <typename T, typename = is_variant_alternative_t<value_type, T>>
  const auto& get() const noexcept
  {
    return std::get<T>(value_);
  }

private:
  std::string iden_;
  value_type value_;
};

/**
 * Check that two symbols compare equal.
 *
 * Symbols are uniquely identified by identifiers so if two symbols have the
 * same identifier, they are considered equal, even if the values differ.
 *
 * @param a First symbol
 * @param b Second symbol
 */
inline bool operator==(const calc_symbol& a, const calc_symbol& b)
{
  return a.iden() == b.iden();
}

}  // namespace pdcalc

namespace std {

/**
 * Hash specialization for the `calc_symbol`.
 *
 * Symbols are uniquely identified by their identifiers.
 */
template <>
struct hash<pdcalc::calc_symbol> {
  auto operator()(const pdcalc::calc_symbol& sym) const
  {
    return hash<std::string>{}(sym.iden());
  }
};

}  // namespace std

#endif  // PDCALC_CALC_SYMBOL_HH_
