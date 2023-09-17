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
  "Usage: " + progname + " [-h] [FILE...]\n"
  "\n"
  "A statement-based infix calculator.\n"
  "\n"
  "Reads arithmetic or logical expression statements from files or stdin and\n"
  "prints the results, prepended by the type, to stdout.\n"
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
 * @returns `EXIT_SUCCESS` if successful, `EXIT_FAILURE` on error
 */
int parse_files(const std::vector<std::string>& input_files)
{
  // check that input files exist and are regular
  for (const auto& input_file : input_files) {
    // file existence
    if (!std::filesystem::exists(input_file)) {
      std::cerr << progname << ": error: " << input_file <<
        " does not exist" << std::endl;
      return EXIT_FAILURE;
    }
    // not a directory, device, etc.
    if (!std::filesystem::is_regular_file(input_file)) {
      std::cerr << progname << ": error: " << input_file <<
        " is not a regular file" << std::endl;
      return EXIT_FAILURE;
    }
  }
  // parse in a batch
  pdcalc::parse_driver parser;
  for (const auto& input_file : input_files) {
    if (!parser(input_file)) {
      std::cerr << progname << ": error: " << input_file <<
        " parsing failed" << std::endl;
      return EXIT_FAILURE;
    }
  }
  return EXIT_SUCCESS;
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
  // process input files
  if (opt_map.find("file") != opt_map.end())
    return parse_files(opt_map.at("file"));
  // otherwise, parse input from stdin
  pdcalc::parse_driver parser;
  return !parser();
}
