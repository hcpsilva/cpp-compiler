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
};

}
