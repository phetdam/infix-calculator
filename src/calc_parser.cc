/**
 * @file calc_parser.cc
 * @author Derek Huang
 * @brief C++ source for the infix calculator parse driver
 * @copyright MIT License
 */

#include "pdcalc/calc_parser.h"

#include <string>

#include "calc_parser_impl.h"

namespace pdcalc {

/**
 * Ctor.
 *
 * All this does is default-construct the implementation.
 */
calc_parser::calc_parser() : impl_{new calc_parser_impl} {}

/**
 * Dtor.
 *
 * Nothing interesting here.
 */
calc_parser::~calc_parser() = default;

/**
 * Parse the specified input file.
 *
 * @param input_file File to read input from, empty or "-" for `stdin`
 * @param trace_lexer `true` to enable lexer tracing
 * @param trace_parser `true` to enable parser tracing
 * @returns `true` on success, `false` on failure
 */
bool calc_parser::parse(
  const std::string& input_file, bool trace_lexer, bool trace_parser)
{
  return impl_->parse(input_file, trace_lexer, trace_parser);
}

/**
 * Return a message describing the last error that occurred.
 *
 * Errors can occur before, during, or after parsing.
 */
const std::string& calc_parser::last_error() const noexcept
{
  return impl_->last_error();
}

}  // namespace pdcalc
