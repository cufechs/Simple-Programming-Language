flex lexer.l 
bison -dy --verbose parser.y 
g++ -w -g symbolTable.hpp y.tab.c -ll -ly