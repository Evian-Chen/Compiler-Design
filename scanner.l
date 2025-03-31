%{
    #define MAX_LINE_LENG 256

    int linenum = 0;
}

%%

"(" {token('(');}