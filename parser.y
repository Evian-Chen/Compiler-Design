%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbols.h"

SymbolTable* globalTable;
extern int yylex();
extern int linenum;
extern char *yytext;
extern FILE *yyin;

void yyerror(const char *msg);
%}

%union {
    int ival;
    char *sval;
}

%token <ival> INTEGER
%token <sval> STRING
%token <sval> ID
%token <sval> REAL

%token CONST VOID INT BOOL FLOAT STRING_TYPE
%token IF ELSE WHILE FOR FOREACH RETURN READ PRINT PRINTLN

%token PLUS MINUS MUL DIV MOD
%token ASSIGN
%token EQ NEQ LT LE GT GE
%token AND OR NOT
%token INC DEC
%token DOTDOT

%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET
%token SEMICOLON COMMA COLON

%left OR
%left AND
%left EQ NEQ
%left LT LE GT GE
%left PLUS MINUS
%left MUL DIV MOD
%right NOT
%right UMINUS

%start program

%%

program
    : top_decls
    ;

top_decls
    : top_decls top_decl
    | /* empty */
    ;

top_decl
    : const_decl
    | var_decl
    | func_decl
    ;

var_decl
    : type id_list SEMICOLON
    ;

const_decl
    : CONST type ID ASSIGN expression SEMICOLON
    ;

id_list
    : id_elem
    | id_list COMMA id_elem
    ;

id_elem
    : ID
    | ID ASSIGN expression
    ;

type
    : INT
    | FLOAT
    | BOOL
    | STRING_TYPE
    | type LBRACKET INTEGER RBRACKET
    ;

func_decl
    : type ID LPAREN params RPAREN block
    | VOID ID LPAREN params RPAREN block
    | ID LPAREN params RPAREN block
    ;

params
    : param_list
    | /* empty */
    ;

param_list
    : param
    | param_list COMMA param
    ;

param
    : type ID
    ;

block
    : LBRACE stmt_list RBRACE
    ;

stmt_list
    : stmt_list statement
    | /* empty */
    ;

statement
    : var_decl
    | const_decl
    | assign_stmt
    | print_stmt
    | println_stmt
    | read_stmt
    | return_stmt
    | incdec_stmt
    | if_stmt
    | while_stmt
    | for_stmt
    | foreach_stmt
    | proc_call SEMICOLON
    | block
    | SEMICOLON
    ;

assignment
    : ID ASSIGN expression
    ;

assign_stmt
    : assignment SEMICOLON
    ;

for_stmt
    : FOR LPAREN assignment SEMICOLON expression SEMICOLON for_update RPAREN statement
    ;

for_update
    : assignment
    | ID INC
    | ID DEC
    ;

print_stmt
    : PRINT expression SEMICOLON
    ;

println_stmt
    : PRINTLN expression SEMICOLON
    ;

read_stmt
    : READ ID SEMICOLON
    ;

return_stmt
    : RETURN expression SEMICOLON
    ;

incdec_stmt
    : ID INC SEMICOLON
    | ID DEC SEMICOLON
    ;

if_stmt
    : IF LPAREN expression RPAREN statement
    | IF LPAREN expression RPAREN statement ELSE statement
    ;

while_stmt
    : WHILE LPAREN expression RPAREN statement
    ;

foreach_stmt
    : FOREACH LPAREN ID COLON expression DOTDOT expression RPAREN statement
    ;

proc_call
    : ID LPAREN args RPAREN
    ;

args
    : arg_list
    | /* empty */
    ;

arg_list
    : expression
    | arg_list COMMA expression
    ;

expression
    : expression PLUS expression
    | expression MINUS expression
    | expression MUL expression
    | expression DIV expression
    | expression MOD expression
    | expression EQ expression
    | expression NEQ expression
    | expression LT expression
    | expression LE expression
    | expression GT expression
    | expression GE expression
    | expression AND expression
    | expression OR expression
    | NOT expression
    | MINUS expression %prec UMINUS
    | ID INC
    | ID DEC
    | INC ID
    | DEC ID
    | LPAREN expression RPAREN
    | proc_call
    | ID
    | INTEGER
    | REAL
    | STRING
    ;

%%

void yyerror(const char *msg) {
    fprintf(stderr, "Error at line %d: %s (token: %s)\n", linenum, msg, yytext);
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: ./parser <inputfile>\n");
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("fopen");
        return 1;
    }

    globalTable = createSymbolTable();
    if (yyparse() == 0) {
        printf("Parsing completed successfully.\n");
    } else {
        printf("Parsing failed.\n");
    }

    return 0;
}
