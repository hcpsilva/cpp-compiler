/** @file parser/parser.yy -*- bison -*-
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

%code requires {
	#include "fmt/core.h"
	#include <string>

	namespace hcpsilva {
		class driver;
	}
}

%code top {
	#include "driver.hh"
	#include "scanner.hh"
	#include "parser.hh"
	#include "location.hh"

	using namespace hcpsilva;

	static auto yylex(driver& driver) -> yy::parser::symbol_type {
		return driver.yylex();
	}
}

/* the following options enable us more information when printing the
 * error */
%define parse.error detailed
%define parse.trace
%define parse.lac full
%define parse.assert
%define api.token.constructor
%define api.token.prefix {TOK_}
%define api.token.raw
%define api.value.type variant
%define api.parser.class {parser}

%param { hcpsilva::driver& driver }

%require "3.8.1"
%skeleton "lalr1.cc"
%language "c++"

%locations

/* types */
%token
	INT      "int type keyword"
	FLOAT    "float type keyword"
	BOOL     "bool type keyword"
	CHAR     "char type keyword"
;

/* reserved keywords */
%token
	IF      "if keyword"
	THEN    "then keyword"
	ELSE    "else keyword"
	WHILE   "while keyword"
	INPUT   "input keyword"
	OUTPUT  "output keyword"
	RETURN  "return keyword"
;

/* operators */
%token
	PLUS                "+"
	MINUS               "-"
	STAR                "*"
	SLASH               "/"
	PERCENT             "%"
	BANG                "!"
	CARET               "^"
	LESS_THAN           "<"
	GREATER_THAN        ">"
	EQUAL               "="
	OC_LESS_EQUAL       "<="
	OC_GREATER_EQUAL    ">="
	OC_EQUAL            "=="
	OC_NOT_EQUAL        "!="
	OC_AND              "&&"
	OC_OR               "||"
;

/* special punctuation */
%token
	LPAREN      "("
	RPAREN      ")"
	LCURLY      "{"
	RCURLY      "}"
	LSQUARE     "["
	RSQUARE     "]"
	SEMICOLON   ";"
	COMMA       ","
;

/* error! */
%token ERROR

/* literals */
%token <int> INTEGER            "integer literal"
%token <double> FLOATING_POINT  "floating point literal"
%token <bool> FALSE             "false literal"
%token <bool> TRUE              "true literal"
%token <char> CHARACTER         "character literal"
%token <std::string> IDENTIFIER "identifier"

%printer { fmt::print("{}", $$); } <*>;

%%

	/* ---------- GLOBAL SCOPE ---------- */

	/* the source code can be empty, and variables require ';' */
source
	: %empty
	| source global_var SEMICOLON
	| source function
	;

global_var
	: type id_global_var_rep
	;

	/* we can have multiple variables being initialized at once */
id_global_var_rep
	: id_global_var
	| id_global_var_rep COMMA id_global_var
	;

id_global_var
	: IDENTIFIER
	| IDENTIFIER index_def
	;

function
	: header block
	;

	/* definition parameters can be empty, as well as calling parameters */
header
	: type IDENTIFIER LPAREN def_params_rep RPAREN
	| type IDENTIFIER LPAREN RPAREN
	;

def_params_rep
	: def_params
	| def_params_rep COMMA def_params
	;

def_params
	: type IDENTIFIER
	;

block
	: LCURLY command_rep RCURLY
	| LCURLY RCURLY
	;

	/* ---------- COMMANDS ---------- */

	/* commands are chained through ';' */
command_rep
	: command_rep command SEMICOLON
	| command SEMICOLON
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

	/* we use "=" in attributions, as expected */
atrib
	: IDENTIFIER EQUAL expr
	| IDENTIFIER index EQUAL expr
	;

var_local
	: type id_var_local_rep
	;

	/* again, we can have multiple variables being declared at once */
id_var_local_rep
	: id_var_local
	| id_var_local_rep COMMA id_var_local
	;

	/* and they can be initialized (using "<=", for some reason) */
id_var_local
	: IDENTIFIER
	| IDENTIFIER OC_LESS_EQUAL literal
	;

control_flow
	: if
	| while
	;

if
	: IF LPAREN expr RPAREN THEN block
	| IF LPAREN expr RPAREN THEN block ELSE block
	;

while
	: WHILE LPAREN expr RPAREN block
	;

io
	: INPUT IDENTIFIER
	| OUTPUT IDENTIFIER
	| OUTPUT literal
	;

return
	: RETURN expr
	;

call
	: IDENTIFIER LPAREN param_rep RPAREN
	| IDENTIFIER LPAREN RPAREN
	;

param_rep
	: expr
	| param_rep COMMA expr
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
	: op_elem
	| tk_op_un op_un
	;

op_elem
	: IDENTIFIER
	| IDENTIFIER index
	| call
	| literal
	| LPAREN expr RPAREN
	;

	/* tokens of each expression rule */
tk_op_log
	: OC_AND
	| OC_OR
	;

tk_op_eq
	: OC_EQUAL
	| OC_NOT_EQUAL
	;

tk_op_cmp
	: OC_LESS_EQUAL
	| OC_GREATER_EQUAL
	| LESS_THAN
	| GREATER_THAN
	;

tk_op_add
	: PLUS
	| MINUS
	;

tk_op_mul
	: STAR
	| SLASH
	| PERCENT
	;

tk_op_un
	: MINUS
	| BANG
	;

	/* ---------- LITERALS ----------  */

literal
	: INTEGER
	| FLOATING_POINT
	| TRUE
	| FALSE
	| CHARACTER
	;

	/* ---------- MISC ----------  */

index_def
	: LSQUARE index_def_rep RSQUARE
	;

index_def_rep
	: INTEGER
	| index_def_rep CARET INTEGER
	;

index
	: LSQUARE index_rep RSQUARE
	;

index_rep
	: expr
	| index_rep CARET expr
	;

type
	: INT
	| FLOAT
	| BOOL
	| CHAR
	;

%%

auto yy::parser::error(yy::location const& location, std::string const& message) -> void
{
	auto const token = driver.scanner.get_last_token();
	auto const complete_line = driver.scanner.get_current_line();
	auto const first_col = location.begin.column;
	auto const last_col = location.end.column;
	auto underline_string = (char*) calloc(last_col + 1, sizeof (char));

	auto aux_ptr = underline_string;

	std::memset(aux_ptr, ' ', first_col - 1);
	aux_ptr += first_col - 1;
	*aux_ptr = '^';
	std::memset(aux_ptr + 1, '~', last_col - first_col - 1);

	fmt::print(stderr, "\n--\n");

	fmt::print(stderr, "line {}: {} (read token = \"{}\")\n", location.begin.line, message, token);

	fmt::print(stderr, "{}\t| {}\n", location.begin.line, complete_line);
	fmt::print(stderr, "\t| {}\n", underline_string);

	free(underline_string);
}
