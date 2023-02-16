/** @file driver.hh
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

#include <fstream>
#include <istream>
#include <map>
#include <string>
#include <optional>

#include "ast.hh"
#include "lexic_values.hh"
#include "location.hh"
#include "parser.hh"
#include "scanner.hh"
#include "tree.hh"

namespace hcpsilva {

class driver {
public:
    driver(std::string const& file_name);

    driver() = default;

    auto parse() -> int;

    auto yylex() -> yy::parser::symbol_type { return this->scanner.lex(*this); }

    auto swap_input(std::string const& file_name) -> void;
    auto swap_input(std::ifstream& input) -> void;
    auto swap_input() -> void;

    auto print_ast() -> void;

    friend class yy::scanner;
    friend class yy::parser;

private:
    yy::location  location;
    std::string   file_name;
    std::ifstream input;
    yy::scanner   scanner;
    std::optional<tree_node<lexic_value>> ast;
    yy::parser    parser = yy::parser(*this);
};

}
