%{
#include <stdlib.h>
#include "y.tab.h"
void yyerror(char *);
%}

%{
/////////////////////////////////////////////////////////
//                  Definitions                        //
/////////////////////////////////////////////////////////
%}

LETTER              [a-zA-Z_]
DIGIT               [0-9]
IDENTIFIER          {LETTER}({LETTER}|{DIGIT})*
INTEGER             [0-9]+
DOUBLE              (([0-9]*\.[0-9]+)|([0-9]+\.[0-9]*))
EXP                 ([eE][-+]?{INTEGER})
REAL                ({INTEGER}{EXP}|{DOUBLE}{EXP}?)
COMMENT             "//"(.)*

%%
    /* Operators */
[-+*/()<>{}=,;:|&^%]        return *yytext;
">="                        return GE;
"<="                        return LE;
"=="                        return EQ;
"!="                        return NE;
"++"                        return INC;
"--"                        return DEC;
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
"print"                    return PRINT;
"const"                    return CONST;

    /* DataTypes and likes */
"void"                     return VOID;
"int"                      return INT_TYPE;
"double"                   return DOUBLE_TYPE;
"char"                     return CHAR_TYPE;
"bool"                     return BOOL_TYPE;

    /* Values of Types */
{IDENTIFIER}               return IDENTIFIER;
(\'.\')                    return CHAR;
{INTEGER}                  return INTEGER;
{REAL}                     return DOUBLE;
"true"                     return BOOL;
"false"                    return BOOL;


{COMMENT}     ;          /* ignore comment */
[ \t\n]+      ;          /* ignore whitespace */

.               yyerror("Unknown character");


%%

int yywrap(void) {
    return 1;
}
