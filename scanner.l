%{
    #define MAX_LINE_LENG 256

    int linenum = 0;
    char buf[MAX_LINE_LENG];
    int buf_index = 0;
}

// define all key words
const char* keywords[] = {
    "bool", "break", "case", "char", "const", "continue", "default", "do", "double", "else", "extern", "false", "float", "for", "foreach", "if",
    "int", "print", "println", "read", "return", "string", "switch", "true", "void", "while", NULL
}

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

digit   [0-9]
ascii   [a-zA-Z]

// don't call yywarp()
%option noyywrap

%%

\n  {
    linenum++;
    buf[buf_index] = '\0';  // terminate current line
    printf("%d: %s\n", linenum, buf);
    buf_index = 0;  // reset buffer
}

.   {
    // put current token into buffer
    if (buf_index < MAX_LINE_LENG - 1) {
        buf[buf_index] = yytext[0];
        buf_index++;
    }
}

%%

int main(void) {
    yylex();
    return 0;
}