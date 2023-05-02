/**
 * @file main.cc
 * @author Derek Huang
 * @brief Main source file for pdcalc
 * @copyright MIT License
 */

#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>
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
  "Usage: " + progname + " [-h]\n"
  "\n"
  "REPL infix calculator.\n"
  "\n"
  "Currently, the only thing it does is tokenize input from stdin.\n"
  "\n"
  "Options:\n"
  "  -h, --help       Print this usage\n"
  "  -V, --version    Print version info"
};

/**
 * Parse incoming command-line args and store them in the options map.
 *
 * @param opt_map Command-line options map
 * @param argc Arg count from `main`
 * @param argv Arg vector from `main`
 * @returns `true` on parse success, `false` on parse failure
 */
bool parse_args(cliopt_map& opt_map, int argc, char **argv)
{
  using mapped_type = typename std::decay_t<decltype(opt_map)>::mapped_type;
  // loop through the arguments to collect options and their args if any
  for (int i = 1; i < argc; i++) {
    // help option
    if (!std::strcmp(argv[i], "-h") || !std::strcmp(argv[i], "--help"))
      opt_map.insert_or_assign("help", mapped_type{});
    // version option
    else if (!std::strcmp(argv[i], "-V") || !std::strcmp(argv[i], "--version"))
      opt_map.insert_or_assign("version", mapped_type{});
    // unknown option
    else {
      std::cerr << "Error: Unknown option '" << argv[i] << "'. Try " <<
        progname << " --help for usage." << std::endl;
      return false;
    }
  }
  return true;
}

}  // namespace

int main(int argc, char **argv)
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
  // run simple lexing routine reporting on all the tokens
  // while (yylex().type_get())
  //   ;
  // parser input and generate output
  yy::parser parser;
// support parser operation tracing
#if YYDEBUG
  parser.set_debug_level(1);
#endif  // YYDEBUG
  parser();
  return EXIT_SUCCESS;
}
