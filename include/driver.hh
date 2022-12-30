/** @file tools.hpp
 *
 * @copyright (C) 2022 Henrique Silva
 *
 *
 * @author Henrique Silva <hcpsilva@inf.ufrgs.br>
 *
 * @section LICENSE
 *
 * This file is subject to the terms and conditions defined in the file
 * 'LICENSE', which is part of this source code package.
 */

#pragma once

#include <istream>
#include <map>
#include <string>
#include <fstream>

#include "parser.hh"

#define YY_DECL \
        yy::parser::symbol_type yylex(hcpsilva::driver& driver)

YY_DECL;

namespace hcpsilva {

class driver {
public:
    driver(std::string const& file_name);

    driver() = default;

    int parse(std::string const& file_name);

    int parse();

    void begin_scan();

    void end_scan();

    yy::location location;

private:
    std::string file_name;

    std::ifstream input_file;
};

}
