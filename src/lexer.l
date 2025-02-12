/**
 * lexer.l
 *
 * Author: Derek Huang
 * Summary: pdcalc C++ Flex input
 * Copyright: MIT License
 */

/* Lexer is never going to be used interactively but is non-reetrant. We don't
 * generate the input() and yyunput() functions since it will not be
 * interactive and must make lexer non-reentrant to work with C++ Bison parser.
 * The debug option is provided to allow tracing of the lexer.
 */
%option noinput nounput never-interactive debug

%{
// only contains warning macro helpers, so ok to put first
#include "pdcalc/warnings.h"

#include <cerrno>
#include <cstdio>
#include <cstring>

// MSVC complains that stdint.h is redefining fixed-width integral type macros
// like INT8_MIN, UINT32_MAX, etc. so disable this warning. this can also be
// avoided by putting #include <cstdio> in a top% block
PDCALC_MSVC_WARNING_PUSH()
PDCALC_MSVC_WARNING_DISABLE(4005)
#include <stdexcept>
PDCALC_MSVC_WARNING_POP()

#include <string>
#include <string_view>
#include <variant>

// {FIXME} should namespace source with pdcalc
#include "calc_parser_impl.hh"    // includes parser.yy.h
#include "pdcalc/calc_symbol.hh"

/**
 * User-defined action run after token match before its rule action.
 *
 * Here we just advance the location reference's end position columns by the
 * length of the token that was just matched to track locations.
 *
 * Note that `YY_USER_ACTION` must be a full statement ending with a semicolon
 * or braced context as otherwise you will get a compile error.
 */
#define YY_USER_ACTION loc.columns(yyleng);

namespace pdcalc {

/**
 * Symbol visitor to determine the correct symbol token via its value type.
 */
class symbol_token_visitor {
public:
  /**
   * Ctor.
   *
   * @param iden Symbol identifier
   * @param loc Parser location
   */
  symbol_token_visitor(std::string_view iden, const yy::location& loc) noexcept
    : iden_{iden}, loc_{loc}
  {}

  /**
   * Indicate to the Bison parser that identifier has a boolean value.
   */
  auto operator()(bool /*value*/) const
  {
    return yy::parser::make_BOOL_IDEN({iden_.begin(), iden_.end()}, loc_);
  }

  /**
   * Indicate to the Bison parser that identifier has a long value.
   */
  auto operator()(long /*value*/) const
  {
    return yy::parser::make_LONG_IDEN({iden_.begin(), iden_.end()}, loc_);
  }

  /**
   * Indicate to the Bison parser that identifier has a double value.
   */
  auto operator()(double /*value*/) const
  {
    return yy::parser::make_DOUBLE_IDEN({iden_.begin(), iden_.end()}, loc_);
  }

private:
  std::string_view iden_;
  const yy::location& loc_;
};

}  // namespace pdcalc
%}

/* Start conditions */

/* Python-style "#" comment */
%x LINE_COMMENT

/* Token definitions */

DIGIT          [0-9]
CHAR           [a-zA-Z]
/* CHARS          {CHAR}+ */
/* MAYBE_CHARS    {CHAR}* */
ALNUM          [a-zA-Z0-9]
/* ALNUMS         {ALNUM}+ */
/* MAYBE_ALNUMS   {ALNUM}* */
DIGITS         {DIGIT}+
MAYBE_DIGITS   {DIGIT}*
INT            -?{DIGITS}
/* Note that we allow a trailing . here */
FLOAT          {INT}"."{MAYBE_DIGITS}
IDEN           ({CHAR}|_)+({ALNUM}|_)*
/* If we implement commands in the REPL */
/* COMMAND        @{IDEN} */
/* We treat blanks and newlines separately for accurate location tracking, as
 * only newlines result in column being reset and moving to next line. Location
 * is stepped for both blanks and newlines, but newlines increase the number of
 * lines by the number of newlines that are read.
 */
BLANKS         [ \t\r]+
NEWLINES       \n+

/* Rules */
%%

%{
  // location setup code run before scanning. PDCALC_YYLEX is a friend of the
  // pdcalc::calc_parser_impl class and so can update the location_ member directly
  auto& loc = driver.location_;
  // move start position onto previous end position
  loc.step();
%}

  /* Arithmetic literals */
{INT}                   return yy::parser::make_INTEGRAL(std::stol(yytext), loc);
{FLOAT}                 return yy::parser::make_FLOATING(std::stod(yytext), loc);
  /* Grammar tokens */
";"                     return yy::parser::make_SEMICOLON(loc);
","                     return yy::parser::make_COMMA(loc);
  /* Arithmetic operators */
"+"                     return yy::parser::make_PLUS(loc);
"-"                     return yy::parser::make_MINUS(loc);
"*"                     return yy::parser::make_STAR(loc);
"/"                     return yy::parser::make_SLASH(loc);
"%"                     return yy::parser::make_PERCENT(loc);
  /* Bitwise operators */
"|"                     return yy::parser::make_PIPE(loc);
"&"                     return yy::parser::make_AMPERSAND(loc);
"^"                     return yy::parser::make_CARET(loc);
"<<"                    return yy::parser::make_LSHIFT(loc);
">>"                    return yy::parser::make_RSHIFT(loc);
"~"                     return yy::parser::make_TILDE(loc);
  /* Comparison operators */
"<"                     return yy::parser::make_LANGLE(loc);
">"                     return yy::parser::make_RANGLE(loc);
"<="                    return yy::parser::make_LEQUALS(loc);
">="                    return yy::parser::make_GEQUALS(loc);
"=="                    return yy::parser::make_EQUALS(loc);
"!="                    return yy::parser::make_NOT_EQUALS(loc);
  /* Boolean literals */
"true"                  return yy::parser::make_TRUTH(true, loc);
"false"                 return yy::parser::make_TRUTH(false, loc);
  /* Boolean operators */
"&&"                    return yy::parser::make_AND(loc);
"||"                    return yy::parser::make_OR(loc);
"!"                     return yy::parser::make_NOT(loc);
  /* Parentheses */
"("                     return yy::parser::make_LPAREN(loc);
")"                     return yy::parser::make_RPAREN(loc);
  /* Assignment operators (TODO: add some bitwise ones) */
"="                     return yy::parser::make_ASSIGN(loc);
"+="                    return yy::parser::make_ASSIGN_PLUS(loc);
"-="                    return yy::parser::make_ASSIGN_MINUS(loc);
"*="                    return yy::parser::make_ASSIGN_MULTIPLY(loc);
"/="                    return yy::parser::make_ASSIGN_DIVIDE(loc);
  /* Known types */
  /* "long"                  return yy::parser::make_T_LONG(loc); */
  /* int used as a synonym for long */
  /* "int"                   return yy::parser::make_T_LONG(loc); */
  /* "double"                return yy::parser::make_T_DOUBLE(loc); */
  /* "bool"                  return yy::parser::make_T_BOOL(loc); */
  /* Start parsing line comment when '#' is seen */
"#"                     BEGIN(LINE_COMMENT);
  /* Ignore comment contents until newline */
<LINE_COMMENT>[^\n]*
  /* For each commented line, update position, and return the normal lexing */
<LINE_COMMENT>\n        loc.lines(yyleng); loc.step(); BEGIN(INITIAL);
  /* {COMMAND}               printf("A command name: %s\n", yytext); */
  /* Skipped tokens */
{BLANKS}                loc.step();
{NEWLINES}              loc.lines(yyleng); loc.step();
  /* Built-in function names */
"exp"                   return yy::parser::make_F_EXP(loc);
"log"                   return yy::parser::make_F_LOG(loc);
"log2"                  return yy::parser::make_F_LOG2(loc);
"log10"                 return yy::parser::make_F_LOG10(loc);
"sqrt"                  return yy::parser::make_F_SQRT(loc);
"max"                   return yy::parser::make_F_MAX(loc);
"min"                   return yy::parser::make_F_MIN(loc);
"sin"                   return yy::parser::make_F_SIN(loc);
"cos"                   return yy::parser::make_F_COS(loc);
"tan"                   return yy::parser::make_F_TAN(loc);
  /* Identifiers */
{IDEN}                  {
                          // lookup symbol. if not found, unknown identifier
                          auto sym = driver.get_symbol(yytext);
                          if (!sym)
                            return yy::parser::make_UNKNOWN_IDEN(yytext, loc);
                          // otherwise, apply visitor to get correct token
                          pdcalc::symbol_token_visitor vis{yytext, loc};
                          return std::visit(vis, sym->value());
                        }
  /* Default rule */
.                       throw yy::parser::syntax_error{
                          loc,
                          "Unrecognized token '" + std::string{yytext} + "'"
                        };
  /* With Bison locations turned on make_YYEOF needs to be explicitly used */
<<EOF>>                 return yy::parser::make_YYEOF(loc);

%%

namespace pdcalc {

/**
 * Perform setup for the Flex lexer.
 *
 * @param input_file Input file to read. If empty or "-", `stdin` is used.
 * @param enable_debug `true` to turn on lexer tracing, default `false`
 * @returns `true` on success, `false` on failure and sets `last_error_`
 */
bool calc_parser_impl::lex_setup(
  const std::string& input_file, bool enable_debug) noexcept
{
  // enable/disable debugging. note yy_flex_debug declaration is not exported
  // in the Flex-generated lexer.yy.h header, so we have to implement this
  // function directly as part of the generated lexer.yy.cc file.
  // TODO: use yyset_debug instead, which is exported in lexer.yy.h
  yy_flex_debug = enable_debug;
  // empty file or "-" to read from stdin. latter follows POSIX conventions
  if (input_file.empty() || input_file == "-") {
    yyin = stdin;
    return true;
  }
  // otherwise, attempt to read from file. handle error
  if ((yyin = std::fopen(input_file.c_str(), "r")) == nullptr) {
    last_error_ =
      "Error opening " + input_file + ": " + std::string{std::strerror(errno)};
    return false;
  }
  return true;
}

/**
 * Perform cleanup for the Flex lexer.
 *
 * Currently, all this does is close `yyin` unless `yyin` is `stdin`.
 *
 * @param input_file Input file passed to `lex_setup`. Used in error reporting.
 * @returns `true` on success, `false` on failure and sets `last_error_`
 */
bool calc_parser_impl::lex_cleanup(const std::string& input_file) noexcept
{
  if (yyin != stdin && std::fclose(yyin)) {
    last_error_ =
      "Error closing " + input_file + ": " + std::string{std::strerror(errno)};
    return false;
  }
  return true;
}

}  // namespace pdcalc
