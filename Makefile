scanner: y.tab.o lex.yy.o symbols.o
	gcc -o p y.tab.o lex.yy.o symbols.o -lfl

y.tab.o: parser.y
	yacc -d parser.y
	gcc -c -g y.tab.c

lex.yy.o: scanner.l
	lex scanner.l
	gcc -c -g lex.yy.c

symbols.o: symbols.c symbols.h
	gcc -c -g symbols.c

clean:
	rm -f *.o lex.yy.c y.tab.c y.tab.h p
