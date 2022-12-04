/** @file cpp-compiler.hpp
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

/**
 * Unnecessary.
 */
auto is_running(void) -> int;

/**
 * Does nothing.
 */
auto init(void) -> int;

// aliases
constexpr auto isRunning = is_running;
constexpr auto initMe = init;
