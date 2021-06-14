#ifndef __UTILS_H_
#define __UTILS_H_

enum SymbolKind
{
    constant, //const int M
    var,      //int x
    func,     //void main
    param,    //int par
};
enum DataType
{
    TYPE_INT = 10,
    TYPE_DOUBLE,
    TYPE_CHAR,
    TYPE_VOID,
    TYPE_BOOL,
    TYPE_STRING,
};

#endif