/**
 * @file main.cc
 * @author Derek Huang
 * @brief Main source file for pdcalc
 * @copyright MIT License
 */

#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <iostream>
#include <string>
#include <string_view>
#include <type_traits>
#include <unordered_map>
#include <vector>

#include "pdcalc/parser.h"
#include "pdcalc/version.h"

namespace {

// type alias for the program options map
using cliopt_map = std::unordered_map<std::string, std::vector<std::string>>;

// program name, program version info, program usage
const std::string progname{"pdcalc"};
const std::string program_version_info{
  progname + " " + pdcalc::version + " (" + pdcalc::build_type + ", " +
  pdcalc::system_arch + " " + pdcalc::system_name + " " +
  pdcalc::system_version + ")"
};
const std::string program_usage{
  "Usage: " + progname + " [-h] [FILE...] [-t[l[p]]]\n"
  "\n"
  "A statement-based infix calculator.\n"
  "\n"
  "Reads arithmetic or logical expression statements from files or stdin and\n"
  "prints the results, prepended by the type, to stdout.\n"
  "\n"
  "Options:\n"
  "  -h, --help          Print this usage\n"
  "  -V, --version       Print version info\n"
  "\n"
  "  -t[l[p]], --trace[=lexer[,parser]]\n"
  "\n"
  "                      Enable tracing. The specifiers l, p can be passed to\n"
  "                      -t to enable lexer and parser tracing respectively,\n"
  "                      while the specifiers lexer, parser can be passed to\n"
  "                      --trace for the same purpose. If -t, --trace has no\n"
  "                      specifiers, both lexer and parser tracing is enabled."
};

/**
 * Parse the trace specifiers for the short trace option.
 *
 * @param opt_map Command-line option map
 * @param arg Short trace option, possibly with appended specifiers
 * @returns `true` on success, `false` otherwise
 */
bool parse_short_trace_args(cliopt_map& opt_map, const std::string_view& arg)
{
  using mapped_type = cliopt_map::mapped_type;
  // if exactly -t, then enable tracing for both
  if (arg == "-t") {
    opt_map.insert_or_assign("trace_lexer", mapped_type{});
    opt_map.insert_or_assign("trace_parser", mapped_type{});
    return true;
  }
  // remove any existing specifiers
  opt_map.erase("trace_lexer");
  opt_map.erase("trace_parser");
  // check specifiers
  auto trace_specs = arg.substr(2);
  for (auto spec : trace_specs) {
    switch (spec) {
      case 'l':
        opt_map.insert_or_assign("trace_lexer", mapped_type{});
        break;
      case 'p':
        opt_map.insert_or_assign("trace_parser", mapped_type{});
        break;
      default:
        std::cerr << progname << ": -t received unknown specifier '" << spec <<
          "'" << std::endl;
        return false;
    }
  }
  return true;
}

/**
 * Parse the trace specifiers for the long trace option.
 *
 * If the long trace option is specified as `--trace=`, tracing is disabled.
 *
 * @param opt_map Command-line option map
 * @param arg Long trace option, possibly with appended specifiers
 * @returns `true` on success, `false` otherwise
 */
bool parse_long_trace_args(cliopt_map& opt_map, const std::string_view& arg)
{
  using mapped_type = cliopt_map::mapped_type;
  using size_type = mapped_type::size_type;
  // if exactly --trace, then enable tracing for both
  if (arg == "--trace") {
    opt_map.insert_or_assign("trace_lexer", mapped_type{});
    opt_map.insert_or_assign("trace_parser", mapped_type{});
    return true;
  }
  // remove any existing specifiers
  opt_map.erase("trace_lexer");
  opt_map.erase("trace_parser");
  // get possibly comma-separated specifiers. arg must be 8 chars long or more
  auto trace_specs = arg.substr(8);
  // start and end indices for the target specifier
  size_type s_i = 0;
  size_type e_i = 0;
  // until s_i is past the end of trace_specs
  while (s_i < trace_specs.size()) {
    // get position of next comma. if npos (not found), truncate to size()
    e_i = trace_specs.find(',', s_i);
    if (e_i == std::string_view::npos)
      e_i = trace_specs.size();
    // get specifier, i.e. [s_i, e_i) substring
    auto trace_spec = trace_specs.substr(s_i, e_i - s_i);
    // handle appropriately; error if unknown
    if (trace_spec == "lexer")
      opt_map.insert_or_assign("trace_lexer", mapped_type{});
    else if (trace_spec == "parser")
      opt_map.insert_or_assign("trace_parser", mapped_type{});
    else {
      std::cerr << progname << ": --trace received unknown specifier '" <<
        trace_spec << "'" << std::endl;
      return false;
    }
    // update s_i one past e_i position
    s_i = e_i + 1;
  }
  return true;
}

/**
 * Parse incoming command-line args and store them in the options map.
 *
 * @param opt_map Command-line options map
 * @param argc Arg count from `main`
 * @param argv Arg vector from `main`
 * @returns `true` on parse success, `false` on parse failure
 */
bool parse_args(cliopt_map& opt_map, int argc, char** argv)
{
  using mapped_type = typename std::decay_t<decltype(opt_map)>::mapped_type;
  // loop through the arguments to collect options and their args if any
  for (int i = 1; i < argc; i++) {
    // current argument, use string_view to prevent copying
    std::string_view arg = argv[i];
    // help option
    if (arg == "-h" || arg == "--help")
      opt_map.insert_or_assign("help", mapped_type{});
    // version option
    else if (arg == "-V" || arg == "--version")
      opt_map.insert_or_assign("version", mapped_type{});
    // file to read from. if starting with "-", assume it is an option
    else if (arg.size() && arg[0] != '-') {
      // allow processing more than one file
      opt_map.try_emplace("file", mapped_type{});
      opt_map.at("file").emplace_back(arg);
    }
    // tracing short option
    else if (arg.substr(0, 2) == "-t") {
      if (!parse_short_trace_args(opt_map, arg))
        return false;
    }
    // tracing long option
    else if (arg.substr(0, 7) == "--trace") {
      if (!parse_long_trace_args(opt_map, arg))
        return false;
    }
    // unknown option
    else {
      std::cerr << "Error: Unknown option '" << argv[i] << "'. Try " <<
        progname << " --help for usage." << std::endl;
      return false;
    }
  }
  return true;
}

/**
 * Parse the given input file paths.
 *
 * @todo Replace with use of the `pdcalc` parser driver.
 *
 * @param input_files Input file paths
 * @param trace_lexer `true` to trace lexer operations
 * @param trace_parser `true` to trace parser operations
 * @returns `EXIT_SUCCESS` if successful, `EXIT_FAILURE` on error
 */
int parse_files(
  const std::vector<std::string>& input_files,
  bool trace_lexer,
  bool trace_parser)
{
  // check that input files exist and are regular
  for (const auto& input_file : input_files) {
    // file existence
    if (!std::filesystem::exists(input_file)) {
      std::cerr << progname << ": " << input_file << " does not exist" <<
        std::endl;
      return EXIT_FAILURE;
    }
    // not a directory, device, etc.
    if (!std::filesystem::is_regular_file(input_file)) {
      std::cerr << progname << ": " << input_file << " is not a regular file" <<
        std::endl;
      return EXIT_FAILURE;
    }
  }
  // parse in a batch
  pdcalc::parse_driver parser;
  for (const auto& input_file : input_files) {
    if (!parser(input_file, trace_lexer, trace_parser)) {
      std::cerr << progname << ": " << parser.last_error() << std::endl;
      return EXIT_FAILURE;
    }
  }
  return EXIT_SUCCESS;
}

}  // namespace

int main(int argc, char** argv)
{
  // parse command-line arguments, exiting on failure
  cliopt_map opt_map;
  if (!parse_args(opt_map, argc, argv))
    return EXIT_FAILURE;
  // print help
  if (opt_map.find("help") != opt_map.end()) {
    std::cout << program_usage << std::endl;
    return EXIT_SUCCESS;
  }
  // print version info
  if (opt_map.find("version") != opt_map.end()) {
    std::cout << program_version_info << std::endl;
    return EXIT_SUCCESS;
  }
  // process input files
  if (opt_map.find("file") != opt_map.end())
    return parse_files(
      opt_map.at("file"),
      opt_map.find("trace_lexer") != opt_map.end(),
      opt_map.find("trace_parser") != opt_map.end()
    );
  // otherwise, parse input from stdin
  pdcalc::parse_driver parser;
  if (!parser()) {
    std::cerr << progname << ": " << parser.last_error() << std::endl;
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
