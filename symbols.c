#include "symbols.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define TABLE_SIZE 211

SymbolTable* createSymbolTable() {
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

int isDeclared(SymbolTable* st, const char* name) {
    return lookup(st, name) != -1;
}

int lookup(SymbolTable* st, const char* name) {
    unsigned int h = hash(name);
    SymbolEntry* entry = st->table[h];
    while (entry) {
        if (strcmp(entry->name, name) == 0)
            return entry->index;
        entry = entry->next;
    }
    return -1;
}

int insert(SymbolTable* st, const char* name) {
    int existing = lookup(st, name);
    if (existing != -1) return existing;

    unsigned int h = hash(name);
    SymbolEntry* newEntry = (SymbolEntry*)malloc(sizeof(SymbolEntry));
    newEntry->name = strdup(name);
    newEntry->index = st->currentIndex++;
    newEntry->next = st->table[h];
    st->table[h] = newEntry;

    return newEntry->index;
}

void dump(SymbolTable* st) {
    printf("Symbol Table:\n");
    for (int i = 0; i < TABLE_SIZE; i++) {
        SymbolEntry* entry = st->table[i];
        while (entry) {
            printf("  [%d] %s\n", entry->index, entry->name);
            entry = entry->next;
        }
    }
}
