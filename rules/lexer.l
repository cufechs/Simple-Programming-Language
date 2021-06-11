%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int multiline_comment_start = 0;
char currentType[32];
char currentID[32];
char currentValue[32]; //int,char,double,bool
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
[[\-+*/()<>{}:|&!^%\]]    {printf("Operator : %s\n", yytext); return *yytext;}
">="                         {printf("Operator : %s\n", yytext); return  GE;}
"<="                         {printf("Operator : %s\n", yytext); return  LE;}
"=="                         {printf("Operator : %s\n", yytext); return  EQ;}
"!="                         {printf("Operator : %s\n", yytext); return  NE;}
"++"                         {printf("Operator : %s\n", yytext); return  INC;}
"--"                         {printf("Operator : %s\n", yytext); return  DEC;}
"+="                         {
                                printf("Operator : %s\n", yytext); 
                                yylval.op = strdup(yytext);
                                return  ADD_EQ;}
"-="                         {
                                printf("Operator : %s\n", yytext); 
                                yylval.op = strdup(yytext);
                                return  SUB_EQ;
                            }
"*="                         {
                                printf("Operator : %s\n", yytext); 
                                yylval.op = strdup(yytext);
                                return  MULT_EQ;
                            }
"/="                         {
                                printf("Operator : %s\n", yytext); 
                                yylval.op = strdup(yytext);
                                return  DIV_EQ;
                            }
"<<"                         {printf("Operator : %s\n", yytext); return  SHL;}
">>"                         {printf("Operator : %s\n", yytext); return  SHR;}
"&&"                         {printf("Operator : %s\n", yytext); return  LOGIC_AND;}
"||"                         {printf("Operator : %s\n", yytext); return  LOGIC_OR;}
"="                         {
                                printf("Operator: %s\n", yytext);
                                yylval.op = strdup(yytext);
                                return ASSIGN_OP;
                            }

    /* Reserved Words */
"for"                       {printf("Reserved word: %s\n", yytext); return  FOR;}
"do"                        {printf("Reserved word: %s\n", yytext); return  DO;}
"while"                     {printf("Reserved word: %s\n", yytext); return  WHILE;}
"switch"                    {printf("Reserved word: %s\n", yytext); return  SWITCH;}
"case"                      {printf("Reserved word: %s\n", yytext); return  CASE;}
"default"                   {printf("Reserved word: %s\n", yytext); return  DEFAULT;}
"continue"                  {printf("Reserved word: %s\n", yytext); return  CONTINUE;}
"break"                     {printf("Reserved word: %s\n", yytext); return  BREAK;}
"return"                    {printf("Reserved word: %s\n", yytext); return  RETURN;}
"if"                        {printf("Reserved word: %s\n", yytext); return  IF;}
"else"                      {printf("Reserved word: %s\n", yytext); return  ELSE;}
"printf"                    {printf("Reserved word: %s\n", yytext); return  PRINT;}
"scanf"                     {printf("Reserved word: %s\n", yytext); return  SCAN;}
"const"                     {printf("Reserved word: %s\n", yytext); return CONST;}

";"                         {printf("Line ended***************\n"); return SEMICOLON;}
","                         {return COMMA;}

    /* DataTypes and likes */
"void"                     {strcpy(currentType, yytext); printf("datatype: %s\n", yytext); return  VOID;}
"int"                      {strcpy(currentType, yytext); printf("datatype: %s\n", yytext);return INT_TYPE;}
"double"                   {strcpy(currentType, yytext); printf("datatype: %s\n", yytext); return DOUBLE_TYPE;}
"char"                     {strcpy(currentType, yytext); printf("datatype: %s\n", yytext); return CHAR_TYPE;}
"string"                   {strcpy(currentType, yytext); printf("datatype: %s\n", yytext); return STRING_TYPE;}
"bool"                     {strcpy(currentType, yytext); printf("datatype: %s\n", yytext); return BOOL_TYPE;}

    /* Values of Types */
"true"                       {
                                printf("bool value: %s\n", yytext); 
                                yylval.value = strdup(yytext);
                                return BOOL;
                            }
"false"                      {printf("bool value: %s\n", yytext); return BOOL;}
{IDENTIFIER}                 {
                                printf("CurrentType: %s ", currentType);
                                printf("Identifier: %s \n", yytext); 
                                yylval.idName = strdup(yytext);
                                strcpy(currentID, yylval.idName);
                                return IDENTIFIER;}
(\'.\')                      {
                                printf("char value: %s\n", yytext);
                                yylval.cVal = yytext[1];
                                strcpy(currentValue, yytext);
                                return CHAR; }
{INTEGER}                    {
                                printf("integer value: %s\n", yytext);
                                yylval.value = atoi(yytext);
                                strcpy(currentValue, yytext);
                                return INTEGER;}
{REAL}                       {
                                printf("double value: %s\n", yytext); 
                                yylval.dVal = atof(yytext);
                                strcpy(currentValue, yytext);
                                return DOUBLE;}
{WHITESPACE}                 ;



"/*"                        {multiline_comment_start = yylineno; BEGIN COMMENT; printf("multiline comment started at %d\n", yylineno);}
<COMMENT>.|{WHITESPACE}     ;
<COMMENT>\n                 ;
<COMMENT>"*/"               {BEGIN INITIAL; printf("multiline comment ended at line %d\n", yylineno);}
<COMMENT><<EOF>>            {printf("Line %d multiline comment not terminated\n", multiline_comment_start); yyterminate();}             
"//".*                      {printf("single line comment at line %d\n", yylineno);}

\"[^\"\n]*\"                return STRING;
\"[^\"\n]*$                 {printf("Line %d missing quatation for string %s\n", yylineno, yytext);}
{DIGIT}+({LETTER}|_)+       {printf("Line %d cannot start an identifier with a digit %s\n", yylineno, yytext);}
\n                          ;

.                          {printf("Unrecognized %s\n", yytext); return yytext;}


%%

int yywrap(void) {
    return 1;
}
