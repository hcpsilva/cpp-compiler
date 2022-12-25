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

#include "lexic.hpp"
#include "cpp-compiler-config.hpp"

#ifndef VERBOSE
#define V_LOG_LEXER(STR) ((void)0)
#define PRINT_NAME(TOKEN) printf("%u " #TOKEN " [%s]\n", get_line_number(), yytext)
#define PRINT_SPC_NAME(TOKEN) printf("%u TK_ESPECIAL [%c]\n", get_line_number(), TOKEN)
#else
#define V_LOG_LEXER(STR) printf("\n==> [%d]: " STR " {%s}\n", get_line_number(), yytext)
#define PRINT_NAME(TOKEN) ((void)0)
#define PRINT_SPC_NAME(TOKEN) ((void)0)
#endif

extern int yylineno;
