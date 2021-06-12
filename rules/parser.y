%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "Node.h"

#include "lex.yy.c"


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

// enum DataType {
//     TYPE_INT,
//     TYPE_DOUBLE,
//     TYPE_CHAR,
//     TYPE_VOID,
//     TYPE_BOOL
// };
int getArithmeticResultInt(int a, int b, char op);
double getArithmeticResultDouble(float a, float b, char op);
char* convertToCharArrayInt(int a); 
char* convertToCharArrayDouble(double a); 
Node *constantInt(int value);
Node *constantDouble(double value);
Node *createIdentifier(char* i);
Node* evaluateExpression(char op, Node* operand1, Node* operand2);

%}

%union {
    int iVal;
    char cVal;
    char *idName;
    char *sVal;
    double dVal;
    char* op;
    char value[32]; //general value for int, double, bool, char 
    Node *node;
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




%token<idName> IDENTIFIER
%token<iVal> INTEGER 
%token<dVal> DOUBLE 
%token<cVal> CHAR 
%token<node> BOOL
%type<node> identifier array_indexing
%token<node> ADD_EQ SUB_EQ MULT_EQ DIV_EQ
%type<node> assign_operation
%type<node> arithmetic_expression  primitive_constants
%token<node> '(' '-' ')'

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

assign_expression: identifier assign_operation arithmetic_expression {
                                                                identifierType = currentDataType; 
                                                                printf("IDENTIFIER: %s ",$1->idName); 
                                                                printf("Assign operation: %s ", $2); 
                                                                printf("Value: %s\n", $3);
                                                            }
                 | identifier assign_operation function_invoke
                 | identifier assign_operation unary_expression
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
arithmetic_expression: arithmetic_expression '+' arithmetic_expression {
                                                                        $$ = evaluateExpression('+', $1, $3);
                                                                        printf("Arithmetic :+: %d + %d \n", $1->iVal, $3->iVal);
                                                                       }
                     | arithmetic_expression '-' arithmetic_expression {
                                                                        $$ = evaluateExpression('-', $1, $3);
                                                                        printf("Arithmetic :-: %d - %d \n", $1->iVal, $3->iVal);
                                                                        printf("[DEBUG] Final result :  %d\n", $$->iVal);
                                                                       }
                     | arithmetic_expression '*' arithmetic_expression {
                                                                        $$ = evaluateExpression('*', $1, $3);
                                                                        printf("Arithmetic :*: %d * %d \n", $1->iVal, $3->iVal);
                                                                       }
                     | arithmetic_expression '/' arithmetic_expression {
                                                                        $$ = evaluateExpression('/', $1, $3);
                                                                        printf("Arithmetic :/: %d / %d \n", $1->iVal, $3->iVal);
                                                                       }
                     | arithmetic_expression '%' arithmetic_expression 
                     | '(' arithmetic_expression ')'
                     | '-' arithmetic_expression %prec UMINUS
                     | identifier 
                     | primitive_constants                              {
                                                                        printf("Arithmetic : %d\n", $1->iVal);
                                                                        }
                     ;
  
unary_expression: IDENTIFIER INC  {printf("POST INCREMENT\n");}
               | IDENTIFIER DEC   {printf("POST DECREMENT\n");}
               | INC IDENTIFIER   {printf("PRE INCREMENT\n");}
               | DEC IDENTIFIER   {printf("PRE DECREMENT\n");}
               ;

identifier: IDENTIFIER {$$ = createIdentifier($1); printf("IDENTIFIER NAME: %s\n", $1);}
          ;


  
data_type: INT_TYPE         {currentDataType = TYPE_INT;}
         | DOUBLE_TYPE      {currentDataType = TYPE_DOUBLE;}
         | BOOL_TYPE        {currentDataType = TYPE_BOOL;}
         | CHAR_TYPE        {currentDataType = TYPE_CHAR;}
         | VOID             {currentDataType = TYPE_VOID;}
         ;

   //values of integer, char, or double
primitive_constants: INTEGER    {$$ = constantInt($1); }
               | CHAR           {printf("CHAR VALUE : %c\n", $1);}
               | DOUBLE         {$$ = constantDouble($1);}
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

array_indexing: identifier '[' array_index ']'  {printf("array***********************\n");}
              | identifier '[' array_index ']' '[' array_index ']'
              ;

array_index:  primitive_constants
              | identifier
              ;

assign_operation:  ASSIGN_OP        {currentOperation = "MOV";}
                | ADD_EQ            {currentOperation = "ADDEQ";}
                | SUB_EQ            {currentOperation = "SUBEQ";}
                | MULT_EQ           {currentOperation = "MULEQ";}
                | DIV_EQ            {currentOperation = "DIVEQ";}
                ;




%%

char* convertToCharArrayInt(int a) {
    char* buf = malloc(32); 
    snprintf(buf, sizeof(buf), "%d", a);
    return buf;
}
char* convertToCharArrayDouble(double a) {
    char* buf = malloc(32); 
    snprintf(buf, sizeof(buf), "%f", a);
    return buf;
}

int getArithmeticResultInt(int a, int b, char op) {
    int res = 0;
    
    switch(op) {
        case '+':
            res = a + b;
            break;
        case '*':
            res = a * b;
            break;
        case '-':
            res = a - b;
            break;
        case '/':
            if (b == 0) yyerror("Division by zero");
            res = a / b;
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
        case '-':
            res = a - b;
            break;
        case '/':
            if (b == 0.0) yyerror("Division by zero");
            res = a / b;
            break;
        default:
            printf("No operation");
            break;
    }
    printf("RES::: %f\n", res);
    return res;
}

Node *constantInt(int value) {
    Node *p;

    /* allocate node */
    if ((p = malloc(sizeof(Node))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->nodeType = NODE_CONST_VALUE;
    p->iVal = value;
    p->line_num = yylineno;
    p->dataType = TYPE_INT;
    return p;
}

Node *constantDouble(double value) {
    Node *p;

    /* allocate node */
    if ((p = malloc(sizeof(Node))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->nodeType = NODE_CONST_VALUE;
    p->dVal = value;
    p->line_num = yylineno;
    p->dataType = TYPE_DOUBLE;

    return p;
}

Node *createIdentifier(char* i) {
    Node *p;

    /* allocate node */
    if ((p = malloc(sizeof(Node))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->nodeType = NODE_ID;
    //strcpy(p->idName, i);
    p->idName = strdup(i);
    p->line_num = yylineno;

    return p;
}

Node* evaluateExpression(char op, Node* operand1, Node* operand2) {
    Node* res;

    if (operand1->dataType != operand2->dataType) {
        yyerror("Type mismatch");
    }

    if ((res = malloc(sizeof(Node))) == NULL)
        yyerror("out of memory");

    // assuming now that both are of the same type
    if (operand1->dataType == TYPE_INT) {
        int tmp_res = getArithmeticResultInt(operand1->iVal, operand2->iVal, op);
        res->nodeType = NODE_CONST_VALUE;
        res->iVal = tmp_res;
        res->line_num = yylineno;
        res->dataType = TYPE_INT;
    } else if (operand1->dataType == TYPE_DOUBLE) {
        double tmp_res = getArithmeticResultDouble(operand1->dVal, operand2->dVal, op);
        res->nodeType = NODE_CONST_VALUE;
        res->dVal = tmp_res;
        res->line_num = yylineno;
        res->dataType = TYPE_DOUBLE;
    }

    return res;
}

Node *operation(char op, Node* operand1, Node* operand2) {
    Node* p;

    // check if operand1 and operand2 are iniialized
    // check if operand1 and operand2 are of type NODE_ID or NODE_CONST_VALUE
    if (operand1->nodeType == NODE_CONST_VALUE && operand2->nodeType == NODE_CONST_VALUE) {

    } else if (operand1->nodeType == NODE_CONST_VALUE && operand2->nodeType == NODE_ID) {

    } else if (operand1->nodeType == NODE_ID && operand2->nodeType == NODE_CONST_VALUE) {

    }
    switch(op) {
        case '+':

            break;
        case '-':

            break;
        case '*':

            break;
        case '/':

            break;
        default:
            printf("%c operation is not supported\n", op);
    }

    /* allocate node, extending op array */
    // if ((p = malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) == NULL)
    //     yyerror("out of memory");


    return p;
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