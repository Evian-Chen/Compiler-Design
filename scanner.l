%{
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "y.tab.h"
#include "symbols.h"

#define MAX_LINE_LENG 256

#define token(s,t) { addToBuf(yytext); return(t); }
#define tokenInteger(s,v) { yylval.ival = v; addToBuf(yytext); return(INTEGER); }
#define tokenReals(s,v) { yylval.sval = strdup(v); addToBuf(yytext); return(REAL); }
#define tokenString(s,v) { yylval.sval = strdup(v); addToBuf(yytext); return(STRING); }

int linenum = 1;
char buf[MAX_LINE_LENG];
int bufIndex = 0;
extern SymbolTable* globalTable;

void addToBuf(const char* str) {
    int len = strlen(str);
    if (bufIndex + len < MAX_LINE_LENG) {
        strncpy(buf + bufIndex, str, len);
        bufIndex += len;
    }
}

%}

%x MUTI_COMMENT
%option noyywrap

id      [a-zA-Z_][a-zA-Z0-9_]*
digs    [0-9]+
real    [0-9]+\.[0-9]+([eE][-+]?[0-9]+)?
ws      [ \t\r\f\v]+

%%

"//".*                  { /* skip single-line comment */ }

"/*"                      { BEGIN(MUTI_COMMENT); }
<MUTI_COMMENT>"*/"        { BEGIN(INITIAL); }
<MUTI_COMMENT>\n          { linenum++; }
<MUTI_COMMENT>.           { /* skip character */ }


{ws}                    { /* skip whitespace */ }

{real}                  { tokenReals("REAL", yytext); }
{digs}                  { tokenInteger("INTEGER", atoi(yytext)); }

"true"                  { tokenInteger("INTEGER", 1); }
"false"                 { tokenInteger("INTEGER", 0); }

\"([^\\\"\n]|\\.)*\"  { tokenString("STRING", yytext); }

"++"                    { token("++", INC); }
"--"                    { token("--", DEC); }
"=="                    { token("==", EQ); }
"!="                    { token("!=", NEQ); }
"<="                    { token("<=", LE); }
">="                    { token(">=", GE); }
"&&"                    { token("&&", AND); }
"||"                    { token("||", OR); }
"="                     { token("=", ASSIGN); }
"<"                     { token("<", LT); }
">"                     { token(">", GT); }
"!"                     { token("!", NOT); }
"+"                     { token("+", PLUS); }
"-"                     { token("-", MINUS); }
"*"                     { token("*", MUL); }
"/"                     { token("/", DIV); }
"%"                     { token("%", MOD); }
".."                    { token("..", DOTDOT); }     

";"                     { token(";", SEMICOLON); }
","                     { token(",", COMMA); }
":"                     { token(":", COLON); }
"("                     { token("(", LPAREN); }
")"                     { token(")", RPAREN); }
"{"                     { token("{", LBRACE); }
"}"                     { token("}", RBRACE); }
"["                     { token("[", LBRACKET); }
"]"                     { token("]", RBRACKET); }

{id} {
    if (strcmp(yytext, "if") == 0) return(IF);
    else if (strcmp(yytext, "else") == 0) return(ELSE);
    else if (strcmp(yytext, "while") == 0) return(WHILE);
    else if (strcmp(yytext, "for") == 0) return(FOR);
    else if (strcmp(yytext, "foreach") == 0) return(FOREACH);
    else if (strcmp(yytext, "return") == 0) return(RETURN);
    else if (strcmp(yytext, "read") == 0) return(READ);
    else if (strcmp(yytext, "print") == 0) return(PRINT);
    else if (strcmp(yytext, "println") == 0) return(PRINTLN);
    else if (strcmp(yytext, "const") == 0) return(CONST);
    else if (strcmp(yytext, "void") == 0) return(VOID);
    else if (strcmp(yytext, "int") == 0) return(INT);
    else if (strcmp(yytext, "bool") == 0) return(BOOL);
    else if (strcmp(yytext, "string") == 0) return(STRING_TYPE);
    else if (strcmp(yytext, "float") == 0) return(FLOAT);
    else if (strcmp(yytext, "main") == 0) return(ID);  
    else {
        yylval.sval = strdup(yytext);
        insert(globalTable, yytext);
        return(ID);
    }
}

.       { printf("Unknown token: %s\n", yytext); }
\n    { linenum++; }


%%

