/*
        programmer:     Alexander Giammaruti
        final update:   5/3/2018
       
	Final assignment for Dr. Timothy McGuire's COSC 4316.01 Compiler Design and Construction:
 
        Bison specification to create a parser/code generator for the ZINC programming language
        in conjunction with a lexical analyzer specification contained in the file ZINC.l and
        a simple symbol table defined in SymTab.c

        to compile:
                1) flex ZINC.l
                2) bison -dv ZINC.y
                3) gcc -Wall -o arg010ZINC ZINC.tab.c SymTab.c -ll
	
	or more simply make use of the provided Makefile

*/

%{
#include <stdio.h>
#include <ctype.h>
#include<string.h>
#include<stdlib.h>

FILE *fileOUT;

#define YYSTYPE char*

void performDropTable();
char *genLabel();
int yylex();
int identifier(char *c);
int yyerror(char *s);
%}

%token NUM
%token ID
%token IFSYM
%token THENSYM
%token ELSESYM
%token BEGINSYM
%token ENDSYM
%token ENDIFSYM
%token ENDWHILESYM
%token WHILESYM
%token LOOPSYM
%token PROGRAMSYM
%token VARSYM
%token INTSYM
%token WRITEINT
%token READINT
%token LP
%token RP
%token ASGN
%token SC
%token COLON
%token POWSYM
%token MULSYM
%token DIVSYM
%token MODSYM
%token PLUSSYM
%token MINUSSYM
%token EQ
%token NE
%token LT
%token GT
%token LE
%token GE

%left PLUSSYM MINUSSYM
%left MULSYM DIVSYM MODSYM
%left POWSYM


%%
program: 		PROGRAMSYM {fprintf(fileOUT ,"Section .data\n");}declarations 
				BEGINSYM {fprintf(fileOUT, "Section .code\n");} 
				statementSequence ENDSYM {fprintf(fileOUT, "\tHALT\n");}
			;
declarations: 		VARSYM ID {; fprintf(fileOUT, "\t%s:\tword\n", $2);} COLON type SC  declarations
			|/*Empty*/
			;
type:			INTSYM
			;
statementSequence:	statement SC statementSequence
			|/*Empty*/
			;
statement:		assignment
			|ifStmt
			|whileStmt
			|writeInt
			|/*Empty*/
			;
			/* Modified grammar to resolve reduce/reduce conflict*/
assignment:		ID {fprintf(fileOUT, "\tLVALUE\t%s\n", $1);} ASGN assignRest 
			;
assignRest:		expression {fprintf(fileOUT, "\tSTO\n");}
			|READINT {fprintf(fileOUT, "\tREAD\n\tSTO\n");}
			;

ifStmt:			IFSYM expression {$$ = strdup(genLabel()); $1 = strdup(genLabel()); 
				fprintf(fileOUT, "\tGOFALSE %8s\n", $1);} THENSYM statementSequence 
				{fprintf(fileOUT, "\tGOTO\t%s\n\tLABEL\t%s\n", $3, $1);}elseClause 
				ENDIFSYM {fprintf(fileOUT, "\tLABEL\t%s\n", $3);}
			;
elseClause:		ELSESYM statementSequence
			|/*Empty*/
			;
whileStmt:		WHILESYM {$$ = strdup(genLabel()); $1 = strdup(genLabel()); fprintf(fileOUT, "\tLABEL\t%s\n", $$);}
				expression {fprintf(fileOUT, "\tGOFALSE\t%s\n", $1);} LOOPSYM statementSequence 
				ENDWHILESYM {fprintf(fileOUT, "\tGOTO\t%s\n\tLABEL\t%s\n", $2, $1);}
			;
writeInt:		WRITEINT expression {fprintf(fileOUT, "\tPRINT\n");}
			;
expression:		simpleExpression
			|simpleExpression EQ expression {fprintf(fileOUT, "\tEQ\n");}
			|simpleExpression NE expression {fprintf(fileOUT, "\tNE\n");}
			|simpleExpression LT expression {fprintf(fileOUT, "\tLT\n");}
			|simpleExpression GT expression {fprintf(fileOUT, "\tGT\n");}
			|simpleExpression LE expression {fprintf(fileOUT, "\tLE\n");}
			|simpleExpression GE expression {fprintf(fileOUT, "\tGE\n");}
			;
simpleExpression:	//grammar modified to correct order of operations errors
			simpleExpression PLUSSYM simpleExpression {fprintf(fileOUT, "\tADD\n");}
			|simpleExpression MINUSSYM simpleExpression {fprintf(fileOUT, "\tSUB\n");}
			|term
			;
term:			//grammar modified to correct order of operations errors
			term MULSYM term {fprintf(fileOUT, "\tMPY\n");}  
			|term DIVSYM term {fprintf(fileOUT, "\tDIV\n");}
			|term MODSYM term {fprintf(fileOUT, "\tMOD\n");}
			|factor
			;
factor:			primary POWSYM factor { int x = atoi($1); int n = atoi($3); 
				fprintf(fileOUT, "\tPOP\n\tPOP\n");
				for(int i = 1; i <= n; i++){
					fprintf(fileOUT, "\tPUSH\t%d\n", x);
				}
				for(int i = 1; i < n; i++){    
                                        fprintf(fileOUT, "\tMPY\n");
                                }
			}	
			|primary
			;
primary:		ID {fprintf(fileOUT, "\tRVALUE\t%s\n", $1);}
			|NUM {fprintf(fileOUT, "\tPUSH\t%s\n", $1);}
			|LP expression RP
			;
%%

#include "lex.yy.c"

char * genLabel(){
	static int numLabel = 0;
	char buff[3];
	char label[8] = "LABEL";
	numLabel++;
	snprintf(buff, sizeof(buff), "%d", numLabel);
	return strcat(label, buff);
	
}// end genLabel

int yyerror(char *s){
	printf("%s at line: %d found: %s\n", s, lineNum, yytext);
	return(1);
}

void open_input(int argc, char *argv[]){
	if(argc > 1){
		if((yyin= fopen(argv[1], "r"))==NULL){
			fprintf(stderr, "ERROR: failed to open input file: %s\n", argv[1]);
			exit(1);
		}
	}else{
		char fileName[20];
		printf("Enter file name for input: ");
		scanf("%s", fileName);
		if((yyin= fopen(fileName, "r"))==NULL){
                        fprintf(stderr, "ERROR: failed to open input file: %s\n", fileName);
                        exit(1);
                }
		
	}	
}// end open_input

int main(int argc, char *argv[]){

	fileOUT = fopen("output.txt", "w");
	open_input(argc, argv);
	yyparse();
	performDropTable();
}
