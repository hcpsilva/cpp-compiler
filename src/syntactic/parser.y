/** @file parser/parser.y -*- bison -*-
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

%{
 // #include "syntactic.h"
 #include "scanner.yy.hpp"
 void yyerror([[maybe_unused]] char const* s, ...) { };
%}

%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_BOOL
%token TK_PR_CHAR
%token TK_PR_IF
%token TK_PR_THEN
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_INPUT
%token TK_PR_OUTPUT
%token TK_PR_RETURN
%token TK_PR_FOR
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_LIT_FALSE
%token TK_LIT_TRUE
%token TK_LIT_CHAR
%token TK_IDENTIFICADOR

/* the following options enable us more information when printing the
 * error */
%define parse.error detailed
%locations

%%

    /* ---------- GLOBAL SCOPE ---------- */

    /* the source code can be empty, and variables require ';' */
source
    : %empty
    | source var_global ';'
    | source function
    ;

var_global
    : type id_var_global_rep
    ;

    /* we can have multiple variables being initialized at once */
id_var_global_rep
    : id_var_global
    | id_var_global_rep ',' id_var_global
    ;

id_var_global
    : TK_IDENTIFICADOR index
    | TK_IDENTIFICADOR
    ;

function
    : header block
    ;

    /* definition parameters can be empty, as well as calling parameters */
header
    : type TK_IDENTIFICADOR '(' def_params_rep ')'
    | type TK_IDENTIFICADOR '(' ')'
    ;

def_params_rep: def_params
    | def_params_rep ',' def_params
    ;

def_params
    : type TK_IDENTIFICADOR
    ;

block
    : '{' '}'
    | '{' command_rep '}'
    ;

    /* ---------- COMMANDS ---------- */

    /* commands are chained through ';' */
command_rep
    : command_rep command ';'
    | command ';'
    ;

command
    : atrib
    | var_local
    | control_flow
    | io
    | return
    | call
    | block
    ;

    /* we use "<=" in attributions, for some reason */
atrib
    : TK_IDENTIFICADOR TK_OC_LE expr
    | TK_IDENTIFICADOR index TK_OC_LE expr
    ;

var_local
    : type id_var_local_rep
    ;

    /* again, we can have multiple variables being declared at once */
id_var_local_rep: id_var_local
    | id_var_local_rep ',' id_var_local
    ;

    /* and they can be initialized (using "<=") */
id_var_local: TK_IDENTIFICADOR
    | TK_IDENTIFICADOR TK_OC_LE TK_IDENTIFICADOR
    | TK_IDENTIFICADOR TK_OC_LE literal
    ;

control_flow
    : if
    | for
    | while
    ;

if
    : TK_PR_IF '(' expr ')' TK_PR_THEN block
    | TK_PR_IF '(' expr ')' TK_PR_THEN block TK_PR_ELSE block
    ;

for
    : TK_PR_FOR '(' atrib ':' expr ':' atrib ')' block
    ;

while
    : TK_PR_WHILE '(' expr ')' block
    ;

io
    : TK_PR_INPUT TK_IDENTIFICADOR
    | TK_PR_OUTPUT TK_IDENTIFICADOR
    | TK_PR_OUTPUT literal
    ;

return
    : TK_PR_RETURN expr
    ;

call
    : TK_IDENTIFICADOR '(' param_rep ')'
    | TK_IDENTIFICADOR '(' ')'
    ;

param_rep
    : expr
    | param_rep ',' expr
    ;

    /* ---------- EXPRESSIONS ---------- */

    /* the expression rules are implemented following precedence orders */
expr
    : op_log
    ;

op_log
    : op_eq
    | op_eq tk_op_log op_log
    ;

op_eq
    : op_cmp
    | op_cmp tk_op_eq op_eq
    ;

op_cmp
    : op_add
    | op_add tk_op_cmp op_cmp
    ;

op_add
    : op_mul
    | op_mul tk_op_add op_add
    ;

op_mul
    : op_un
    | op_un tk_op_mul op_mul
    ;

op_un
    : tk_op_un op_un
    | op_elem
    ;

op_elem
    : TK_IDENTIFICADOR
    | TK_IDENTIFICADOR index
    | TK_LIT_INT
    | TK_LIT_FLOAT
    | call
    | boolean
    | '(' expr ')'
    ;

    /* tokens of each expression rule */
tk_op_eq
    : TK_OC_EQ
    | TK_OC_NE
    ;

tk_op_log
    : TK_OC_AND
    | TK_OC_OR
    ;

tk_op_cmp
    : TK_OC_LE
    | TK_OC_GE
    ;

tk_op_add
    : '+'
    | '-'
    ;

tk_op_mul
    : '*'
    | '/'
    | '%'
    ;

tk_op_un
    : '-'
    | '!'
    ;

    /* ---------- LITERALS ----------  */

literal
    : decimal
    | boolean
    | TK_LIT_CHAR
    ;

decimal
    : integer
    | float
    ;

integer
    : TK_LIT_INT
    ;

float
    : TK_LIT_FLOAT
    ;

boolean
    : TK_LIT_TRUE
    | TK_LIT_FALSE
    ;

    /* ---------- MISC ----------  */

index
    : '^' expr
    | '^' expr index
    ;

type
    : TK_PR_INT
    | TK_PR_FLOAT
    | TK_PR_BOOL
    | TK_PR_CHAR
    ;

%%