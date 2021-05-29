%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "lex.yy.c"
/* prototypes */
int yylex(void);
int yyerror(char *s);

//Here will be defination of sym table 😮 /* symbol table */ 
%}


% union {
    int intVal;
}

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
%token SCAN
%token STRING
%token WHITESPACE

// Operators
%token INC
%token DEC
%token ADD_EQ
%token SUB_EQ
%token MULT_EQ
%token DIV_EQ
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
%token DOUBLE
%token CHAR
%token BOOL
%token IDENTIFIER




// Order matters here:
%right      '='
%left       ','
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
%right      PRE_INC PRE_DEC
%left       SUF_INC SUF_DEC
%right      '!'


%nonassoc ELSE
%nonassoc UMINUS
%nonassoc PRECEED_ELSE
%nonassoc PRECEED_FUNC

%%



start: start line_stmt 
     | line_stmt  
     ;
    
line_stmt: function 
         | declaration 
         ;

function: data_type IDENTIFIER '(' argument_list ')' scope_stmt
        ;

argument_list: arguments
             | 
             ;

arguments: arguments ',' argument 
         | argument
         ;

argument: data_type identifier
        ;

scope_stmt: '{' stmts '}'
          ;
        
stmts: stmts stmt  
     | 
     ;

stmt: scope_stmt | atomic_stmt
    ;

atomic_stmt: if_block | while_block | for_block | declaration | print 
    | scan | function_invoke ';' | RETURN ';' | CONTINUE ';' 
    | BREAK ';' | RETURN sub_expression ';'
    ;

declaration: data_type declaration_list ';'     
            | declaration_list ';' | unary_expression ';'
            ;

declaration_list: declaration_list ',' sub_declaration
                | sub_declaration
                ;

sub_declaration: assign_expression | identifier | array_indexing
                ;

if_block: IF '(' expression ')' stmt %prec PRECEED_ELSE | IF '(' expression ')' stmt ELSE stmt 
        ;

for_block: FOR '(' expression_statement expression_statement ')' stmt 
         | FOR '(' expression_statement expression_statement expression_statement ')' stmt 
         ;

while_block: WHILE '(' expression ')' stmt 
           ;        


expression_statement: expression ';'
          | ';'
          ;

expression: expression ',' sub_expression
          | sub_expression
          ;

sub_expression: sub_expression '>' sub_expression
                | sub_expression '<' sub_expression
                | sub_expression EQ sub_expression
                | sub_expression NE sub_expression
                | sub_expression LE sub_expression
                | sub_expression GE sub_expression
                | sub_expression LOGIC_AND sub_expression
                | sub_expression LOGIC_OR sub_expression
                | '!' sub_expression
                | arithmetic_expression
                | assign_expression
                | unary_expression
                ;

assign_expression: lhs assign_operation arithmetic_expression
                 | lhs assign_operation array_indexing
                 | lhs assign_operation function_invoke
                 | lhs assign_operation unary_expression
                 ;

function_invoke: identifier '(' parameter_list ')'  {printf("invoking function %s\n", $2);}
               | identifier '(' ')'  {printf("invoking function %s\n", $1);}
               ;

parameter_list: parameter_list ',' parameter
              | parameter
              ;

parameter: sub_expression
         | STRING
         ;


    /// source  https : //www.gnu.org/software/bison/manual/html_node/Contextual-Precedence.html
arithmetic_expression: arithmetic_expression '+' arithmetic_expression
                     | arithmetic_expression '-' arithmetic_expression
                     | arithmetic_expression '*' arithmetic_expression
                     | arithmetic_expression '/' arithmetic_expression
                     | arithmetic_expression '%' arithmetic_expression
                     | '(' arithmetic_expression ')'
                     | '-' arithmetic_expression %prec UMINUS
                     | identifier 
                     | primitive_constants
                     ;
  
unary_expression: IDENTIFIER INC
               | IDENTIFIER DEC
               | INC IDENTIFIER
               | DEC IDENTIFIER
               ;

identifier: IDENTIFIER 
          ;

 
  
data_type: INT_TYPE
         | DOUBLE_TYPE
         | BOOL_TYPE
         | CHAR_TYPE
         | VOID
         ;

   
primitive_constants: INTEGER 
               | CHAR 
               | DOUBLE 
               ;

scan: SCAN '(' STRING ',' '&' IDENTIFIER ')' ';'
    ;

print: PRINT '(' STRING ')' ';'
     | PRINT '(' STRING ',' IDENTIFIER ')' ';'
     ;

lhs: identifier
   | array_indexing
   ;

array_indexing: identifier '[' array_index ']'
              | identifier '[' array_index ']' '[' array_index ']'
              ;

array_index:  primitive_constants
              | identifier
              ;

assign_operation:  '='
                | ADD_EQ
                | SUB_EQ
                | MULT_EQ
                | DIV_EQ
                ;




%%


int main(int argc, char *argv[]) {
    printf("\n\n********* Simple Programming Language Compiler ********* \n\n");

    yyin = fopen(argv[1], "r");

    yyparse();
    printf("\nNo errors in input file!\n");

    fclose(yyin);
    return 0;
}

int yyerror(char *s) {
    printf("Error in line: %d, with message %s at token: %s\n", yylineno, s, yytext);
    exit(0);
}