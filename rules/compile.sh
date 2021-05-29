bison -dy parser.y --verbose 
flex lexer.l
gcc -w -g y.tab.c -ly -ll