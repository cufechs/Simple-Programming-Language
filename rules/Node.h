#define MAX_ID_LENGTH 32

enum DataType {
    TYPE_INT,
    TYPE_DOUBLE,
    TYPE_CHAR,
    TYPE_VOID,
    TYPE_BOOL
};

enum NodeType {
    NODE_ID, //identifier 
    NODE_CONST_VALUE, //int, double, number
    NODE_OP, //operation
};

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

}Node;