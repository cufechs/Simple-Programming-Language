%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "lex.yy.c"
#include "symbolTable.hpp"
/* prototypes */
int yylex(void);
int yyerror(char *s);


char *currentOperation;
int currentDataType;
int valueType;
int identifierType;
int firstOperandType, secondOperandType;
int regCount = 0;
int regNum = 0;
char currentIdentifier[32];


int getArithmeticResultInt(int a, int b, char op);
double getArithmeticResultDouble(float a, float b, char op);
// char* convertToCharArrayInt(int a); 
// char* convertToCharArrayDouble(double a); 

%}

%union {
    int iVal;
    char cVal;
    char* idName;
    char *sVal;
    double dVal;
    char* op;
    char value[32]; //general value for int, double, bool, char 
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
// %token<iVal> INTEGER
// %token<dVal> DOUBLE
// %token<cVal> CHAR
// %token<value> BOOL
// %type<idName> identifier array_indexing
// %token<op> ADD_EQ SUB_EQ MULT_EQ DIV_EQ
// %type<op> assign_operation
// %type<value> arithmetic_expression primitive_constants 
// %token<value> '(' '-' ')'

%token<value> INTEGER IDENTIFIER
%token<value> DOUBLE
%token<value> CHAR
%token<value> BOOL
%type<value> identifier array_indexing
%token<value> ADD_EQ SUB_EQ MULT_EQ DIV_EQ
%type<value> assign_operation
%type<value> unary_expression
%type<value> sub_expression
%type<value> expression
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

scope_stmt: {printf("start of scope at line %d \n",yylineno);} '{' stmts '}' {printf("end of scope at line %d \n",yylineno);}
          ;
        
stmts: stmts stmt  
     | 
     ;

stmt: scope_stmt 
    | atomic_stmt
    ;

atomic_stmt: if_block 
            | while_block 
            | for_block 
            | switch_block 
            | do_while_block SEMICOLON 
            | case_block 
            | declaration 
            | print 
            | scan 
            | function_invoke SEMICOLON 
            | RETURN SEMICOLON 
            | CONTINUE SEMICOLON 
            | BREAK SEMICOLON 
            | RETURN sub_expression SEMICOLON
            ;

declaration: data_type declaration_list SEMICOLON  
            | CONST data_type declaration_list SEMICOLON   
            | declaration_list SEMICOLON 
            | unary_expression SEMICOLON 
            ;

declaration_list: declaration_list COMMA sub_declaration
                | sub_declaration
                ;

sub_declaration: assign_expression 
                | identifier
                | array_indexing
                ;

if_block: IF '(' expression ')' stmt %prec PRECEED_ELSE    
        | IF '(' expression ')' stmt ELSE stmt             
        ;

for_block: FOR '(' for_init for_middle for_end ')' stmt 
         ;

for_init: declaration 
        | SEMICOLON
        ;

for_middle: expression SEMICOLON 
            | SEMICOLON
            ;

for_end: expression
        | /*epsilon*/
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


expression: expression COMMA sub_expression
          | sub_expression
          ;

sub_expression: sub_expression '>' sub_expression
                | sub_expression '<' sub_expression
                | sub_expression EQ sub_expression          {printf("Compare %s == %s \n",$1,$3);}
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

assign_expression: identifier assign_operation arithmetic_expression {
                                                                identifierType = currentDataType; 
                                                                printf("IDENTIFIER: %s ",$1); 
                                                                
                                                                printf("Assign operation: %s ", $2); 
                                                                printf("Value: %s\n", $3);

                                                                //insert();
                                                            }
                 | identifier assign_operation function_invoke
                 | identifier assign_operation unary_expression
                 ;

function_invoke: identifier '(' parameter_list ')'  {printf("Function invoke\n");}
               | identifier '(' ')'                 {printf("Function invoke\n");}
               ;

parameter_list: parameter_list COMMA parameter
              | parameter
              ;

parameter: sub_expression
         | STRING
         ;

  
    /// source  https : //www.gnu.org/software/bison/manual/html_node/Contextual-Precedence.html
arithmetic_expression: arithmetic_expression '+' arithmetic_expression {
                                                                        //printf("Arithmetic +: %s + %s\n", $1, $3);
                                                                        if (currentDataType == TYPE_INT) {
                                                                            strcpy($$, to_string(getArithmeticResultInt(atoi($1), atoi($3), '+')).c_str());
                                                                        } else {
                                                                            strcpy($$, to_string(getArithmeticResultDouble((float)atof($1), (float)atof($3), '+')).c_str());
                                                                        }
                                                                        printf("result of addition : %s\n", $$);
                                                                        }
                     | arithmetic_expression '-' arithmetic_expression 
                     | arithmetic_expression '*' arithmetic_expression {
                                                                        //printf("Arithmetic *: %s * %s\n", $1, $3);
                                                                        if (currentDataType == TYPE_INT) {
                                                                            strcpy($$, to_string(getArithmeticResultInt(atoi($1), atoi($3), '*')).c_str());
                                                                        } else {
                                                                            strcpy($$, to_string(getArithmeticResultDouble((float)atof($1), (float)atof($3), '*')).c_str());
                                                                        }
                                                                        printf("result of multiplication : %s\n", $$);
                                                                        }
                     | arithmetic_expression '/' arithmetic_expression
                     | arithmetic_expression '%' arithmetic_expression 
                     | '(' arithmetic_expression ')'
                     | '-' arithmetic_expression %prec UMINUS
                     | identifier 
                     | primitive_constants                              {/*printf("Arithmetic : %s\n", $1);*/}
                     ;
  
unary_expression: IDENTIFIER INC  //{printf("POST INCREMENT\n");}
               | IDENTIFIER DEC   //{printf("POST DECREMENT\n");}
               | INC IDENTIFIER   //{printf("PRE INCREMENT\n");}
               | DEC IDENTIFIER   //{printf("PRE DECREMENT\n");}
               ;

identifier: IDENTIFIER {/*printf("IDENTIFIER NAME: %s\n", $1);*/}
          ;


  
data_type: INT_TYPE         {currentDataType = TYPE_INT;}
         | DOUBLE_TYPE      {currentDataType = TYPE_DOUBLE;}
         | BOOL_TYPE        {currentDataType = TYPE_BOOL;}
         | CHAR_TYPE        {currentDataType = TYPE_CHAR;}
         | VOID             {currentDataType = TYPE_VOID;}
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

// lhs: IDENTIFIER 
//    | array_indexing
//    ;

array_indexing: identifier '[' array_index ']' 
              | identifier '[' array_index ']' '[' array_index ']'
              ;

array_index:  primitive_constants
              | identifier
              ;

assign_operation: ASSIGN_OP         {currentOperation = "MOV";}
                | ADD_EQ            {currentOperation = "ADDEQ";}
                | SUB_EQ            {currentOperation = "SUBEQ";}
                | MULT_EQ           {currentOperation = "MULEQ";}
                | DIV_EQ            {currentOperation = "DIVEQ";}
                ;




%%

/*char* convertToCharArrayInt(int a) {
    char* buf = malloc(32); 
    snprintf(buf, sizeof(buf), "%d", a);
    return buf;
}
char* convertToCharArrayDouble(double a) {
    char* buf = malloc(32); 
    snprintf(buf, sizeof(buf), "%f", a);
    return buf;
}*/

int getArithmeticResultInt(int a, int b, char op) {
    int res = 0;
    
    switch(op) {
        case '*':
            res = a * b;
            break;
        case '+':
            res = a + b;
            break;
        default:
            printf("No operation");
            break;
    }
    return res;
} 

double getArithmeticResultDouble(float a, float b, char op) {
    double res = 0.0;
    printf("a = %f   b = %f\n", a, b);
    switch(op) {
        case '*':
            res = a * b;
            break;
        case '+':
            res = a + b;
            break;
        default:
            printf("No operation");
            break;
    }
    printf("RES::: %f\n", res);
    return res;
}


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