/**
 * @file calc_parser_impl.cc
 * @author Derek Huang
 * @brief C++ source for the infix calculator parse driver implementation
 * @copyright MIT License
 */

#include "calc_parser_impl.h"

#include <filesystem>

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
  const std::filesystem::path& input_file, bool trace_lexer, bool trace_parser)
{
  // need file path as string
  auto path_string = input_file.string();
  // initialize Bison parser location for location tracking + reset last error
  location_.initialize(&path_string);
  last_error_ = "";
  // perform Flex lexer setup, create Bison parser, set debug level, parse
  if (!lex_setup(path_string, trace_lexer))
    return false;
  yy::parser parser{*this};
  parser.set_debug_level(trace_parser);
  auto status = parser.parse();
  // perform Flex lexer cleanup + return
  if (!lex_cleanup(path_string))
    return false;
  // last_error_ should already have been set if parsing is failing
  return !status;
}

}  // namespace pdcalc
