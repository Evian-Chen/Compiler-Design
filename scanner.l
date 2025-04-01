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

%x SINGLE_COMMENT

digs    [0-9]
word    [a-zA-Z_][a-zA-Z0-9_]*
symbol  [^0-9a-zA-Z]
spaces  [ \t\r\f\v]

%%

{digs}  {
    printf("i found integer");
}

{word} {
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
    printf("here's new line\n");
    linenum++;
    buf[bufIndex] = '\0';  // terminate current line
    printf("%d: %s\n", linenum, buf);
    bufIndex = 0;  // reset buffer
}

\/\/    { 
    addToBuf(yytext);
    BEGIN(SINGLE_COMMENT); 
}

{symbol}    {
    printf("<'%s'>\n", yytext);
    addToBuf(yytext);
}

<SINGLE_COMMENT>\n    {
    buf[bufIndex] = '\0';
    printf("%d: %s\n", linenum, buf);
    bufIndex = 0;
    linenum++;
    BEGIN(INITIAL);
}

<SINGLE_COMMENT>[^\n]+  {
    addToBuf(yytext);
}

%%

int main(void) {
    yylex();
    return 0;
}