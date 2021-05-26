%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

/* prototypes */
int yylex(void);
void yyerror(char *s);

//Here will be defination of sym table 😮 /* symbol table */
%}

/* Tokens from lexer */
// Data types
%token INT_TYPE
%token DOUBLE_TYPE
%token CHAR_TYPE
%token BOOL_TYPE
%token VOID

// Keywords
%token CONST
%token IF
%token ELSE
%token SWITCH
%token CASE
%token DEFAULT
%token FOR
%token UNTIL
%token WHILE
%token BREAK
%token CONTINUE
%token RETURN
%token PRINT

// Operators
%token INC
%token DEC
%token SHL
%token SHR
%token LOGIC_AND
%token LOGIC_OR
%token EQ
%token NE
%token GE
%token LE

// Values
%token INTEGER
%token FLOAT
%token CHAR
%token BOOL
%token IDENTIFIER


%nonassoc IFX
%nonassoc ELSE

// Order matters here:
%right      '='
%left       LOGIC_OR
%left       LOGIC_AND
%left       '|'
%left       '^'
%left       '&'
%left       EQ NE
%left       LE GE '<' '>'
%left       SHR SHL
%left       '-' '+'
%left       '*' '/' '%'


%%
/*   Rules Here:   */
program:
        function                { exit(0); }
        ;

function: ;


%%

void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
    printf("Welcome:\n");
    yyparse();
    return 0;
}
