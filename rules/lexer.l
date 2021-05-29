%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int multiline_comment_start = 0;
%}

%{
/////////////////////////////////////////////////////////
//                  Definitions        {LETTER|_}({LETTER}|{DIGIT}|_)*                 //
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
[[\-+*/()<>{}=,;:|&!^%\]]       return *yytext;
">="                         {printf("Operator : %s\n", yytext); return  GE;}
"<="                         {printf("Operator : %s\n", yytext); return  LE;}
"=="                         {printf("Operator : %s\n", yytext); return  EQ;}
"!="                         {printf("Operator : %s\n", yytext); return  NE;}
"++"                         {printf("Operator : %s\n", yytext); return  INC;}
"--"                         {printf("Operator : %s\n", yytext); return  DEC;}
"+="                         {printf("Operator : %s\n", yytext); return  ADD_EQ;}
"-="                         {printf("Operator : %s\n", yytext); return  SUB_EQ;}
"*="                         {printf("Operator : %s\n", yytext); return  MULT_EQ;}
"/="                         {printf("Operator : %s\n", yytext); return  DIV_EQ;}
"<<"                         {printf("Operator : %s\n", yytext); return  SHL;}
">>"                         {printf("Operator : %s\n", yytext); return  SHR;}
"&&"                         {printf("Operator : %s\n", yytext); return  LOGIC_AND;}
"||"                         {printf("Operator : %s\n", yytext); return  LOGIC_OR;}

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

    /* DataTypes and likes */
"void"                     {printf("datatype: %s\n", yytext); return  VOID;}
"int"                      {printf("datatype: %s\n", yytext);return INT_TYPE;}
"double"                   {printf("datatype: %s\n", yytext); return DOUBLE_TYPE;}
"char"                     {printf("datatype: %s\n", yytext); return CHAR_TYPE;}
"string"                   {printf("datatype: %s\n", yytext); return STRING_TYPE;}
"bool"                     {printf("datatype: %s\n", yytext); return BOOL_TYPE;}

    /* Values of Types */
"true"                     {printf("bool value: %s\n", yytext); return BOOL;}
"false"                     {printf("bool value: %s\n", yytext); return BOOL;}
{IDENTIFIER}                 {printf("Identifier: %s \n", yytext); return IDENTIFIER;}
(\'.\')                      {printf("char value: %s\n", yytext); return CHAR; }
{INTEGER}                    {printf("integer value: %s\n", yytext); return INTEGER;}
{REAL}                       {printf("double value: %s\n", yytext); return DOUBLE;}
{WHITESPACE}                 ;



"/*"                       {multiline_comment_start = yylineno; BEGIN COMMENT; printf("multiline comment started at %d\n", yylineno);}
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
