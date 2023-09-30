/**
 * @file calc_parser_impl.cc
 * @author Derek Huang
 * @brief C++ source for the infix calculator parse driver implementation
 * @copyright MIT License
 */

#include "calc_parser_impl.h"

#include <string>

namespace pdcalc {

/**
 * Parse the specified input file.
 *
 * @param input_file File to read input from, empty or "-" for `stdin`
 * @param trace_lexer `true` to enable lexer tracing
 * @param trace_parser `true` to enable parser tracing
 * @returns `true` on success, `false` on failure
 */
bool calc_parser_impl::parse(
  const std::string& input_file, bool trace_lexer, bool trace_parser)
{
  // initialize Bison parser location for location tracking
  location_.initialize(&input_file);
  // perform Flex lexer setup, create Bison parser, set debug level, parse
  if (!lex_setup(input_file, trace_lexer))
    return false;
  yy::parser parser{*this};
  parser.set_debug_level(trace_parser);
  auto status = parser.parse();
  // perform Flex lexer cleanup + return
  if (!lex_cleanup(input_file))
    return false;
  // last_error_ should already have been set if parsing is failing
  return !status;
}

}  // namespace pdcalc
