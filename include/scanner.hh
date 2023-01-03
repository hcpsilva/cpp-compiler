#pragma once

#include <iostream>

#if !defined(yyFlexLexerOnce)
#include "FlexLexer.h"
#endif

#include "parser.hh"

namespace hcpsilva {
    class driver;
}

namespace yy {

class scanner : public yyFlexLexer {
public:
    scanner(std::istream* yyin = 0, std::ostream* yyout = 0)
        : yyFlexLexer(yyin, yyout) {}

    virtual auto lex(hcpsilva::driver& driver) -> parser::symbol_type;

    auto get_current_line(void) -> std::string const&;

    auto get_last_token(void) -> std::string const&;

private:
    std::string current_line;

    std::string last_token;

    auto on_new_token(char* yytext, int yyleng, char yy_hold_char) -> void;
};

}
