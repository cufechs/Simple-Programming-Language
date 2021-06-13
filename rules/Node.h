#include "utils.h"
#include <string>

#define MAX_ID_LENGTH 32


enum NodeType {
    NODE_ID, //identifier 
    NODE_CONST_VALUE, //int, double, number
    NODE_OP, //operation
    NODE_POST_PRE, //preincrment/decrement and postincrement/decrement
    NODE_CONDITIONAL, // if, else if, else
    NODE_EXPRESSION
};

typedef struct ExpressionNode {

}ExpressionNode;

typedef struct Node {
    // values
    union {
        int iVal; 
        double dVal; 
        char cVal; 
        char *idName;
    };
    char* value;
    char* name;
    int scope; 
    int initialized;
    int line_num;
    enum DataType dataType;
    enum NodeType nodeType;

    std::string tmpName;
    std::string assemblyCode;
    std::string post_pre_op;

}Node;