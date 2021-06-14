%{
#include <iostream>
#include <fstream>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "quadrables.hpp"
#include "symbolTable.hpp"

#include "lex.yy.c"


/* prototypes */
int yylex(void);
int yyerror(char *s);

//outputting logs:
std::ofstream myfile;

int noErrors=0;

//Label counts
int ifBlockCount = 0;
int ifCount =0;
int switchCount =0;
int caseCount =0;
int forCount =0;
int whileCount =0;
int doWhileCount =0;

bool fromElse =false;
int forEnd =0;
char *currentOperation = 0;
char *currentDeclarationID = 0;
int currentDataType;
int valueType;
int identifierType,lastIdentifierType=-1;
int firstOperandType, secondOperandType;
int regCount = 0;
int regNum = 0;
char currentIdentifier[32];
int isCurrentIdentifierInitialized = 0;
int tmpRegCount = 0;
// enum DataType {
//     TYPE_INT,
//     TYPE_DOUBLE,
//     TYPE_CHAR,
//     TYPE_VOID,
//     TYPE_BOOL
// };
int getArithmeticResultInt(int a, int b, std::string op);
double getArithmeticResultDouble(float a, float b, std::string op);
bool getArithmeticResultBool(bool a, bool b, std::string op);
bool getArithmeticResultBoolWithInt(int a, int b, std::string op);
bool getArithmeticResultBoolWithDouble(float a, float b, std::string op);

Node* createUnaryExpression(char* idName, char* op);
char* convertToCharArrayInt(int a); 
char* convertToCharArrayDouble(double a); 
Node *constantInt(int value);
Node *constantDouble(double value);
Node *constantChar(char value);
Node *constantString(char* value);
Node *constantBool(bool value);
Node *createIdentifier(char* i);
Node* evaluateExpression(std::string op, Node* operand1, Node* operand2);
bool getBoolExpr(std::string op);
void checkVarSemanticError(char *e);

%}

%union {
    int iVal;
    char cVal;
    char *idName;
    char *sVal;
    double dVal;
    bool bVal;
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
%token STRING_TYPE
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
%token SEMICOLON
%token LEFT_BRACE

// Operators
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
// %token<value> LEFT_ROUND '-' RIGHT_ROUND




%token<idName> IDENTIFIER
%token<iVal> INTEGER 
%token<dVal> DOUBLE 
%token<cVal> CHAR 
%token<bVal> BOOL
//%token<sVal> STRING

%type<node> identifier array_indexing
%token<node> ADD_EQ SUB_EQ MULT_EQ DIV_EQ INC DEC
%type<node> assign_operation
%type<node> unary_expression
%type<node> function_invoke
%type<node> primitive_constants
%type<node> declaration
%type<node> parameter_list_dec
%type<node> parameter_list
%type<node> parameter_dec
%type<node> parameter
%type<node> sub_declaration
%type<node> expression
%type<node> sub_expression
%type<node> arithmetic_expression 
%token<node> LEFT_ROUND '-' RIGHT_ROUND 

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




%nonassoc DECLAR
%nonassoc PRECEED_ELSE
%nonassoc ELSE
%nonassoc UMINUS
%nonassoc PRECEED_FUNC

%%



start: start line_stmt {printf("\n"); }
     | line_stmt  {printf("\n"); }
     | stmts
     ;
    
line_stmt: function 
         | declaration 
         ;

function: data_type IDENTIFIER LEFT_ROUND argument_list RIGHT_ROUND scope_stmt
        | data_type IDENTIFIER LEFT_ROUND argument_list RIGHT_ROUND SEMICOLON {printf("function definition\n");}
        ;

argument_list: arguments
             | 
             ;

arguments: arguments COMMA argument 
         | argument
         ;

argument: data_type identifier
        ;

scope_stmt: LEFT_BRACE {globalScope++; printf("[DEBUG] open scope at line %d\n", yylineno);} stmts '}' {printf("[DEBUG] close scope at line %d\n", yylineno);globalScope--;}
          ;
        
stmts: stmts stmt  
     | 
     ;

stmt: scope_stmt 
    | atomic_stmt
    ;

atomic_stmt: if_block                           {   
                                                    if(fromElse){
                                                        std::string s2="LF";
                                                        s2 += std::to_string(ifBlockCount);
                                                        char* tp2 = new char[10];
                                                        strcpy(tp2 ,s2.c_str());
                                                        insertQuad(NULL,NULL,"LABEL",tp2,forEnd);   
                                                        ifBlockCount++; 
                                                        fromElse = false;
                                                    }
                                                }
            | while_block                       {   
                                                    std::string s="LWLS";
                                                    s += std::to_string(whileCount);
                                                    char* tp = new char[10];
                                                    strcpy(tp ,s.c_str());
                                                    insertQuad(NULL,NULL,"JMP",tp,forEnd); 
                                                    std::string s2="LWLE";
                                                    s2 += std::to_string(whileCount);
                                                    char* tp2 = new char[10];
                                                    strcpy(tp2 ,s2.c_str());
                                                    insertQuad(NULL,NULL,"LABEL",tp2,forEnd);   
                                                    whileCount++; 
                                                
                                                }
            | for_block                         {   
                                                    std::string s="LFRS";
                                                    s += std::to_string(forCount);
                                                    char* tp = new char[10];
                                                    strcpy(tp ,s.c_str());
                                                    insertQuad(NULL,NULL,"JMP",tp,-1); 
                                                    std::string s2="LFRE";
                                                    s2 += std::to_string(forCount);
                                                    char* tp2 = new char[10];
                                                    strcpy(tp2 ,s2.c_str());
                                                    insertQuad(NULL,NULL,"LABEL",tp2,forEnd);   
                                                    forCount++; 
                                                }
            | switch_block                      {   
                                                    std::string s2="LSW";
                                                    s2 += std::to_string(switchCount);
                                                    char* tp2 = new char[10];
                                                    strcpy(tp2 ,s2.c_str());
                                                    insertQuad(NULL,NULL,"LABEL",tp2,forEnd);   
                                                    switchCount++; 
                                                }
            | do_while_block SEMICOLON          
            | case_block                        
            | declaration 
            | print 
            | scan 
            | function_invoke  
            | function_declaration  
            | RETURN SEMICOLON 
            | CONTINUE SEMICOLON 
            | BREAK SEMICOLON                               {printf("break:::\n");}
            | RETURN sub_expression SEMICOLON
            ;

declaration: data_type assign_expression SEMICOLON  %prec DECLAR        {
                                                                            //printf("id: %s\n",currentDeclarationID);
                                                                            if(!insert(currentDeclarationID,var,currentType,true))
                                                                                yyerror("Semantic Error: Already assigned..");
                                                                            // else 
                                                                            //     insertQuad();
                                                                        }
            | CONST data_type assign_expression SEMICOLON    {if(!insert(currentDeclarationID,constant,currentType,true))
                                                                    yyerror("Semantic Error: Already assigned..");
                                                            }
            | data_type declaration_list SEMICOLON                    
            | unary_expression SEMICOLON                    {checkVarSemanticError(currentDeclarationID);}
            | data_type IDENTIFIER SEMICOLON                {if(!insert(currentID,var,currentType,false))
                                                                    yyerror("Semantic Error: Already assigned..");
                                                            }
            | assign_expression SEMICOLON                   {
                                                                SymbolTableEntry *entry = getEntry(currentDeclarationID);
                                                                if(entry!=NULL){    
                                                                    if(entry->kind == constant)
                                                                        yyerror("Semantic Error: Re-assigning const");

                                                                    entry->initialized = true;
                                                                }
                                                            } 
            ;

declaration_list: declaration_list COMMA sub_declaration
                | sub_declaration 
                ;

sub_declaration: assign_expression                                      {
                                                                            if(!insert(currentDeclarationID,var,currentType,true))
                                                                                yyerror("Semantic Error: Already assigned..");
                                                                        } 
                | array_indexing
                ;

////IF
if_alone: IF LEFT_ROUND expression RIGHT_ROUND   {
                                                    std::string s="L";
                                                    s += std::to_string(ifCount);
                                                    char* tp = new char[10];
                                                    strcpy(tp ,s.c_str());
                                                    printf("type of cond of if: %d\n",$3->dataType);
                                                    if($3->dataType == TYPE_BOOL)
                                                        insertQuad($3->tmpName,NULL,"JZ",tp,forEnd);   
                                                    else 
                                                        yyerror("Semantic Error: Conditions MUST be of bool type");
                                                 } 
        ;  

if_stm: if_alone stmt               {
                                        std::string s="LF";
                                        s += std::to_string(ifBlockCount);
                                        char* tp = new char[10];
                                        strcpy(tp ,s.c_str());
                                        insertQuad(NULL,NULL,"JMP",tp,forEnd);
                                        std::string s2="L";
                                        s2 += std::to_string(ifCount);
                                        char* tp2 = new char[10];
                                        strcpy(tp2 ,s2.c_str());
                                        insertQuad(NULL,NULL,"LABEL",tp2,forEnd);  
                                        ifCount++;

                                    } 
        ;

if_block: if_stm %prec PRECEED_ELSE 
        | if_stm ELSE {fromElse=true;} stmt          
        ;

////FOR
for_block: FOR LEFT_ROUND for_init for_middle for_end RIGHT_ROUND stmt 
         ;

for_init: declaration               {
                                            std::string s2="LFRS";
                                            s2 += std::to_string(forCount);
                                            char* tp2 = new char[10];
                                            strcpy(tp2 ,s2.c_str());
                                            insertQuad(NULL,NULL,"LABEL",tp2,forEnd);
                                    }
        | SEMICOLON
        ;

for_middle: expression SEMICOLON {
                                    std::string s2="LFRE";
                                    s2 += std::to_string(forCount);
                                    char* tp2 = new char[10];
                                    strcpy(tp2 ,s2.c_str());
                                    if($1->dataType == TYPE_BOOL)
                                        insertQuad($1->tmpName,NULL,"JZ",tp2,forEnd); 
                                    else 
                                        yyerror("Semantic Error: Conditions MUST be of bool type");

                                    forEnd++;
                                 }
            | SEMICOLON
            ;

for_end: expression              {
                                    forEnd--;
                                 }
        | /*epsilon*/
        ;

////WHILE
while: WHILE            {
                            std::string s2="LWLS";
                            s2 += std::to_string(whileCount);
                            char* tp2 = new char[10];
                            strcpy(tp2 ,s2.c_str());
                            insertQuad(NULL,NULL,"LABEL",tp2,forEnd); 
                        }
;
while_stmt: while LEFT_ROUND expression RIGHT_ROUND {
                                                        std::string s2="LWLE";
                                                        s2 += std::to_string(whileCount);
                                                        char* tp2 = new char[10];
                                                        strcpy(tp2 ,s2.c_str());
                                                        if($3->dataType == TYPE_BOOL)
                                                            insertQuad($3->tmpName,NULL,"JZ",tp2,forEnd);   
                                                        else 
                                                            yyerror("Semantic Error: Conditions MUST be of bool type");
                                                    }
;

while_block:while_stmt stmt 
           ;        

////DO WHILE
do: DO                      {std::string s2="LDW";
                                s2 += std::to_string(doWhileCount);
                                char* tp2 = new char[10];
                                strcpy(tp2 ,s2.c_str());
                                insertQuad(NULL,NULL,"LABEL",tp2,forEnd);  
                            }
;
do_while_block: do stmt WHILE LEFT_ROUND expression RIGHT_ROUND     {   
                                                                        if($5->dataType == TYPE_BOOL)
                                                                                {
                                                                                    std::string s2="LDW";
                                                                                    s2 += std::to_string(doWhileCount);
                                                                                    char* tp2 = new char[10];
                                                                                    strcpy(tp2 ,s2.c_str());
                                                                                    printf("typosaasaads %d\n",$5->dataType);
                                                                                    insertQuad($5->tmpName,NULL,"JNZ",tp2,forEnd);   
                                                                                    doWhileCount++; 
                                                                                }
                                                                        else 
                                                                            yyerror("Semantic Error: Conditions MUST be of bool type");
                                                                    
                                                                    }
;

////SWITCH
switch_alone: SWITCH LEFT_ROUND expression RIGHT_ROUND          {if(!($3->dataType == TYPE_INT || $3->dataType == TYPE_BOOL || $3->dataType == TYPE_DOUBLE || $3->dataType == TYPE_CHAR))
                                                                    yyerror("Semantic Error: Switch Case must have PRIMITIVE constant!!");
                                                                }
            ;   

switch_block: switch_alone stmt   {printf("switch\n");}
            ;
case_alone: CASE expression ':'         {
                                            if($2->isPrimitiveConst)
                                                printf("yess i am a constsnt\n");

                                            printf("var= %s , gowa case = %s\n",currentID,$2->tmpName);
                                            Node * id = createIdentifier(currentID);
                                            Node * par= evaluateExpression("==", id, $2);
                                            insertQuad(currentID, $2->tmpName,"==",par->tmpName,forEnd);
                                            std::string s2="LCS";
                                            s2 += std::to_string(caseCount);
                                            char* tp2 = new char[10];
                                            strcpy(tp2 ,s2.c_str());
                                            insertQuad(par->tmpName,NULL,"JZ",tp2,forEnd);

                                        }
        ;
default_alone: DEFAULT ':'      
;
case_block: case_alone stmt             {   
                                            std::string s="LSW";
                                            s += std::to_string(switchCount);
                                            char* tp = new char[10];
                                            strcpy(tp ,s.c_str());
                                            insertQuad(NULL,NULL,"JMP",tp,forEnd); 
                                            std::string s2="LCS";
                                            s2 += std::to_string(caseCount);
                                            char* tp2 = new char[10];
                                            strcpy(tp2 ,s2.c_str());
                                            insertQuad(NULL,NULL,"LABEL",tp2,forEnd);  
                                            caseCount++; 
                                        }
          | default_alone stmt            {printf("default case\n");}
          ;

expression: expression COMMA sub_expression
          | sub_expression
          ;

sub_expression: arithmetic_expression
                | assign_expression
                | unary_expression      
                ;

assign_expression: identifier assign_operation arithmetic_expression {
                                                                        currentDeclarationID=$1->idName;
                                                                        identifierType = currentDataType;
                                                                        insertQuad($3->tmpName,NULL,"=",currentDeclarationID,forEnd);
                                                                        if ($1->dataType!= $3->dataType) {
                                                                            yyerror("Type mismatch");
                                                                        }
                                                                        
                                                                    }
                 | identifier assign_operation function_invoke      {
                                                                        // currentDeclarationID=$1->idName;
                                                                        // identifierType = currentDataType;
                                                                        // insertQuad($3->tmpName,NULL,"=",currentDeclarationID,forEnd);
                                                                        // if ($1->dataType!= $3->dataType) {
                                                                        //     yyerror("Type mismatch");
                                                                        // }
                                                                        
                                                                    }
                 | identifier assign_operation unary_expression      {
                                                                        currentDeclarationID=$1->idName;
                                                                        identifierType = currentDataType;
                                                                        insertQuad($3->tmpName,NULL,"=",currentDeclarationID,forEnd);
                                                                        if ($1->dataType!= $3->dataType) {
                                                                            yyerror("Type mismatch");
                                                                        }
                                                                        
                                                                    }

                 ;
////FUNCTIONS

function_declaration: data_type identifier LEFT_ROUND parameter_list_dec RIGHT_ROUND stmt                {
                                                                                                                    //printf("id: %s\n",currentDeclarationID);
                                                                                                                    if(!insert(currentDeclarationID,var,currentType,true))
                                                                                                                        yyerror("Semantic Error: Already assigned..");
                                                                                                                    // else 
                                                                                                                    //     insertQuad();
                                                                                                                }
;
parameter_list_dec: parameter_list_dec COMMA parameter_dec
              | parameter_dec                       {
                                                        printf("param =%s \n",$1->tmpName);
                                                    }
              ;

parameter_dec: data_type identifier             {$$ = createIdentifier($2->tmpName);}
            | /* */
         ;

function_invoke: identifier LEFT_ROUND parameter_list RIGHT_ROUND SEMICOLON 
               | identifier LEFT_ROUND RIGHT_ROUND SEMICOLON
               ;

parameter_list: parameter_list COMMA parameter
              | parameter                       {
                                                    printf("param =%s \n",$1->tmpName);
                                                }
              ;

parameter: sub_expression
         | STRING
         ;

  
    /// source  https : //www.gnu.org/software/bison/manual/html_node/Contextual-Precedence.html
arithmetic_expression: arithmetic_expression '+' arithmetic_expression {
                                                                        $$ = evaluateExpression("+", $1, $3);
                                                                        insertQuad($1->tmpName, $3->tmpName,"+",$$->tmpName,forEnd);
                                                                       }
                     | arithmetic_expression '-' arithmetic_expression {
                                                                        $$ = evaluateExpression("-", $1, $3);
                                                                        insertQuad($1->tmpName, $3->tmpName,"-",$$->tmpName,forEnd);
                                                                       }
                     | arithmetic_expression '*' arithmetic_expression {
                                                                        $$ = evaluateExpression("*", $1, $3);
                                                                        insertQuad($1->tmpName, $3->tmpName,"*",$$->tmpName,forEnd);
                                                                       }
                     | arithmetic_expression '/' arithmetic_expression {
                                                                        $$ = evaluateExpression("/", $1, $3);
                                                                        insertQuad($1->tmpName, $3->tmpName,"/",$$->tmpName,forEnd);
                                                                       }
                    | arithmetic_expression '%' arithmetic_expression 
                    | arithmetic_expression LOGIC_AND arithmetic_expression              {
                                                                        $$ = evaluateExpression("&&", $1, $3);
                                                                        insertQuad($1->tmpName, $3->tmpName,"&&",$$->tmpName,forEnd);
                                                                       }
                    | arithmetic_expression LOGIC_OR arithmetic_expression               {
                                                                        $$ = evaluateExpression("||", $1, $3);
                                                                        insertQuad($1->tmpName, $3->tmpName,"||",$$->tmpName,forEnd);
                                                                       }
                    | arithmetic_expression '>' arithmetic_expression  {
                                                                        $$ = evaluateExpression(">", $1, $3);
                                                                        insertQuad($1->tmpName, $3->tmpName,">",$$->tmpName,forEnd);
                                                                       }
                    | arithmetic_expression '<' arithmetic_expression {
                                                                        $$ = evaluateExpression("<", $1, $3);
                                                                        insertQuad($1->tmpName, $3->tmpName,"<",$$->tmpName,forEnd);
                                                                       }
                    | arithmetic_expression EQ arithmetic_expression  {
                                                                        $$ = evaluateExpression("==", $1, $3);
                                                                        insertQuad($1->tmpName, $3->tmpName,"==",$$->tmpName,forEnd);
                                                                       }
                    | arithmetic_expression NE arithmetic_expression  {
                                                                        $$ = evaluateExpression("!=", $1, $3);
                                                                        insertQuad($1->tmpName, $3->tmpName,"!=",$$->tmpName,forEnd);
                                                                       }
                    | arithmetic_expression LE arithmetic_expression    {
                                                                        $$ = evaluateExpression("<=", $1, $3);
                                                                        insertQuad($1->tmpName, $3->tmpName,"||",$$->tmpName,forEnd);
                                                                       }
                    | arithmetic_expression GE arithmetic_expression   {
                                                                        $$ = evaluateExpression(">=", $1, $3);
                                                                        insertQuad($1->tmpName, $3->tmpName,">=",$$->tmpName,forEnd);
                                                                       }
                    | arithmetic_expression SHR arithmetic_expression  
                    | arithmetic_expression SHL arithmetic_expression
                    | arithmetic_expression '^' arithmetic_expression
                    | arithmetic_expression '|' arithmetic_expression
                    | arithmetic_expression '&' arithmetic_expression
                    | '!' arithmetic_expression
                     | LEFT_ROUND arithmetic_expression RIGHT_ROUND
                     | '-' arithmetic_expression %prec UMINUS
                     | identifier                                       {
                                                                            checkVarSemanticError($1->idName);
                                                                        }
                     | primitive_constants   
                      
                     ;
  
unary_expression:  IDENTIFIER INC                   { $$ = createUnaryExpression(currentID, "++");}  
               | IDENTIFIER DEC                     { $$ = createUnaryExpression(currentID, "--");} 
               | INC IDENTIFIER                     { $$ = createUnaryExpression(currentID, "++");} 
               | DEC IDENTIFIER                     { $$ = createUnaryExpression(currentID, "--");} 
               ;

identifier: IDENTIFIER {        
                                
                                $$ = createIdentifier($1); 
                                // SymbolTableEntry *entry = getEntry($1);
                                // if(entry!=NULL)
                                //     lastIdentifierType=getDatatype(entry);
                                printf("IDENTIFIER NAME: %s\n", $1);
                        }
          ;


  
data_type: INT_TYPE         {currentDataType = TYPE_INT;}
         | DOUBLE_TYPE      {currentDataType = TYPE_DOUBLE;}
         | BOOL_TYPE        {currentDataType = TYPE_BOOL;}
         | CHAR_TYPE        {currentDataType = TYPE_CHAR;}
         | STRING_TYPE      {currentDataType = TYPE_STRING;}
         | VOID             {currentDataType = TYPE_VOID;}
         ;

   //values of integer, char, or double
primitive_constants: INTEGER    {$$ = constantInt($1); }
               | CHAR           {$$ = constantChar($1);}
               | DOUBLE         {$$ = constantDouble($1);}
               | STRING         
               | BOOL           {$$ = constantBool($1);}
               ;

scan: SCAN LEFT_ROUND STRING COMMA '&' IDENTIFIER RIGHT_ROUND SEMICOLON
    ;

print: PRINT LEFT_ROUND STRING RIGHT_ROUND SEMICOLON
     | PRINT LEFT_ROUND STRING COMMA IDENTIFIER RIGHT_ROUND SEMICOLON
     | PRINT LEFT_ROUND STRING COMMA primitive_constants RIGHT_ROUND SEMICOLON
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

assign_operation:  ASSIGN_OP        {currentOperation = "MOV";}
                | ADD_EQ            {currentOperation = "ADDEQ";}
                | SUB_EQ            {currentOperation = "SUBEQ";}
                | MULT_EQ           {currentOperation = "MULEQ";}
                | DIV_EQ            {currentOperation = "DIVEQ";}
                ;




%%

char* convertToCharArrayInt(int a) {
    char* buf = (char*)malloc(32); 
    snprintf(buf, sizeof(buf), "%d", a);
    return buf;
}
char* convertToCharArrayDouble(double a) {
    char* buf = (char*)malloc(32); 
    snprintf(buf, sizeof(buf), "%f", a);
    return buf;
}

int getArithmeticResultInt(int a, int b, std::string x) {
    
    int res = 0;
    
        if(x== "+")
            res = a + b;
        else if(x== "*")
            res = a * b;
        else if(x== "-")
            res = a - b;
        else if(x== "/"){
            if (b == 0) yyerror("Division by zero");
            res = a / b;
        }
        else
            printf("No operation");

    return res;
} 

double getArithmeticResultDouble(float a, float b, std::string x) {
    double res = 0.0;
    printf("a = %f   b = %f\n", a, b);
            if(x== "+")
            res = a + b;
        else if(x== "*")
            res = a * b;
        else if(x== "-")
            res = a - b;
        else if(x== "/"){
            if (b == 0) yyerror("Division by zero");
            res = a / b;
        }
        else
            printf("No operation");
    printf("RES::: %f\n", res);
    return res;
}
bool getArithmeticResultBool(bool a, bool b, std::string x) {

    bool res = false;
    if(x== "&&")
            res = a && b;
    else if(x== "||")
            res = a || b;
    else
            printf("No operation");
    return res;
}
bool getArithmeticResultBoolWithInt(int a, int b, std::string x) {

    bool res = false;
    if(x== ">")
            res = a > b;
    else if(x== "<")
            res = a < b;
    else if(x== ">=")
            res = a >= b;
    else if(x== "<=")
            res = a <= b;
    else if(x== "==")
            res = a == b;
    else if(x== "!=")
            res = a != b;
    else
            printf("No operation");
    return res;
}
bool getArithmeticResultBoolWithDouble(float a, float b, std::string x) {
    bool res = false;
    if(x== ">")
            res = a > b;
    else if(x== "<")
            res = a < b;
    else if(x== ">=")
            res = a >= b;
    else if(x== "<=")
            res = a <= b;
    else if(x== "==")
            res = a == b;
    else if(x== "!=")
            res = a != b;
    else
            printf("No operation");
    return res;
}

Node *constantInt(int value) {
    Node *p;

    /* allocate node */
    if ((p = (Node*)malloc(sizeof(Node))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->nodeType = NODE_CONST_VALUE;
    p->iVal = value;
    p->line_num = yylineno;
    p->dataType = TYPE_INT;
    p->isPrimitiveConst = true;
    p->tmpName = new char[10];
    strcpy(p->tmpName ,to_string(value).c_str());
    return p;
}

Node *constantDouble(double value) {
    Node *p;

    /* allocate node */
    if ((p = (Node*)malloc(sizeof(Node))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->nodeType = NODE_CONST_VALUE;
    p->dVal = value;
    p->line_num = yylineno;
    p->dataType = TYPE_DOUBLE;
    p->isPrimitiveConst = true;
    p->tmpName = new char[10];
    strcpy(p->tmpName ,to_string(value).c_str());
    return p;
}

Node *constantChar(char value) {
    Node *p;

    /* allocate node */
    if ((p = (Node*)malloc(sizeof(Node))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->nodeType = NODE_CONST_VALUE;
    p->cVal = value;
    p->line_num = yylineno;
    p->dataType = TYPE_CHAR;
    p->isPrimitiveConst = true;
    p->tmpName = new char[10];
    std::string s;
    s += value;
    //p->tmpName[0] = value;
    strcpy(p->tmpName ,s.c_str());
    return p;
}

// Node *constantString(char* value) {
//     Node *p;

//     /* allocate node */
//     if ((p = (Node*)malloc(sizeof(Node))) == NULL)
//         yyerror("out of memory");

//     /* copy information */
//     p->nodeType = NODE_CONST_VALUE;
//     p->sVal = new char[10];
//     strcpy(p->sVal ,to_string(value).c_str());
//     p->line_num = yylineno;
//     p->dataType = TYPE_STRING;
//     p->tmpName = new char[10];
//     strcpy(p->tmpName ,value);
//     return p;
// }

Node *constantBool(bool value) {
    Node *p;

    /* allocate node */
    if ((p = (Node*)malloc(sizeof(Node))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->nodeType = NODE_CONST_VALUE;
    p->bVal = value;
    p->line_num = yylineno;
    p->dataType = TYPE_BOOL;
    p->isPrimitiveConst = true;
    p->tmpName = new char[10];
    strcpy(p->tmpName ,to_string(value).c_str());
    return p;
}

Node *createIdentifier(char* i) {
    Node *p;

    /* allocate node */
    if ((p = (Node*)malloc(sizeof(Node))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->nodeType = NODE_ID;
    //strcpy(p->idName, i);
    p->idName = strdup(i);
    p->tmpName = p->idName;
    p->line_num = yylineno;
    SymbolTableEntry *entry = getEntry(p->idName);
    if(entry==NULL)
        p->dataType = getDataTypeInsert(currentType);
    else 
        p->dataType = entry->dataType;
    printf("currtype: %d\n",p->dataType);
    return p;
}

bool getBoolExpr(std::string op){
    return (op == ">" ||op == "<"||op == "=="||op == "!="||op == ">="||op == "<=");
}

Node* evaluateExpression(std::string op, Node* operand1, Node* operand2) {
    Node* res;
    if (operand1->dataType != operand2->dataType) {
        yyerror("Type mismatch");
    }

    if ((res = (Node*)malloc(sizeof(Node))) == NULL)
       yyerror("out of memory");

    std::string temp = "$t" + std::to_string(tmpRegCount);
    //res->tmpName = temp.c_str();
    tmpRegCount++;
    // assuming now that both are of the same type
    bool boolExpr = getBoolExpr(op);
    if (!boolExpr && operand1->dataType == TYPE_INT) {
        int tmp_res = getArithmeticResultInt(operand1->iVal, operand2->iVal, op);
        res->nodeType = NODE_CONST_VALUE;
        res->iVal = tmp_res;
        res->line_num = yylineno;
        res->dataType = TYPE_INT;
    } else if (!boolExpr && operand1->dataType == TYPE_DOUBLE) {
        double tmp_res = getArithmeticResultDouble(operand1->dVal, operand2->dVal, op);
        res->nodeType = NODE_CONST_VALUE;
        res->dVal = tmp_res;
        res->line_num = yylineno;
        res->dataType = TYPE_DOUBLE;
    
    } else if (operand1->dataType == TYPE_BOOL) {
        bool tmp_res = getArithmeticResultBool(operand1->bVal, operand2->bVal, op);
        res->nodeType = NODE_CONST_VALUE;
        res->bVal = tmp_res;
        res->line_num = yylineno;
        res->dataType = TYPE_BOOL;
    }
    else if (boolExpr && operand1->dataType == TYPE_INT) {
        bool tmp_res = getArithmeticResultBoolWithInt(operand1->bVal, operand2->bVal, op);
        res->nodeType = NODE_CONST_VALUE;
        res->bVal = tmp_res;
        res->line_num = yylineno;
        res->dataType = TYPE_BOOL;
    } else if (boolExpr && operand1->dataType == TYPE_DOUBLE) {
        bool tmp_res = getArithmeticResultBoolWithDouble(operand1->bVal, operand2->bVal, op);
        res->nodeType = NODE_CONST_VALUE;
        res->bVal = tmp_res;
        res->line_num = yylineno;
        res->dataType = TYPE_BOOL;
    } 
    
    //lastIdentifierType = res->dataType;
    res->tmpName = new char[10];
    strcpy(res->tmpName ,temp.c_str());
    return res;
}

Node* createUnaryExpression(char* idName, char* op) {
    Node* res;

    if ((res = (Node*)malloc(sizeof(Node))) == NULL)
        yyerror("out of memory");

    if (strcmp(currentType, "int") != 0 && strcmp(currentType, "double") != 0) {
    
        yyerror("Type mismatch. Cannot increment a non numeric token");
    }
    printf("ana geeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeet\n");
    res->idName = strdup(idName);
    // res->nodeType = NODE_POST_PRE;
    // res->post_pre_op = std::string(op);
    checkVarSemanticError(currentID);
    insertQuad(NULL, NULL,std::string(op) ,currentID,forEnd);
    return res;

}

void checkVarSemanticError(char *e){
    SymbolTableEntry *entry = getEntry(e);
    if(entry==NULL)
        yyerror("Semantic Error: Used before declared");
    else if (!getInitializationStatus(entry)) 
        yyerror("Semantic Error: Used before initialized"); 
}

int main(int argc, char *argv[]) {
    printf("\n\n********* Simple Programming Language Compiler ********* \n\n");
    clearSymbolTable();
    yyin = fopen(argv[1], "r");
    myfile.open("log.txt");
    yyparse();
    if(noErrors==0){
        printf("\nNo errors in input file!\n");
        printf("\nSymbol Table:\n");
        std::cout << printSymbolTable() <<std::endl;

        printf("\nQuadrables:\n");
        printQuadrables();
    }
    else {
        printf("\nFile has %d errors in log file!\n",noErrors);
    }
    myfile.close();
    fclose(yyin);
    return 0;
}

int yyerror(char *s) {
    printf("Error in line: %d, with message %s at token: %s\n", yylineno, s, yytext);
    noErrors++;
    myfile << "Error in line: "<< yylineno << ", with message "<< s << " at token: "<<yytext<<"\n";
}