%{

#include <stdio.h>
#include <string.h>
#include <ctype.h>

#define MAX_LINE_LENG 256

#define token(tok)           printf("<%s>\n", tok)
#define tokenInteger(tok, v) printf("<%s:%d>\n", tok, v)
#define tokenReals(tok, v)   printf("<%s:%s>\n", tok, v)
#define tokenString(tok, s)  printf("<%s:%s>\n", tok, s)

#define TABLE_SIZE 211

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

typedef struct SymbolEntry {
    char* name;
    int index;
    struct SymbolEntry* next;
} SymbolEntry;

typedef struct SymbolTable {
    SymbolEntry* table[211];
    int currentIndex;
} SymbolTable;

SymbolTable* create() {
    SymbolTable* st = (SymbolTable*)malloc(sizeof(SymbolTable));
    for (int i = 0; i < TABLE_SIZE; i++) {
        st->table[i] = NULL;
    }
    st->currentIndex = 0;
    return st;
}

unsigned int hash(const char* str) {
    unsigned int h = 0;
    while (*str) h = (h << 4) + *str++;
    return h % TABLE_SIZE;
}

int lookup(SymbolTable* st, const char* name) {
    unsigned int h = hash(name);
    SymbolEntry* entry = st->table[h];
    while (entry != NULL) {
        if (strcmp(entry->name, name) == 0)
            return entry->index;
        entry = entry->next;
    }
    return -1; // not found
}

void dump(SymbolTable* st) {
    printf("Symbol Table:\n");
    for (int i = 0; i < TABLE_SIZE; i++) {
        SymbolEntry* entry = st->table[i];
        while (entry) {
            printf("%s\n", entry->name);
            entry = entry->next;
        }
    }
}

int insert(SymbolTable* st, const char* name) {
    int existing = lookup(st, name);
    if (existing != -1)
        return existing;

    unsigned int h = hash(name);
    SymbolEntry* newEntry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    newEntry->name = strdup(name);  
    newEntry->index = st->currentIndex++;
    newEntry->next = st->table[h];
    st->table[h] = newEntry;

    return newEntry->index;
}

char* toUpper(const char* str) {
    static char ans[256];
    int i = 0;
    while (str[i] && i < 255) {
        ans[i] = toupper((char)(str[i]));
        i++;
    }
    ans[i] = '\0';
    return ans;
}

SymbolTable* globalTable;

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
    addToBuf(yytext);
    BEGIN(MUTI_COMMENT);
}

[-+]?[0-9]+\.[0-9]+([eE][-+]?[0-9]+)? {
    tokenReals("real", yytext);
    addToBuf(yytext);
}


[+-]?[1-9]digs+    {
    printf("<i found integer: %s>\n", yytext);
    tokenInteger("integer", atoi(yytext));
    addToBuf(yytext);
}

{word} {
    if (isKeyword(yytext)) {
        // token(yytext);
        printf("<%s>\n", toUpper(yytext));
    } else {
        int id = insert(globalTable, yytext);
        // tokenString("ID", yytext);
        printf("<ID: %s>\n", yytext);
    }
    addToBuf(yytext);
}

"true" {
    tokenInteger("integer", 1);
}

\"[^\n]+\"    {
    printf("<string:%s>\n", yytext);
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
    globalTable = create();

    yylex();

    if (strlen(buf) > 0) {
        buf[bufIndex] = '\0';  // terminate current line
        printf("%d: %s\n", linenum+1, buf);
    }

    dump(globalTable);

    return 0;
}