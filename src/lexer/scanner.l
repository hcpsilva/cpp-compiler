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

%option nounput yylineno nomain noyywrap

%{
#include "scanner.hpp"
%}

/* helpful character classes */
WHITE [[:blank:]]
GRAPH [[:graph:]]
ALNUM [[:alnum:]]
ALPHA [[:alpha:]]

/* to handle escape sequences require the modification of the matched
 * string, which is not a good idea to do with yytext, as it points
 * directly to the input stream */
ESC_SEQ [abfnrtv\\\"\']
/* reserved keywords */
RK_INT "int"
RK_FLOAT "float"
RK_BOOL "bool"
RK_CHAR "char"
RK_IF "if"
RK_THEN "then"
RK_ELSE "else"
RK_WHILE "while"
RK_INPUT "input"
RK_OUTPUT "output"
RK_RETURN "return"
RK_FOR "for"
/* special punctuation or operator characters */
SPC_CHAR [,;:(){}+*/%^<>=!-]
/* delimiters, which are either whitespace or special punctuation
 * characters */
DELIM ({SPC_CHAR}|{WHITE}|\n)
/* composite operators */
OP_LE "<="
OP_GE ">="
OP_EQ "=="
OP_NE "!="
OP_AND "&&"
OP_OR "||"
/* decimals */
NUMBER [[:digit:]]
SCI_NOT [eE][+\-]?{NUMBER}+
/* boolean literals */
BOOL_T "true"
BOOL_F "false"
/* states */
%x COMMENT
%x WORD
%x QUOTE
%x DECIMAL

%%

	/* ----------  comments section ----------  */
	/* block comment*/
"/*"                                   { BEGIN(COMMENT); V_LOG_LEXER("COMMENT STATE"); }
	/* comment state */
<COMMENT>{

"*"+"/"                                { BEGIN(INITIAL); V_LOG_LEXER("INITIAL STATE"); }
[^*\n]*
"*"+[^*/\n]*
\n
<<EOF>>                                { return TK_ERRO; }

}

	/* line comments */
"//".*

	/* ----------  words section ----------  */

{ALPHA}+                               {
	BEGIN(WORD);
	V_LOG_LEXER("WORD STATE");
	yyless(0);
}


	/* word state */
<WORD>{

	/* reserved keywords */
{RK_INT}                               { V_LOG_LEXER("RK_INT"); BEGIN(INITIAL); return TK_PR_INT; }
{RK_FLOAT}                             { V_LOG_LEXER("RK_FLOAT"); BEGIN(INITIAL); return TK_PR_FLOAT; }
{RK_BOOL}                              { V_LOG_LEXER("RK_BOOL"); BEGIN(INITIAL); return TK_PR_BOOL; }
{RK_CHAR}                              { V_LOG_LEXER("RK_CHAR"); BEGIN(INITIAL); return TK_PR_CHAR; }
{RK_IF}                                { V_LOG_LEXER("RK_IF"); BEGIN(INITIAL); return TK_PR_IF; }
{RK_THEN}                              { V_LOG_LEXER("RK_THEN"); BEGIN(INITIAL); return TK_PR_THEN; }
{RK_ELSE}                              { V_LOG_LEXER("RK_ELSE"); BEGIN(INITIAL); return TK_PR_ELSE; }
{RK_WHILE}                             { V_LOG_LEXER("RK_WHILE"); BEGIN(INITIAL); return TK_PR_WHILE; }
{RK_INPUT}                             { V_LOG_LEXER("RK_INPUT"); BEGIN(INITIAL); return TK_PR_INPUT; }
{RK_OUTPUT}                            { V_LOG_LEXER("RK_OUTPUT"); BEGIN(INITIAL); return TK_PR_OUTPUT; }
{RK_RETURN}                            { V_LOG_LEXER("RK_RETURN"); BEGIN(INITIAL); return TK_PR_RETURN; }
{RK_FOR}                               { V_LOG_LEXER("RK_FOR"); BEGIN(INITIAL); return TK_PR_FOR; }

	/* boolean literals */
{BOOL_T}                               { V_LOG_LEXER("TRUE"); BEGIN(INITIAL); return TK_LIT_TRUE; }
{BOOL_F}                               { V_LOG_LEXER("FALSE"); BEGIN(INITIAL); return TK_LIT_FALSE; }

	/* identifiers */
{ALPHA}+                               { V_LOG_LEXER("IDENTIFIER"); BEGIN(INITIAL); return TK_IDENTIFICADOR; }

}


	/* ---------- special characters section ----------  */

	/* composite operators */
{OP_LE}                        { V_LOG_LEXER("OP_LE"); return TK_OC_LE; }
{OP_GE}                        { V_LOG_LEXER("OP_GE"); return TK_OC_GE; }
{OP_EQ}                        { V_LOG_LEXER("OP_EQ"); return TK_OC_EQ; }
{OP_NE}                        { V_LOG_LEXER("OP_NE"); return TK_OC_NE; }
{OP_AND}                       { V_LOG_LEXER("OP_AND"); return TK_OC_AND; }
{OP_OR}                        { V_LOG_LEXER("OP_OR"); return TK_OC_OR; }

	/* special characters */
{SPC_CHAR}/{WHITE}?            {
	V_LOG_LEXER("SPECIAL");
	return (int)*yytext;
}


	/* ---------- literals section ----------  */

	/* character literals */
"\'"                           { BEGIN(QUOTE); yymore(); V_LOG_LEXER("CHAR STATE"); }
<QUOTE>("\\".|[^\'\n\\]?)"\'"          {
	BEGIN(INITIAL);
	V_LOG_LEXER("QUOTED CHARACTER");
	return TK_LIT_CHAR;
}

<QUOTE>{GRAPH}                         {
	yyless(1);
	BEGIN(INITIAL);
	V_LOG_LEXER("MALFORMED QUOTE");
	return TK_ERRO;
}

	/* number literals */
{NUMBER}/{ALNUM}*         {
	BEGIN(DECIMAL);
	V_LOG_LEXER("DECIMAL STATE");
	yyless(0);
}

	/* decimal state */
<DECIMAL>{
	/* float */
{NUMBER}+"."{NUMBER}+{SCI_NOT}?        {
	BEGIN(INITIAL);
	V_LOG_LEXER("FLOATING POINT");
	return TK_LIT_FLOAT;
}

	/* malformed float */
{NUMBER}+"."{ALNUM}+                   {
	BEGIN(INITIAL);
	V_LOG_LEXER("MALFORMED FLOATING POINT");
	return TK_ERRO;
}

	/* integer */
{NUMBER}+                              {
	BEGIN(INITIAL);
	V_LOG_LEXER("INTEGER");
	return TK_LIT_INT;
}

	/* malformed decimal */
{ALNUM}+                               {
	BEGIN(INITIAL);
	V_LOG_LEXER("MALFORMED DECIMAL");
	return TK_ERRO;
}

}
	/* ---------- misc section ----------  */
	/* whitespace or newlines between tokens */
({WHITE}|\n)+ { }

	/* error catch-all */
<*>.                                   { V_LOG_LEXER("UNKNOWN"); BEGIN(INITIAL); return TK_ERRO; }
%%
