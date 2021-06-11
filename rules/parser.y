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

%union {
    int iVal;
    char cVal;
    char* idName;
    char *sVal;
    double dVal;
    char* op;
    char *value; //general value for int, double, bool, char 
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
%token WHILE
%token DO
%token BREAK
%token CONTINUE
%token RETURN
%token PRINT
%token SCAN
%token STRING
%token WHITESPACE
%token STRING_TYPE
%token SEMICOLON

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
%token<value> INTEGER
%token<value> DOUBLE
%token<value> CHAR
%token<value> BOOL
// %token<idName> IDENTIFIER
// %type<idName> lhs identifier array_indexing
%token<idName> IDENTIFIER 
%type<value> lhs identifier array_indexing
%token<op> ADD_EQ SUB_EQ MULT_EQ DIV_EQ
%type<op> assign_operation
%type<value> arithmetic_expression primitive_constants 
%token<value> '(' '-' ')'

// Order matters here:
%right<op>  ASSIGN_OP
%left       COMMA
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





%nonassoc PRECEED_ELSE
%nonassoc ELSE
%nonassoc UMINUS
%nonassoc PRECEED_FUNC

%%



start: start line_stmt {printf("\n"); }
     | line_stmt  {printf("\n"); }
     ;
    
line_stmt: function 
         | declaration 
         ;

function: data_type IDENTIFIER '(' argument_list ')' scope_stmt
        | data_type IDENTIFIER '(' argument_list ')' SEMICOLON {printf("function definition\n");}
        ;

argument_list: arguments
             | 
             ;

arguments: arguments COMMA argument 
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

atomic_stmt: if_block | while_block | for_block 
    | switch_block 
    | do_while_block SEMICOLON 
    | case_block | declaration | print 
    | scan | function_invoke SEMICOLON | RETURN SEMICOLON | CONTINUE SEMICOLON 
    | BREAK SEMICOLON | RETURN sub_expression SEMICOLON
    ;

declaration: data_type declaration_list SEMICOLON  
            | CONST data_type declaration_list SEMICOLON   
            | declaration_list SEMICOLON | unary_expression SEMICOLON 
            ;

declaration_list: declaration_list COMMA sub_declaration
                | sub_declaration
                ;

sub_declaration: assign_expression 
                | identifier
                | array_indexing
                ;

if_block: IF '(' expression ')' stmt %prec PRECEED_ELSE | IF '(' expression ')' stmt ELSE stmt 
        ;

for_block: FOR '(' expression_statement expression_statement ')' stmt 
         | FOR '(' expression_statement expression_statement expression_statement ')' stmt 
         ;

while_block: WHILE '(' expression ')' stmt 
           ;        

do_while_block: DO stmt WHILE '(' expression ')'
                ;

switch_block: SWITCH '(' expression ')' stmt   {printf("switch\n");}
            ;

case_block: CASE expression ':' stmt   {printf("case\n");}
          | DEFAULT ':' stmt            {printf("default case\n");}
          ;

expression_statement: expression SEMICOLON
          | SEMICOLON
          ;

expression: expression COMMA sub_expression
          | sub_expression
          ;

sub_expression: sub_expression '>' sub_expression
                | sub_expression '<' sub_expression
                | sub_expression EQ sub_expression
                | sub_expression NE sub_expression
                | sub_expression LE sub_expression
                | sub_expression GE sub_expression
                | sub_expression SHR sub_expression
                | sub_expression SHL sub_expression
                | sub_expression '^' sub_expression
                | sub_expression '|' sub_expression
                | sub_expression '&' sub_expression
                | sub_expression LOGIC_AND sub_expression
                | sub_expression LOGIC_OR sub_expression
                | '!' sub_expression
                | arithmetic_expression
                | assign_expression
                | unary_expression 
                ;

assign_expression: lhs assign_operation arithmetic_expression {printf("IDENTIFIER: %s ",$1); printf("Assign operation: %s ", $2); printf("Value: %s\n", $2);}
                 | lhs assign_operation array_indexing
                 | lhs assign_operation function_invoke
                 | lhs assign_operation unary_expression
                 ;

function_invoke: identifier '(' parameter_list ')'  
               | identifier '(' ')'  
               ;

parameter_list: parameter_list COMMA parameter
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
  
unary_expression: IDENTIFIER INC  {printf("POST INCREMENT\n");}
               | IDENTIFIER DEC   {printf("POST DECREMENT\n");}
               | INC IDENTIFIER   {printf("PRE INCREMENT\n");}
               | DEC IDENTIFIER   {printf("PRE DECREMENT\n");}
               ;

identifier: IDENTIFIER {printf("IDENTIFIER NAME: %s\n", $1);}
          ;


  
data_type: INT_TYPE
         | DOUBLE_TYPE
         | BOOL_TYPE
         | CHAR_TYPE
         | VOID
         ;

   //values of integer, char, or double
primitive_constants: INTEGER 
               | CHAR           {printf("CHAR VALUE: %c\n", $1);}
               | DOUBLE 
               | BOOL
               ;

scan: SCAN '(' STRING COMMA '&' IDENTIFIER ')' SEMICOLON
    ;

print: PRINT '(' STRING ')' SEMICOLON
     | PRINT '(' STRING COMMA IDENTIFIER ')' SEMICOLON
     | PRINT '(' STRING COMMA primitive_constants ')' SEMICOLON
     ;

lhs: identifier
   | array_indexing
   ;

array_indexing: identifier '[' array_index ']'  {printf("array***********************\n");}
              | identifier '[' array_index ']' '[' array_index ']'
              ;

array_index:  primitive_constants
              | identifier
              ;

assign_operation:  ASSIGN_OP
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