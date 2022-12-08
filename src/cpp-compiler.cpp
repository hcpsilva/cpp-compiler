/** @file cpp-compiler.cpp
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

#include "cpp-compiler.hpp"

extern bool is_done_scanning;

int get_line_number(void);

auto isRunning(void) -> int
{
    return !is_done_scanning;
}

auto initMe(void) -> void
{
    return;
}

auto getLineNumber(void) -> int
{
    return get_line_number();
}

