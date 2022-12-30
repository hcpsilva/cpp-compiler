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

#include <iostream>

namespace hcpsilva {

driver::driver(std::string const& file_name)
    : file_name(file_name)
    , input_file(file_name)
{
}

int driver::parse(std::string const& file_name)
{
    std::istream& input = (!file_name.empty())
        ? [&]() -> std::istream& {
            this->input_file.open(file_name);

            if (!this->input_file)
                abort(); // throw???

            return this->input_file;
        }()
        : std::cin;

    if (!file_name.empty()) {
        this->location.initialize(&file_name);
    } else {
        this->location.initialize();
    }

    yy::parser parser(*this);

    // parser.

    return parser.parse();
}

}
