#!/bin/bash

bison --yacc rules/parser.y -d
flex rules/lexer.l
gcc y.tab.c lex.yy.c
./a.exe
