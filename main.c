/** @file main.c
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

#include <cstdio>
#include <cstdlib>

#include "debug.hpp"
#include "src/lexer/tools.hpp"

int yylex();
int yylex_destroy();

extern char *yytext;
extern FILE *yyin;

#define UNUSED(x) (void)(x)

int main(int argc, char** argv)
{
    UNUSED(argc);
    UNUSED(argv);

    int token = 0;

    V_PRINTF("=> Initiating lexer...\n");

    while ((token = yylex())) {
        PRINT_NAME(token);
        fprintf(stderr, "VALUE: %d\n", token);
    }

    yylex_destroy();

    return 0;
}
