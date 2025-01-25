/**
 * @file pdcalc_demo.cc
 * @author Derek Huang
 * @brief C++ demo program using pdcalc
 * @copyright MIT License
 */

#include <filesystem>

// TODO: consider having a top-level "main" API header, e.g. <pdcalc/pdcalc.hh>
#include <pdcalc/calc_parser.hh>

namespace {

/**
 * Get the absolute path to this program's input file.
 */
const auto& input_path()
{
  static auto path = []
  {
    // path to this file
    std::filesystem::path this_file{__FILE__};
    // return input path using parent + stem
    return this_file.parent_path() / (this_file.stem().string() + ".in");
  }();
  return path;
}

}  // namespace

int main()
{
  // parse input file
  pdcalc::calc_parser parser;
  return !parser(input_path());
}
