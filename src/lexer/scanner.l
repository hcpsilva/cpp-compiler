/** @file lexer/scanner.l -*- bison -*-
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

%option noyywrap yylineno

/* helpful character classes */
WHITE [[:blank:],]
GRAPH [[:graph:]]
ALNUM [[:alnum:]_.]
ALPHA [[:alpha:]_.]

/* special punctuation characters */
SPECIAL [[:punct:]]{-}[\'\"\`_~\\,.]

/* delimiters, which are either whitespace or special punctuation
 * characters */
DELIM [[:punct:][:space:]]{-}[_\\~.]

/* decimals */
NUMBER [[:digit:]]

%{
#include "scanner.hpp"

/* to track the initial column of matched tokens */
int yycolumn = 1;
/* to save the line of the current matches*/
char* yylinebuf = NULL;
size_t yylinebuf_len = 0;

/* helpful flex feature that helps us to track the location of the tokens */
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno; \
	yylloc.first_column = yycolumn; yylloc.last_column = yycolumn + yyleng - 1; \
	yycolumn += yyleng;
%}

/* states */
%x COMMENT
%x WORD
%x STRING
%x QUOTE
%x DECIMAL

/* reserved keywords */
RK_INT "inte"
RK_FLOAT "real"
RK_CHAR "chara"
RK_IF "se"
RK_THEN "entaum"
RK_ELSE "senaum"
RK_WHILE "enquanto"
RK_INPUT "entrada"
RK_OUTPUT "escreva"
RK_RETURN "retorne"

/* composite operators */
OP_LE "<="
OP_GE ">="
OP_EQ "=="
OP_NE "!="

%%

	/* ----------  comments section ----------  */

	/* block comment*/
"///"                                  { BEGIN(COMMENT); V_LOG_LEXER("COMMENT STATE");}
	/* comment state */
<COMMENT>                              {

[^\\\n]*"\\\\\\"                       { BEGIN(INITIAL); V_LOG_LEXER("INITIAL STATE");}
[^\\\n]+
"\\"{1,2}[^\\\n]*
\n                                     { yycolumn = 1; }
<<EOF>>                                { return TOKEN_ERROR; }

}

	/* line comments */
"//".*                                 { yycolumn = 1; }

	/* ---------- word section ---------- */

{ALPHA}/{ALNUM}*                       { BEGIN(WORD); V_LOG_LEXER("WORD STATE"); yyless(0); }

	/* word state */
<WORD>                                 {

	/* reserved keywords */
{RK_INT}                               { V_LOG_LEXER("KW_INTE"); return KW_INTE; }
{RK_FLOAT}                             { V_LOG_LEXER("KW_REAL"); return KW_REAL; }
{RK_CHAR}                              { V_LOG_LEXER("KW_CARA"); return KW_CARA; }
{RK_IF}                                { V_LOG_LEXER("KW_SE"); return KW_SE; }
{RK_THEN}                              { V_LOG_LEXER("KW_ENTAUM"); return KW_ENTAUM; }
{RK_ELSE}                              { V_LOG_LEXER("KW_SENAUM"); return KW_SENAUM; }
{RK_WHILE}                             { V_LOG_LEXER("KW_ENQUANTO"); return KW_ENQUANTO; }
{RK_INPUT}                             { V_LOG_LEXER("KW_ENTRADA"); return KW_ENTRADA; }
{RK_OUTPUT}                            { V_LOG_LEXER("KW_ESCREVA"); return KW_ESCREVA; }
{RK_RETURN}                            { V_LOG_LEXER("KW_RETORNE"); return KW_RETORNE; }

	/* identifiers */
{ALPHA}{ALNUM}*                        { V_LOG_LEXER("TK_IDENTIFIER"); return TK_IDENTIFIER; }

	/* end word */
{DELIM}                                { BEGIN(INITIAL); V_LOG_LEXER("INITIAL STATE"); yyless(0); }

}

	/* ---------- special characters section ----------  */

	/* composite operators */
{OP_LE}                                { V_LOG_LEXER("OP_LE"); return OPERATOR_LE; }
{OP_GE}                                { V_LOG_LEXER("OP_GE"); return OPERATOR_GE; }
{OP_EQ}                                { V_LOG_LEXER("OP_EQ"); return OPERATOR_EQ; }
{OP_NE}                                { V_LOG_LEXER("OP_NE"); return OPERATOR_DIF; }

	/* special characters */
{SPECIAL}/{WHITE}?                     {
	V_LOG_LEXER("SPECIAL");
	return (int)*yytext;
}

	/* ---------- literals section ----------  */

	/* string literals */
"\""                                   { BEGIN(STRING); yymore(); V_LOG_LEXER("STRING STATE"); }
<STRING>("\\".|[^\"\n\\])*"\""         {
	BEGIN(INITIAL);
	V_LOG_LEXER("QUOTED STRING");
	return LIT_STRING;
}

<STRING>{GRAPH}                        {
	yyless(1);
	BEGIN(INITIAL);
	V_LOG_LEXER("MALFORMED STRING");
	return TOKEN_ERROR;
}

	/* character literals */
"\'"                                   { BEGIN(QUOTE); yymore(); V_LOG_LEXER("CHAR STATE"); }
<QUOTE>("\\".|[^\'\n\\])"\'"           {
	BEGIN(INITIAL);
	V_LOG_LEXER("QUOTED CHARACTER");
	return LIT_CHAR;
}

<QUOTE>{GRAPH}                         {
	yyless(1);
	BEGIN(INITAL);
	V_LOG_LEXER("MALFORMED QUOTE");
	return TOKEN_ERROR;
}

	/* number literals */
{NUMBER}/{ALNUM}*                      {
	BEGIN(DECIMAL);
	V_LOG_LEXER("DECIMAL STATE");
	yycolumn--;
	yyless(0);
}

	/* decimal state */
<DECIMAL>                              {

	/* float */
{NUMBER}+"."{NUMBER}+                  {
	BEGIN(INITIAL);
	V_LOG_LEXER("FLOATING POINT");
	return LIT_FLOAT;
}

	/* malformed float */
{NUMBER}+"."{ALNUM}+                   {
	yyless(yyleng - 1);
	BEGIN(INITIAL);
	V_LOG_LEXER("MALFORMED FLOATING POINT");
	return TOKEN_ERROR;
}

	/* integer */
{NUMBER}+                              {
	BEGIN(INITIAL);
	V_LOG_LEXER("INTEGER");
	return LIT_INTEIRO;

}
	/* malformed decimal */
{ALNUM}+                               {
	yyless(yyleng - 1);
	BEGIN(INITIAL);
	V_LOG_LEXER("MALFORMED DECIMAL");
	return TOKEN_ERROR;
}

}

	/* ---------- misc section ---------- */

	/* whitespace or newlines between tokens */
({WHITE}|\n)+
	/* error catch-all */
<*>.                                   { V_LOG_LEXER("UNKNOWN"); return TOKEN_ERROR; }

%%
