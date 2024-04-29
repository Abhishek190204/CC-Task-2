%{
#include <stdio.h>
#include <string.h>
extern FILE *yyin;
int yylex();
int yyerror();
int flag=0;

typedef struct symbol {
    char name[100];
    char type[10];
    int assigned;
} symbol;
symbol table[1000];
int symtab_len = 0;

symbol* lookup(char* name) {
    for(int i = 0; i < symtab_len; i++) {
        if(strcmp(symtab[i].name, name) == 0) {
            return &symtab[i];
        }
    }
    return NULL;
}

void insert(char* name, char* type) {
    symbol* s = lookup(name);
    if(s != NULL) {
        printf("Error: Duplicate declaration of variable %s\n", name);
        flag = 0;
    } else {
        strcpy(symtab[symtab_len].name, name);
        strcpy(symtab[symtab_len].type, type);
        symtab[symtab_len].assigned = 0;
        symtab_len++;
    }
}
void assign(char* name) {
    symbol* s = lookup(name);
    if(s == NULL) {
        printf("Error: Undeclared variable %s\n", name);
        flag = 0;
    } else {
        s->assigned = 1;
    }
}

void check_type(char* name, char* type) {
    symbol* s = lookup(name);
    if(s != NULL && strcmp(s->type, type) != 0) {
        printf("Error: Type mismatch for variable %s\n", name);
        flag = 0;
    }
}
%}
%union
{
    int ival;
	double rval;
    char* sval;
}


%token  PROG_ID INT REAL BOOL VAR  TO  DOWNTO  IF  ELSE  WHILE  FOR  THEN  DO  ARRAY  OF  AND  OR  NOT  BEG  END  READ  WRITE 
   PLUS  MINUS  MULTIPLY  DIVIDE  MOD  EQUAL  ASSIGN  LT  GT  LTE  GTE  NE  SEMICOLON  COLON  COMMA  DOT  LP  RP  LB  RB
%token<ival> NUM
%token<rval> REALNUM
%token<sval> STRING CHAR ID
%%
prog: PROG_ID SEMICOLON v Block DOT {flag=1;}
    ;
v : VAR va
    | ;
va: va varlist COLON type SEMICOLON
    | varlist COLON type SEMICOLON;    
type: t
    | ARRAY LB NUM DOT DOT NUM RB OF t;
t: INT {current_type = "INT";}
    | REAL {current_type = "REAL";}
    | BOOL  {current_type = "BOOL";}
    | CHAR; {current_type = "CHAR";}
varlist: varlist COMMA ID 
    | ID;    
stmt_list: stmt_list stmt    
    |
    ;
stmt: Block 
    |assign_stmt SEMICOLON
    | if_stmt SEMICOLON
    | for_stmt SEMICOLON
    | while_stmt SEMICOLON
    | io_stmt SEMICOLON
    ;
Block: BEG stmt_list END
    ;
io_stmt: READ LP ID RP
    | READ LP ID LB expression RB RP
    | WRITE LP STRING RP;
    | WRITE LP varlist RP;
if_stmt: IF expression THEN stmt else_part;
else_part: ELSE stmt
    | ;
while_stmt: WHILE expression DO stmt;
for_stmt: FOR ID ASSIGN e TO e DO stmt
    | FOR ID ASSIGN e DOWNTO e DO stmt;
assign_stmt: ID ASSIGN e
    |ID LB e RB ASSIGN e;
expression: expression LT e
    | expression GT e
    | expression LTE e
    | expression GTE e
    | expression NE e
    | expression EQUAL e
    | e;
e: e PLUS T
    | e MINUS T
    | e OR T;    
    | T;
T: T MULTIPLY f
    | T DIVIDE f
    | T MOD f
    | T AND f;
    | f;
f: LP expression RP
    | NOT f
    |ID
    |ID LB expression RB
    |NUM
    |REALNUM;    
%%
int main() {
    char filename[100];
    printf("Enter the filename: ");
    scanf("%s", filename);
    yyin = fopen(filename, "r");
    if(yyin == NULL){
        printf("Error opening file!\n");
        return 1;
    }
    yyparse();
    if(flag==1)
        printf("valid input\n");
    else
        printf("syntax error\n");
    fclose(yyin);
    return 0;
}

int yyerror(const char *msg) {
    flag=0;
    /* printf("syntax error\n"); */
    return 0;
}
