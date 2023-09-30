/**
 * @file calc_parser.h
 * @author Derek Huang
 * @brief C++ header for the infix calculator parse driver
 * @copyright MIT License
 */

#ifndef PDCALC_CALC_PARSER_H_
#define PDCALC_CALC_PARSER_H_

#include <string>

#include "pdcalc/dllexport.h"
#include "pdcalc/warnings.h"

// when using raw pointer for PIMPL, don't need <memory>
#ifndef PDCALC_RAW_PIMPL
#include <memory>
#endif  // PDCALC_RAW_PIMPL

namespace pdcalc {

// forward declaration for implementation class
class calc_parser_impl;

/**
 * `pdcalc` infix calculator parse driver.
 *
 * Encapsulates the Flex/Bison generated lexer + parser and driver
 * implementation in an ABI-stable representation.
 */
class PDCALC_API calc_parser {
public:
  /**
   * Ctor.
   */
  calc_parser();

  /**
   * Dtor.
   */
  ~calc_parser();

  /**
   * Deleted copy ctor.
   */
  calc_parser(const calc_parser& other) = delete;

  /**
   * Parse input from `stdin`.
   *
   * @param enable_trace `true` to enable lexer and parser tracing
   * @returns `true` on success, `false` on failure
   */
  bool parse(bool enable_trace = false)
  {
    return parse("", enable_trace);
  }

  /**
   * Parse the specified input file.
   *
   * @param input_file File to read input from, empty or "-" for `stdin`
   * @param enable_trace `true` to enable lexer and parser tracing
   * @returns `true` on success, `false` on failure
   */
  bool parse(const std::string& input_file, bool enable_trace = false)
  {
    return parse(input_file, enable_trace, enable_trace);
  }

  /**
   * Parse the specified input file.
   *
   * @param input_file File to read input from, empty or "-" for `stdin`
   * @param trace_lexer `true` to enable lexer tracing
   * @param trace_parser `true` to enable parser tracing
   * @returns `true` on success, `false` on failure
   */
  bool parse(const std::string& input_file, bool trace_lexer, bool trace_parser);

  /**
   * Parse input from `stdin`.
   *
   * @param enable_trace `true` to enable lexer and parser tracing
   * @returns `true` on success, `false` on failure
   */
  auto operator()(bool enable_trace = false)
  {
    return parse(enable_trace);
  }

  /**
   * Parse the specified input file.
   *
   * @param input_file File to read input from, empty or "-" for `stdin`
   * @param enable_trace `true` to enable lexer and parser tracing
   * @returns `true` on success, `false` on failure
   */
  auto operator()(const std::string& input_file, bool enable_trace = false)
  {
    return parse(input_file, enable_trace);
  }

  /**
   * Parse the specified input file.
   *
   * @param input_file File to read input from, empty or "-" for `stdin`
   * @param trace_lexer `true` to enable lexer tracing
   * @param trace_parser `true` to enable parser tracing
   * @returns `true` on success, `false` on failure
   */
  auto operator()(
    const std::string& input_file, bool trace_lexer, bool trace_parser)
  {
    return parse(input_file, trace_lexer, trace_parser);
  }

  /**
   * Return the last error encountered by the parser.
   */
  const std::string& last_error() const noexcept;

private:
  // if requested, use raw instead of STL unique_ptr to support PIMPL
#if defined(PDCALC_RAW_PIMPL)
  calc_parser_impl* impl_;
#else
  // MSVC emits C4251 complaining that DLL-interface is needed. we're already
  // using PIMPL, anything else STL-related is a Microsoft problem
  PDCALC_MSVC_WARNING_PUSH()
  PDCALC_MSVC_WARNING_DISABLE(4251)
  std::unique_ptr<calc_parser_impl> impl_;
  PDCALC_MSVC_WARNING_POP()
#endif  // !defined(PDCALC_RAW_PIMPL)
};

}  // namespace pdcalc

#endif  // PDCALC_CALC_PARSER_H_
