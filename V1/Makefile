all: ZINC.tab.c lex.yy.c ZINC

ZINC.tab.c ZINC.tab.h: ZINC.y
	bison -d ZINC.y
	
lex.yy.c: ZINC.l ZINC.tab.h
	flex ZINC.l

ZINC: ZINC.tab.c ZINC.tab.h SymTab.c
	gcc -Wall -o arg010ZINC ZINC.tab.c SymTab.c -ll

clean:
	rm arg010ZINC ZINC.tab.c lex.yy.c ZINC.tab.h
