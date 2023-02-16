/** @file driver.cpp
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

#include "driver.hh"

#include <fstream>
#include <iostream>
#include <stdexcept>

namespace hcpsilva {

driver::driver(std::string const& file_name)
    : location(&file_name)
    , file_name(file_name)
    , input(file_name)
    , scanner(&input)
{
}

auto driver::swap_input(std::string const& file_name) -> void
{
    if (file_name.empty())
        throw std::runtime_error("driver error, new input file name is empty\n");

    // TODO: maybe also check if the file exists... sigh. use std::filesystem

    this->location.initialize(&file_name);

    this->file_name = file_name;

    if (this->input.is_open())
        this->input.close();

    this->input = std::ifstream(file_name);

    this->scanner.switch_streams(&this->input);
}

auto driver::swap_input(std::ifstream& input) -> void
{
    this->location.initialize();

    this->file_name = "";

    if (this->input.is_open())
        this->input.close();

    this->input.swap(input); // WARN: generally not what one means to do?
                             // swapping on input variables is perhaps bad
                             // taste and we should instead receive a rvalue
                             // reference if we were to do this

    this->scanner.switch_streams(&this->input);
}

auto driver::swap_input() -> void
{
    this->location.initialize();

    this->file_name = "";

    if (this->input.is_open())
        this->input.close();

    this->scanner.switch_streams();
}

auto driver::parse(void) -> int
{
    return this->parser.parse();
}

auto driver::print_ast() -> void
{
    if (this->ast) {
        this->ast->print();
        this->ast->print_edges();
    }
}

}
