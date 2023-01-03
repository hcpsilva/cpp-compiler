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
%option noyylineno
%option c++
%option yyclass="scanner"
%option warn
%option debug
%option batch

%{
#include <cstdlib>
#include <cstring>

#include <string>
#include <fmt/core.h>

#include "parser.hh"
#include "location.hh"
#include "scanner.hh"
#include "driver.hh"

static bool read_a_line = true;

#undef YY_DECL
#define YY_DECL yy::parser::symbol_type yy::scanner::lex(hcpsilva::driver& driver)

/* update the location of the tokens as they are recognized */
/* VERY evil code */
#define YY_USER_ACTION loc.columns(yyleng); this->on_new_token(yytext, yyleng, yy_hold_char);
%}

/* helpful character classes */
WHITE [ \t\r]
ALPHA [[:alpha:]]
ALNUM [[:alnum:]]

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
TK_LPAREN "("
TK_RPAREN ")"
TK_LCURLY "{"
TK_RCURLY "}"
TK_LSQUARE "["
TK_RSQUARE "]"
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

/* states */
%x COMMENT

%%

%{
	// a handy shortcut to the location held by the driver
	auto& loc = driver.location;
	// code run the first time yylex is called
	loc.step();
%}

	/* ----------  comments section ---------- */
	/* block comment*/
"/*"                             { BEGIN(COMMENT); }
	/* comment state */
<COMMENT>{

"*"+"/"                          { BEGIN(INITIAL); }
[^*[:blank:]\n]*
"*"+[^*/[:blank:]\n]*
{WHITE}+                         { loc.step(); }
\n+                              { loc.lines(yyleng); loc.step(); }

}

	/* line comments */
"//".*


	/* ----------  words section ---------- */

	/* types */
{TYPE_INT}                       { return yy::parser::make_INT(loc); }
{TYPE_FLOAT}                     { return yy::parser::make_FLOAT(loc); }
{TYPE_BOOL}                      { return yy::parser::make_BOOL(loc); }
{TYPE_CHAR}                      { return yy::parser::make_CHAR(loc); }

	/* reserved keywords */
{RK_IF}                          { return yy::parser::make_IF(loc); }
{RK_THEN}                        { return yy::parser::make_THEN(loc); }
{RK_ELSE}                        { return yy::parser::make_ELSE(loc); }
{RK_WHILE}                       { return yy::parser::make_WHILE(loc); }
{RK_INPUT}                       { return yy::parser::make_INPUT(loc); }
{RK_OUTPUT}                      { return yy::parser::make_OUTPUT(loc); }
{RK_RETURN}                      { return yy::parser::make_RETURN(loc); }

	/* boolean literals */
{LIT_TRUE}                       { return yy::parser::make_TRUE(true, loc); }
{LIT_FALSE}                      { return yy::parser::make_FALSE(false, loc); }

	/* identifiers */
{ALPHA}+                         { return yy::parser::make_IDENTIFIER(yytext, loc); }


	/* ---------- special characters section ---------- */

	/* simple operators */
{OP_PLUS}                        { return yy::parser::make_PLUS(loc); }
{OP_MINUS}                       { return yy::parser::make_MINUS(loc); }
{OP_STAR}                        { return yy::parser::make_STAR(loc); }
{OP_SLASH}                       { return yy::parser::make_SLASH(loc); }
{OP_PERCENT}                     { return yy::parser::make_PERCENT(loc); }
{OP_BANG}                        { return yy::parser::make_BANG(loc); }
{OP_CARET}                       { return yy::parser::make_CARET(loc); }
{OP_EQUAL}                       { return yy::parser::make_EQUAL(loc); }
{OP_LT}                          { return yy::parser::make_LESS_THAN(loc); }
{OP_GT}                          { return yy::parser::make_GREATER_THAN(loc); }

	/* composite operators */
{OP_LOG_LE}                      { return yy::parser::make_OC_LESS_EQUAL(loc); }
{OP_LOG_GE}                      { return yy::parser::make_OC_GREATER_EQUAL(loc); }
{OP_LOG_EQ}                      { return yy::parser::make_OC_EQUAL(loc); }
{OP_LOG_NE}                      { return yy::parser::make_OC_NOT_EQUAL(loc); }
{OP_LOG_AND}                     { return yy::parser::make_OC_AND(loc); }
{OP_LOG_OR}                      { return yy::parser::make_OC_OR(loc); }

	/* simple special tokens */
{TK_COMMA}                       { return yy::parser::make_COMMA(loc); }
{TK_SEMICOLON}                   { return yy::parser::make_SEMICOLON(loc); }
{TK_LPAREN}                      { return yy::parser::make_LPAREN(loc); }
{TK_RPAREN}                      { return yy::parser::make_RPAREN(loc); }
{TK_LCURLY}                      { return yy::parser::make_LCURLY(loc); }
{TK_RCURLY}                      { return yy::parser::make_RCURLY(loc); }
{TK_LSQUARE}                     { return yy::parser::make_LSQUARE(loc); }
{TK_RSQUARE}                     { return yy::parser::make_RSQUARE(loc); }


	/* ---------- literals section ---------- */

	/* character literals */
"\'"[^\n]?"\'"                   { return yy::parser::make_CHARACTER(yyleng == 3 ? yytext[1] : '', loc); }

	/* float */
{NUMBER}+"."{NUMBER}+{SCI_NOT}?  { return yy::parser::make_FLOATING_POINT(std::atof(yytext), loc); }

	/* integer */
{NUMBER}+                        { return yy::parser::make_INTEGER(std::atoi(yytext), loc); }


	/* ---------- misc section ---------- */

	/* whitespace or newlines between tokens */
{WHITE}+                         { loc.step(); }

\n+                              { loc.lines(yyleng); loc.step(); read_a_line = true; }

<<EOF>>                          { return yy::parser::make_YYEOF(loc); }

{ALNUM}+                         { throw yy::parser::syntax_error(loc, fmt::format("syntax error, bad alphanumeric sequence \"{}\"", yytext)); }

	/* error catch-all */
<*>.                             { throw yy::parser::syntax_error(loc, fmt::format("syntax error, unknown character '{}'", yytext)); }

%%

auto yy::scanner::get_current_line(void) -> std::string const&
{
	return this->current_line;
}

auto yy::scanner::get_last_token(void) -> std::string const&
{
	return this->last_token;
}

auto yy::scanner::on_new_token(char* yytext, int yyleng, char yy_hold_char) -> void
{
	this->last_token = std::string(yytext);

	if (read_a_line) {
		yytext[yyleng] = yy_hold_char;

		auto	newline_index		= std::strchr(yytext, '\n') - yytext;
		auto	newline_char_or_eos = yytext[newline_index];

		yytext[newline_index] = '\0';
		current_line          = std::string(yytext);
		yytext[newline_index] = newline_char_or_eos;

		yytext[yyleng] = '\0';

		read_a_line = false;
	}
}
