#include "utils.h"
#include <string>

#define MAX_ID_LENGTH 32

enum NodeType
{
    NODE_ID,          //identifier
    NODE_CONST_VALUE, //int, double, number
    NODE_OP,          //operation
};

typedef struct Node
{
    // values
    union
    {
        int iVal;
        bool bVal;
        char cVal;
        double dVal;
        char *sVal;
        char *idName;
    };
    char *value;
    char *name;
    int scope;
    int initialized;
    bool isPrimitiveConst = false;
    int line_num;
    char *tmpName;
    enum DataType dataType;
    enum NodeType nodeType;

} Node;