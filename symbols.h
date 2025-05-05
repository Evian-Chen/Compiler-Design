#ifndef SYMBOLS_H
#define SYMBOLS_H

#ifdef __cplusplus
extern "C" {
#endif

#define TABLE_SIZE 211

typedef struct SymbolEntry {
    char* name;
    int index;
    struct SymbolEntry* next;
} SymbolEntry;

typedef struct SymbolTable {
    SymbolEntry* table[TABLE_SIZE];
    int currentIndex;
} SymbolTable;

// Create a new symbol table
SymbolTable* createSymbolTable();

// Look up a name in the symbol table, return index or -1 if not found
int lookup(SymbolTable* st, const char* name);

// Insert a name into the table, return the assigned index
int insert(SymbolTable* st, const char* name);

// Dump the contents of the symbol table to stdout
void dump(SymbolTable* st);

// Check if a name is declared
int isDeclared(SymbolTable* st, const char* name);

#ifdef __cplusplus
}
#endif

#endif // SYMBOLS_H
