%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int multiline_comment_start = 0;
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
[-+*/()<>{}=,;:|&!^%]       return *yytext;
">="                        return GE;
"<="                        return LE;
"=="                        return EQ;
"!="                        return NE;
"++"                        return INC;
"--"                        return DEC;
"+="                        return ADD_EQ;
"-="                        return SUB_EQ;
"*="                        return MULT_EQ;
"/="                        return DIV_EQ;
"<<"                        return SHL;
">>"                        return SHR;
"&&"                        return LOGIC_AND;
"||"                        return LOGIC_OR;

    /* Reserved Words */
"for"                      return FOR;
"while"                    return WHILE;
"until"                    return UNTIL;
"switch"                   return SWITCH;
"case"                     return CASE;
"default"                  return DEFAULT;
"continue"                 return CONTINUE;
"break"                    return BREAK;
"return"                   return RETURN;
"if"                       return IF;
"else"                     return ELSE;
"printf"                    return PRINT;
"scanf"                     return SCAN;
"const"                    return CONST;

    /* DataTypes and likes */
"void"                     return VOID;
"int"                      {printf("datatype: %s\n", yytext);return INT_TYPE;}
"double"                   {printf("datatype: %s\n", yytext); return DOUBLE_TYPE;}
"char"                     {printf("datatype: %s\n", yytext); return CHAR_TYPE;}
"bool"                     {printf("datatype: %s\n", yytext); return BOOL_TYPE;}

    /* Values of Types */
{"true" || "false" }          {printf("bool value: %s \n", yytext); return BOOL;}
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
