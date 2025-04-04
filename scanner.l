%{

#include <stdio.h>
#include <string.h>

#define MAX_LINE_LENG 256

int linenum = 1;
char buf[MAX_LINE_LENG];
char tempBuf[MAX_LINE_LENG];
int bufIndex = 0;
int tempBufIndex = 0;


// define all key words
const char* keywords[] = {
    "bool", "break", "case", "char", "const", "continue", "default", "do", "double", "else", "extern", "false", "float", "for", "foreach", "if",
    "int", "print", "println", "read", "return", "string", "switch", "true", "void", "while", NULL
};

// check if str is a key word
const int isKeyword(const char* str) {
    for (int i=0; keywords[i] != NULL; i++) {
        if (strcmp(str, keywords[i]) == 0) {
            return 1;
        }
    }

    // not a key word
    return 0;
}

// add string into buffer
void addToBuf(const char* str) {
    int len = strlen(str);
    if (bufIndex + len < MAX_LINE_LENG) {
        strncpy(buf + bufIndex, str, len);
        bufIndex += len;
    }
}

%}

%x  SINGLE_COMMENT
%x  PRINT_STATE
%x  MUTI_COMMENT

digs    [0-9]
word    [a-zA-Z_][a-zA-Z0-9_]*
symbol  [^0-9a-zA-Z]
spaces  [ \t\r\f\v]

%%

\/\/    { 
    addToBuf(yytext);
    BEGIN(SINGLE_COMMENT); 
}

\/\* {
    printf("begin muti comment\n");
    addToBuf(yytext);
    BEGIN(MUTI_COMMENT);
}

{digs}  {
    printf("i found integer");
    addToBuf(yytext);
}

{word}{spaces} {
    if (isKeyword(yytext)) {
        printf("<%s>\n", yytext);
    } else {
        printf("<ID: %s>\n", yytext);
    }
    addToBuf(yytext);
}

{spaces}    {
    addToBuf(yytext);
}

\n  {
    buf[bufIndex] = '\0';  // terminate current line
    printf("%d: %s\n", linenum++, buf);
    bufIndex = 0;  // reset buffer
}

\"  {
    addToBuf(yytext);
    BEGIN(PRINT_STATE);
}

{symbol}    {
    printf("<'%s'>\n", yytext);
    addToBuf(yytext);
}

<SINGLE_COMMENT>\n    {
    buf[bufIndex] = '\0';
    printf("%d: %s\n", linenum++, buf);
    bufIndex = 0;
    BEGIN(INITIAL);
}

<SINGLE_COMMENT>[^\n]+  {
    addToBuf(yytext);
}

<MUTI_COMMENT>\*\/  {
    addToBuf(yytext);
    BEGIN(INITIAL);
}

<MUTI_COMMENT>.    {
    addToBuf(yytext);
}

<MUTI_COMMENT>\n    {
    addToBuf(yytext);
    buf[bufIndex] = '\0';
    printf("%d: %s", linenum++, buf);
    bufIndex = 0;
}

<PRINT_STATE>[^\n]+\" {
    addToBuf(yytext);
    BEGIN(INITIAL);
}

%%

int main(void) {
    yylex();

    if (strlen(buf) > 0) {
        buf[bufIndex] = '\0';  // terminate current line
        printf("%d: %s\n", linenum+1, buf);
    }

    return 0;
}