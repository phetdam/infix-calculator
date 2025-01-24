/**
 * @file calc_parser.cc
 * @author Derek Huang
 * @brief C++ source for the infix calculator parse driver
 * @copyright MIT License
 */

#include "pdcalc/calc_parser.hh"

#include <filesystem>
#include <ostream>
#include <string>

#include "calc_parser_impl.hh"

namespace pdcalc {

/**
 * Ctor.
 *
 * @param sink Stream to write all non-error output to, default `std::cout`
 */
calc_parser::calc_parser(std::ostream& sink)
  : impl_{new calc_parser_impl{sink}}
{}

/**
 * Dtor.
 *
 * Nothing interesting here.
 */
#if defined(PDCALC_RAW_PIMPL)
calc_parser::~calc_parser() { delete impl_; }
#else
calc_parser::~calc_parser() = default;
#endif  // !defined(PDCALC_RAW_PIMPL)

/**
 * Return reference to stream all non-error output is written to.
 */
std::ostream& calc_parser::sink() const noexcept
{
  return impl_->sink();
}

/**
 * Parse the specified input file.
 *
 * @param input_file File to read input from, empty or "-" for `stdin`
 * @param trace_lexer `true` to enable lexer tracing
 * @param trace_parser `true` to enable parser tracing
 * @returns `true` on success, `false` on failure
 */
bool calc_parser::parse(
  const std::filesystem::path& input_file, bool trace_lexer, bool trace_parser)
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
