/** @file parser/scanner.l -*- bison -*-
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

%option nounput
%option nomain
%option noyywrap
%option warn
%option debug

%{
#include <cstdlib>

#include <string>
#include <fmt/core.h>

#include "driver.hh"
#include "parser.hh"

/* update the location of the tokens as they are recognized */
#define YY_USER_ACTION loc.columns(yyleng);
%}

/* helpful character classes */
WHITE [ \t\r]
ALPHA [[:alpha:]]

/* types */
TYPE_INT "int"
TYPE_FLOAT "float"
TYPE_BOOL "bool"
TYPE_CHAR "char"
/* reserved keywords */
RK_IF "if"
RK_THEN "then"
RK_ELSE "else"
RK_WHILE "while"
RK_INPUT "input"
RK_OUTPUT "output"
RK_RETURN "return"
/* single character operations */
OP_PLUS "+"
OP_MINUS "-"
OP_STAR "*"
OP_SLASH "/"
OP_PERCENT "%"
OP_BANG "!"
OP_CARET "^"
OP_EQUAL "="
OP_LT "<"
OP_GT ">"
/* special punctuation */
TK_COMMA ","
TK_SEMICOLON ";"
TK_COLON ":"
TK_LPAREN "("
TK_RPAREN ")"
TK_LCURLY "{"
TK_RCURLY "}"
/* composite operators */
OP_LOG_LE "<="
OP_LOG_GE ">="
OP_LOG_EQ "=="
OP_LOG_NE "!="
OP_LOG_AND "&&"
OP_LOG_OR "||"
/* decimals */
NUMBER [[:digit:]]
SCI_NOT ([eE][+-]?{NUMBER}+)
/* literals */
LIT_TRUE "true"
LIT_FALSE "false"
/* delimiters (used to quit word mode) */
DELIM [[:punct:][:blank:]]

/* states */
%x COMMENT
%x WORD

%%

%{
	// A handy shortcut to the location held by the driver.
	yy::location& loc = driver.location;
	// Code run each time yylex is called.
	loc.step();
%}

	/* ----------  comments section ---------- */
	/* block comment*/
"/*"									 { BEGIN(COMMENT); }
	/* comment state */
<COMMENT>{

"*"+"/"									 { BEGIN(INITIAL); }
[^*[:blank:]\n]*
"*"+[^*/[:blank:]\n]*
{WHITE}+								 { loc.step(); }
\n+										 { loc.lines(yyleng); loc.step(); }

}

	/* line comments */
"//".*


	/* ----------  words section ---------- */

{ALPHA}+								 { BEGIN(WORD); yyless(0); }

	/* word state */
<WORD>{

	/* types */
{TYPE_INT}								 { return yy::parser::make_INT(loc); }
{TYPE_FLOAT}							 { return yy::parser::make_FLOAT(loc); }
{TYPE_BOOL}								 { return yy::parser::make_BOOL(loc); }
{TYPE_CHAR}								 { return yy::parser::make_CHAR(loc); }

	/* reserved keywords */
{RK_IF}									 { return yy::parser::make_IF(loc); }
{RK_THEN}								 { return yy::parser::make_THEN(loc); }
{RK_ELSE}								 { return yy::parser::make_ELSE(loc); }
{RK_WHILE}								 { return yy::parser::make_WHILE(loc); }
{RK_INPUT}								 { return yy::parser::make_INPUT(loc); }
{RK_OUTPUT}								 { return yy::parser::make_OUTPUT(loc); }
{RK_RETURN}								 { return yy::parser::make_RETURN(loc); }

	/* boolean literals */
{LIT_TRUE}                               { return yy::parser::make_TRUE(true, loc); }
{LIT_FALSE}                              { return yy::parser::make_FALSE(false, loc); }

	/* identifiers */
{ALPHA}+								 { return yy::parser::make_IDENTIFIER(yytext, loc); }

{DELIM}+						         { BEGIN(INITIAL); yyless(0); }

}


	/* ---------- special characters section ---------- */

	/* simple operators */
{OP_PLUS}								 { return yy::parser::make_PLUS(loc); }
{OP_MINUS}								 { return yy::parser::make_MINUS(loc); }
{OP_STAR}								 { return yy::parser::make_STAR(loc); }
{OP_SLASH}								 { return yy::parser::make_SLASH(loc); }
{OP_PERCENT}							 { return yy::parser::make_PERCENT(loc); }
{OP_BANG}								 { return yy::parser::make_BANG(loc); }
{OP_CARET}								 { return yy::parser::make_CARET(loc); }
{OP_EQUAL}								 { return yy::parser::make_EQUAL(loc); }
{OP_LT}									 { return yy::parser::make_LESS_THAN(loc); }
{OP_GT}									 { return yy::parser::make_GREATER_THAN(loc); }

	/* composite operators */
{OP_LOG_LE}                              { return yy::parser::make_OC_LESS_EQUAL(loc); }
{OP_LOG_GE}                              { return yy::parser::make_OC_GREATER_EQUAL(loc); }
{OP_LOG_EQ}                              { return yy::parser::make_OC_EQUAL(loc); }
{OP_LOG_NE}                              { return yy::parser::make_OC_NOT_EQUAL(loc); }
{OP_LOG_AND}                             { return yy::parser::make_OC_AND(loc); }
{OP_LOG_OR}                              { return yy::parser::make_OC_OR(loc); }

	/* simple special tokens */

{TK_COMMA}								 { return yy::parser::make_COMMA(loc); }
{TK_SEMICOLON}							 { return yy::parser::make_SEMICOLON(loc); }
{TK_COLON}								 { return yy::parser::make_COLON(loc); }
{TK_LPAREN}								 { return yy::parser::make_LPAREN(loc); }
{TK_RPAREN}								 { return yy::parser::make_RPAREN(loc); }
{TK_LCURLY}								 { return yy::parser::make_LCURLY(loc); }
{TK_RCURLY}								 { return yy::parser::make_RCURLY(loc); }


	/* ---------- literals section ---------- */

	/* character literals */
"\'"[^\n]?"\'"							 { return yy::parser::make_CHARACTER(yytext[1], loc); }

	/* float */
[+-]?{NUMBER}+"."{NUMBER}+{SCI_NOT}?	 { return yy::parser::make_FLOATING_POINT(std::atof(yytext), loc); }

	/* integer */
[+-]{NUMBER}+							 { return yy::parser::make_INTEGER(std::atoi(yytext), loc); }

	/* ---------- misc section ---------- */
	/* whitespace or newlines between tokens */
{WHITE}+								 { loc.step(); }

\n+										 { loc.lines(yyleng); loc.step(); }

<<EOF>>									 { return yy::parser::make_YYEOF(loc); }

	/* error catch-all */
<*>.									 { return yy::parser::make_ERROR(loc); }

%%

namespace hcpsilva {

void driver::begin_scan()
{
	yyin = this->file_name.empty()
		? stdin
		: std::fopen(file_name.c_str(), "r");

	if (!yyin) {
		fmt::print(stderr, "ERROR: failed to open file {}: {}\n", this->file_name, strerror(errno));
		exit(1);
	}
}

void driver::end_scan()
{
	fclose(yyin);
}

}
