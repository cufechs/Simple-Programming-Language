%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int multiline_comment_start = 0;
char currentType[32];
char currentID[32];
char currentValue[32]; //int,char,double,bool
char currentOp[10];
int globalScope = 0;





%}

%{
/////////////////////////////////////////////////////////
//                  Definitions                        //
/////////////////////////////////////////////////////////
%}

%option yylineno

LETTER              [a-zA-Z]
INTEGER             [0-9]+
DIGIT               [0-9]
WHITESPACE          [ \t\r\f\v]+
IDENTIFIER          (_|{LETTER})({LETTER}|{DIGIT}|_)*
DOUBLE              (([0-9]*\.[0-9]+)|([0-9]+\.[0-9]*))
EXP                 ([eE][-+]?{INTEGER})
REAL                ({INTEGER}{EXP}|{DOUBLE}{EXP}?)
 //COMMENT             "//"(.)*
  
%x COMMENT 


%%
    /* Operators */
[[\-+*/<>}:|&!^%\]]    { return *yytext;}
">="                         {//printf("Operator : %s\n", yytext); 
                                return  GE;}
"<="                         {//printf("Operator : %s\n", yytext);
                                return  LE;}
"=="                         {//printf("Operator : %s\n", yytext); 
                               return  EQ;}
"!="                         {//printf("Operator : %s\n", yytext); 
                               return  NE;}
"+="                         {
                                
                                yylval.op = strdup(yytext);
                                strcpy(currentOp, yylval.op);
                                return  ADD_EQ;}
"++"                         {
                                
                                yylval.op = strdup(yytext);
                                strcpy(currentOp, yylval.op);
                                return  INC;}
"--"                         {
                                
                                yylval.op = strdup(yytext);
                                strcpy(currentOp, yylval.op);
                                return  DEC;}
"-="                         {
                                
                                yylval.op = strdup(yytext);
                                strcpy(currentOp, yylval.op);
                                return  SUB_EQ;
                            }
"*="                         {
                                
                                yylval.op = strdup(yytext);
                                strcpy(currentOp, yylval.op);
                                return  MULT_EQ;
                            }
"/="                         {
                                
                                yylval.op = strdup(yytext);
                                strcpy(currentOp, yylval.op);
                                return  DIV_EQ;
                            }
"<<"                         {//printf("Operator : %s\n", yytext); 
                               return  SHL;}
">>"                         {//printf("Operator : %s\n", yytext);
                                return  SHR;}
"&&"                         {yylval.op = strdup(yytext);
                                strcpy(currentOp, yylval.op);
                                 return  LOGIC_AND;}
"||"                         { yylval.op = strdup(yytext);
                                strcpy(currentOp, yylval.op);
                                return  LOGIC_OR;}
"="                         {
                                
                                yylval.op = strdup(yytext);
                                strcpy(currentOp, yylval.op);
                                return ASSIGN_OP;
                            }
"{"                         {
                                return LEFT_BRACE;
                            }
"("                         {
                                return LEFT_ROUND;
                            }
")"                         {
                                return RIGHT_ROUND;
                            }


    /* Reserved Words */
"for"                       { return  FOR;}
"do"                        { return  DO;}
"while"                     { return  WHILE;}
"switch"                    { return  SWITCH;}
"case"                      { return  CASE;}
"default"                   { return  DEFAULT;}
"continue"                  { return  CONTINUE;}
"break"                     { return  BREAK;}
"return"                    { return  RETURN;}
"if"                        { return  IF;}
"else"                      { return  ELSE;}
"printf"                    { return  PRINT;}
"scanf"                     { return  SCAN;}
"const"                     { return CONST;}

";"                         {return SEMICOLON;}
","                         {return COMMA;}

    /* DataTypes and likes */
"void"                     {strcpy(currentType, yytext); return  VOID;}
"int"                      {strcpy(currentType, yytext); return INT_TYPE;}
"double"                   {strcpy(currentType, yytext); return DOUBLE_TYPE;}
"char"                     {strcpy(currentType, yytext); return CHAR_TYPE;}
"string"                   {strcpy(currentType, yytext); return STRING_TYPE;}
"bool"                     {strcpy(currentType, yytext);  return BOOL_TYPE;}

    /* Values of Types */
"true"                       {
                                //printf("bool value: %s\n", yytext); 
                                //yylval.value = strdup(yytext);
                                //strcpy(yylval.value, yytext);
                                yylval.bVal = true;
                                return BOOL;
                            }
"false"                      {  // printf("bool value: %s\n", yytext); 
                                //yylval.value = strdup(yytext);
                                yylval.bVal = false;
                                //strcpy(yylval.value, yytext);
                                return BOOL;
                            }
{IDENTIFIER}                 {
                                // printf("CurrentType: %s ", currentType);
                                // printf("Identifier: %s \n", yytext); 
                                yylval.idName = strdup(yytext);
                                strcpy(currentID, yylval.idName);
                                return IDENTIFIER;}
(\'.\')                      {
                                //printf("char value: %s\n", yytext);
                                yylval.cVal = yytext[1];
                                strcpy(currentValue, yytext);
                                //yylval.node->cVal = yytext[1];
                                return CHAR; }
{INTEGER}                    {
                                //printf("integer valueee: %s\n", yytext);
                                yylval.iVal = atoi(yytext);
                                //yylval.node->iVal = atoi(yytext);
                                //printf("integer valueee: %d\n", atoi(yytext));
                                //strcpy(currentValue, yytext);
                                //yylval.node->nodeType = NODE_CONST_VALUE;
                                //printf("[lexer]:: integer value: %d", yylval.node->iVal );
                                return INTEGER;
                            }
{REAL}                       {
                                //printf("double value: %s\n", yytext); 
                                strcpy(currentValue, yytext);
                                yylval.dVal = atof(yytext);
                                //yylval.node->dVal = atof(yytext);
                                return DOUBLE;}
{WHITESPACE}                 ;



"/*"                        {multiline_comment_start = yylineno; BEGIN COMMENT; //printf("multiline comment started at %d\n", yylineno);
                            }
<COMMENT>.|{WHITESPACE}     ;
<COMMENT>\n                 ;
<COMMENT>"*/"               {BEGIN INITIAL; printf("multiline comment ended at line %d\n", yylineno);}
<COMMENT><<EOF>>            {printf("Line %d multiline comment not terminated\n", multiline_comment_start); yyterminate();}             
"//".*                      {printf("single line comment at line %d\n", yylineno);}

\"[^\"\n]*\"                {
                                // printf("string value: %s\n", yytext); 
                                // strcpy(currentValue, yytext);
                                // strcpy(yylval.sVal, yytext);
                                return STRING;
                            }
\"[^\"\n]*$                 {printf("Line %d missing quatation for string %s\n", yylineno, yytext);}
{DIGIT}+({LETTER}|_)+       {printf("Line %d cannot start an identifier with a digit %s\n", yylineno, yytext);}
\n                          ;

.                          //{printf("Unrecognized token\n");}


%%

int yywrap(void) {
    return 1;
}
