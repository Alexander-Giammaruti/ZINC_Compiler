/*
	programmer:	Alexander Giammaruti
	date started:	4/10/2018
	final update:	5/3/2018
	
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "SymTab.h"

enum types {integer};

typedef enum types Types;

struct node{ 
        char lexeme[20];
        int lineNum;
	Types type;
        struct node *left, *right;
};

static struct node *root = NULL;

void dropTable(struct node **Pt);
void search(struct node **Pt, char * key, int lineNum, int pastBegin);

struct node *newNode(char *lex, int lineNum){
        struct node *temp = malloc(sizeof(struct node));
        strcpy(temp->lexeme, lex);
        temp->lineNum = lineNum;
	temp->type = integer;
        temp->left = temp->right = NULL;
        return temp;
}// end newNode

void performDropTable(){
	dropTable(&root);
}

void dropTable(struct node **Pt){
        if((*Pt) == NULL){
                fprintf(stderr, "ERROR: Symbol table is unpopulated!\n");
                return;
        }
        if((*Pt)->left != NULL){
                dropTable(&(*Pt)->left);
        }
        if((*Pt)->right != NULL){
                dropTable(&(*Pt)->right);
        }
        free((*Pt));
}// end dropTable



void performSearch(char * key, int lineNum, int pastBegin){
	search(&root, key, lineNum, pastBegin);
}

void search(struct node **Pt, char * key, int lineNum, int pastBegin){
        

	if(*Pt == NULL){
                *Pt = newNode(key, lineNum);
                return;
        }// end if

        if(strcmp(key,(*Pt)->lexeme) < 0){
                if((*Pt)->left != NULL){
                        search(&(*Pt)->left, key, lineNum, pastBegin);
                }else{
                        if(pastBegin != 1){
                                (*Pt)->left = newNode(key, lineNum);
                        }else{
                                fprintf(stderr, "ERROR: unknown variable name: %s :referenced, but never defined at line %d\n", key, lineNum);
                                return;
                        }
                }// end if
        }else if(strcmp(key,(*Pt)->lexeme) > 0){
                if((*Pt)->right != NULL){
                        search(&(*Pt)->right, key, lineNum, pastBegin);
                }else{
                        if(pastBegin != 1){
                                (*Pt)->right = newNode(key, lineNum);
                        }else{
                                fprintf(stderr, "ERROR: unknown variable name: %s :referenced, but never defined at line %d\n", key, lineNum);
                                return;
                        }
                }// end if
        }else{
                if(pastBegin == 0){
                        fprintf(stderr, "ERROR: variable: %s :is multiply-defined at line %d\n", key, lineNum);
			return;
                }//end if               
        }// end if

}// end search
// For testing purposes
/*
int main(){
	int again = 1;
	static int lineNum = 0;	
	while(again){
		char name[20];
		
		scanf("%s", name);
		search(name, &root, name, lineNum, 0);
		printf("Again? :");
		scanf("%d", &again);
		lineNum++;
	}

	dropTable(&root);
	return 0;
}
*/
