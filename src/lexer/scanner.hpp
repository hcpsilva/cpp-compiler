/** @file scanner.hpp - Lexical analysis scanner header
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
 *
 * @section DESCRIPTION
 *
 * Includes the declaration of some functions that either the lexer
 * itself uses or other public functions to other modules.
 */

#pragma once

#include "tokens.h"

#include <stdio.h>

#include "tokens.h"
#include "utils.h"
#include "debug.h"

extern int yylex(void);
extern int yylex_destroy(void);

extern FILE* yyin;
extern char* yytext;

extern int yylineno;
