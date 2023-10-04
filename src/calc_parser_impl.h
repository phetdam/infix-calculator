/**
 * @file pdcalc/calc_parser_impl.h
 * @author Derek Huang
 * @brief C++ header for the infix calculator parse driver implementation
 * @copyright MIT License
 */

#ifndef PDCALC_CALC_PARSER_IMPL_H_
#define PDCALC_CALC_PARSER_IMPL_H_

#include <filesystem>
#include <string>

/**
 * Forward declaration to satisfy the `yy::parser` definition.
 *
 * The `yy::parser` ctor takes `calc_parser_impl&` as a parameter.
 */
namespace pdcalc { class calc_parser_impl; }

/**
 * The C++ header generated by Bison defining the parsing class.
 *
 * We need this in order to use `YY_DECL`, and so this must be included first.
 */
#include "parser.yy.h"

/**
 * `YY_DECL` function declaration return type.
 *
 * This is defined separately so the `parser` friend declaration can use it.
 */
#define PDCALC_YYLEX_RETURN yy::parser::symbol_type

/**
 * `YY_DECL` function name.
 *
 * Usually this can be left as `yylex` unless the Flex name prefix is changed.
 */
#define PDCALC_YYLEX yylex

/**
 * `YY_DECL` function declaration arguments.
 *
 * Should be a comma-separated list of function arguments.
 */
#define PDCALC_YYLEX_ARGS pdcalc::calc_parser_impl& driver

/**
 * Macro declaring `yylex` in the format the Bison parser expects.
 *
 * The corresponding parser handles complete symbols and uses variant values.
 */
#define YY_DECL PDCALC_YYLEX_RETURN PDCALC_YYLEX(PDCALC_YYLEX_ARGS)

/**
 * `yylex` declaration compatible with C++ Bison parser.
 *
 * There is no need to make this `extern "C"` since the generated Flex lexer
 * is being compiled as C++, not as straight C code.
 */
YY_DECL;

namespace pdcalc {

/**
 * `pdcalc` infix calculator parse driver implementation.
 *
 * Encapsulates the Flex/Bison generated lexer + parser. We need a separated
 * implementation class as there is no way to export the generated Flex/Bison
 * functions + classes without using CMake's `CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS`.
 * Using PIMPL also provides a more stable ABI, which is a good thing.
 */
class calc_parser_impl {
public:
  /**
   * Parse the specified input file.
   *
   * @param input_file File to read input from, empty or "-" for `stdin`
   * @param trace_lexer `true` to enable lexer tracing
   * @param trace_parser `true` to enable parser tracing
   * @returns `true` on success, `false` on failure
   */
  bool parse(
    const std::filesystem::path& input_file,
    bool trace_lexer,
    bool trace_parser);

  // allow lexer to access to the parse driver members to update location +
  // error note we use (::PDCALC_YYLEX) to tell compiler PDCALC_YYLEX is in the
  // global namespace, not in the current enclosing pdcalc namespace
  friend PDCALC_YYLEX_RETURN (::PDCALC_YYLEX)(PDCALC_YYLEX_ARGS);
  // allow parser to access parse driver members to update location + error
  friend class yy::parser;

  /**
   * Return a message describing the last error that occurred.
   *
   * Errors can occur before, during, or after parsing.
   */
  const auto& last_error() const noexcept { return last_error_; }

private:
  yy::location location_;
  std::string last_error_;

  /**
   * Perform setup for the Flex lexer.
   *
   * @param input_file Input file to read. If empty or "-", `stdin` is used.
   * @param enable_debug `true` to turn on lexer tracing, default `false`
   * @returns `true` on success, `false` on failure and sets `last_error_`
   */
  bool lex_setup(const std::string& input_file, bool enable_debug) noexcept;

  /**
   * Perform cleanup for the Flex lexer.
   *
   * Currently, all this does is close `yyin` unless `yyin` is `stdin`.
   *
   * @param input_file Input file passed to `lex_setup`. Used in error reporting.
   */
  bool lex_cleanup(const std::string& input_file) noexcept;
};

}  // namespace pdcalc

#endif  // PDCALC_CALC_PARSER_IMPL_H_
