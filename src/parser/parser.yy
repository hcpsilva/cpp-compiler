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
	#include <string>
	#include <optional>

	#include "fmt/core.h"
	#include "ast.hh"
	#include "lexic_values.hh"

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
%token <hcpsilva::types>
	INT      "int type keyword"
	FLOAT    "float type keyword"
	BOOL     "bool type keyword"
	CHAR     "char type keyword"
;

/* reserved keywords */
%token <hcpsilva::keywords>
	IF      "if keyword"
	WHILE   "while keyword"
	INPUT   "input keyword"
	OUTPUT  "output keyword"
	RETURN  "return keyword"
;

/* reserved keywords that aren't nodes */
%token
	THEN    "then keyword"
	ELSE    "else keyword"
;

/* operators */
%token <hcpsilva::operations>
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

%type <hcpsilva::lexic_value> literal

%type <std::string> header

%type <hcpsilva::types> type

%type <hcpsilva::operations>
	tk_op_add
	tk_op_cmp
	tk_op_eq
	tk_op_log
	tk_op_mul
	tk_op_un
;

/* rules and their types */
%type <hcpsilva::ast_node>
	function
	expr
	op_log op_eq op_cmp op_add op_mul op_un op_elem
	call param_rep
	index index_rep
	id
	atrib
	control_flow
	if
	while
	io
	return
;

%type <std::optional<hcpsilva::ast_node>>
	source
	id_var_local
	var_local
	id_var_local_rep
	block
	command command_rep
;

%printer { fmt::print("{}\n", *$$); } <std::optional<hcpsilva::ast_node>>
%printer { fmt::print("{}\n", $$); } <*>

%%

start
	: source { driver.ast = std::move($1); }
	;

	/* ---------- GLOBAL SCOPE ---------- */

	/* the source code can be empty, and variables require ';' */
source
	: %empty { $$ = std::nullopt; }
	| source global_var SEMICOLON { $$ = std::move($1); }
	| source function {
		if ($1) {
			$1->append_next(std::move($2));
			$$ = std::move(*$1);
		} else {
			$$ = std::move($2);
		}
	}
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
	: header block {
		$$ = ast_node(std::move($1));
		if ($2) $$.add_child(std::move(*$2));
	}
	;

	/* definition parameters can be empty, as well as calling parameters */
header
	: type IDENTIFIER LPAREN decl_params_rep RPAREN { $$ = std::move($2); }
	| type IDENTIFIER LPAREN RPAREN { $$ = std::move($2); }
	;

decl_params_rep
	: decl_param
	| decl_params_rep COMMA decl_param
	;

decl_param
	: type IDENTIFIER
	;

block
	: LCURLY command_rep RCURLY { $$ = std::move($2); }
	| LCURLY RCURLY { $$ = std::nullopt; }
	;

	/* ---------- COMMANDS ---------- */

	/* commands are chained through ';' */
command_rep
	: command_rep command SEMICOLON {
		if ($1 && $2) {
			$1->append_next(std::move(*$2));
			$$ = std::move(*$1);
		} else if ($2) {
			$$ = std::move(*$2);
		}
	}
	| command SEMICOLON { $$ = std::move($1); }
	;

command
	: atrib { $$ = std::move($1); }
	| var_local { $$ = std::move($1); }
	| control_flow { $$ = std::move($1); }
	| io { $$ = std::move($1); }
	| return { $$ = std::move($1); }
	| call { $$ = std::move($1); }
	| block { $$ = std::move($1); }
	;

	/* we use "=" in attributions, as expected */
atrib
	: id EQUAL expr { $$ = ast_node($2, std::move($1), std::move($3)); }
	;

var_local
	: type id_var_local_rep { $$ = std::move($2); }
	;

	/* again, we can have multiple variables being declared at once */
id_var_local_rep
	: id_var_local { $$ = std::move($1); }
	| id_var_local_rep COMMA id_var_local {
		if ($1 && $3) {
			$1->append_next(std::move(*$3));
			$$ = std::move(*$1);
		} else if ($3) {
			$$ = std::move(*$3);
		}
	}
	;

	/* and they can be initialized (using "<=", for some reason) */
id_var_local
	: IDENTIFIER { $$ = std::nullopt; }
	| IDENTIFIER OC_LESS_EQUAL literal { $$ = ast_node(operations::INITIALIZATION, ast_node(std::move($1)), ast_node(std::move($3))); }
	;

control_flow
	: if
	| while
	;

if
	: IF LPAREN expr RPAREN THEN block {
		$$ = ast_node($1, std::move($3));
		if ($6) $$.add_child(std::move(*$6));
	}
	| IF LPAREN expr RPAREN THEN block ELSE block {
		$$ = ast_node($1, std::move($3));
		if ($6) $$.add_child(std::move(*$6));
		if ($8) $$.add_child(std::move(*$8));
	}
	;

while
	: WHILE LPAREN expr RPAREN block {
		$$ = ast_node($1, std::move($3));
		if ($5) $$.add_child(std::move(*$5));
	}
	;

io
	: INPUT id { $$ = ast_node($1, std::move($2)); }
	| OUTPUT id { $$ = ast_node($1, std::move($2)); }
	| OUTPUT literal { $$ = ast_node($1, ast_node(std::move($2))); }
	;

return
	: RETURN expr { $$ = ast_node($1, std::move($2)); }
	;

call
	: IDENTIFIER LPAREN param_rep RPAREN { $$ = ast_node(std::move($1.insert(0, "call ")), std::move($3)); }
	| IDENTIFIER LPAREN RPAREN { $$ = ast_node(std::move($1.insert(0, "call "))); }
	;

param_rep
	: expr { $$ = std::move($1); }
	| param_rep COMMA expr {
		$1.append_next(std::move($3));
		$$ = std::move($1);
	}
	;

	/* ---------- EXPRESSIONS ---------- */

	/* the expression rules are implemented following precedence orders */
expr
	: op_log { $$ = std::move($1); }
	;

op_log
	: op_eq { $$ = std::move($1); }
	| op_eq tk_op_log op_log { $$ = ast_node($2, std::move($1), std::move($3)); }
	;

op_eq
	: op_cmp { $$ = std::move($1); }
	| op_cmp tk_op_eq op_eq { $$ = ast_node($2, std::move($1), std::move($3)); }
	;

op_cmp
	: op_add { $$ = std::move($1); }
	| op_add tk_op_cmp op_cmp { $$ = ast_node($2, std::move($1), std::move($3)); }
	;

op_add
	: op_mul { $$ = std::move($1); }
	| op_mul tk_op_add op_add { $$ = ast_node($2, std::move($1), std::move($3)); }
	;

op_mul
	: op_un { $$ = std::move($1); }
	| op_un tk_op_mul op_mul { $$ = ast_node($2, std::move($1), std::move($3)); }
	;

op_un
	: op_elem { $$ = std::move($1); }
	| tk_op_un op_un { $$ = ast_node($1, std::move($2)); }
	;

op_elem
	: id { $$ = std::move($1); }
	| call { $$ = std::move($1); }
	| literal { $$ = ast_node($1); }
	| LPAREN expr RPAREN { $$ = std::move($2); }
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
	: INTEGER { $$ = $1; }
	| FLOATING_POINT { $$ = $1; }
	| TRUE { $$ = $1; }
	| FALSE { $$ = $1; }
	| CHARACTER { $$ = $1; }
	;

	/* ---------- MISC ----------  */

id
	: IDENTIFIER { $$ = ast_node(std::move($1)); }
	| IDENTIFIER index { $$ = ast_node(operations::INDEX, ast_node(std::move($1)), std::move($2)); }
	;

index_def
	: LSQUARE index_def_rep RSQUARE
	;

index_def_rep
	: INTEGER
	| index_def_rep CARET INTEGER
	;

index
	: LSQUARE index_rep RSQUARE { $$ = std::move($2); }
	;

index_rep
	: expr { $$ = ast_node(operations::INDEX_SEP, std::move($1)); }
	| index_rep CARET expr { $$ = ast_node($2, std::move($1), std::move($3)); }
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
