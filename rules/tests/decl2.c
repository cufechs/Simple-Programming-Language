int a = 1 + 2 * 3 - 4; 

int b = 3;
int d = 4;
int dd =a ;

int main() {
  int c = 1;
  if (c > 100) {
    a--;
  } else {
    a++;
  }
}
//int a = 2;
//char c = 'x';
// int func2(int aa);
// int d = 11111;

/*
  des:    opr:    src1:   src2:
string getAssemblyOfCurrentNode()

each node: responsible for creating its assembly

int a = 1 + 2 * 3 - 4;
Declarations:
  - Arithmetic (at primitive non terminal):
    - MOV R%d, val  <-- get it from node (print at it)
  - expression op expression:
    - ADD R%d, $1->regName if any, $3->regName if any <-- get it from evaluateExpression (print at it)
      - check if $1 or $3 are identifiers not primitive constants
    - always save last register name (lastRegName)
  - at declaration non terminal (with initialization):
    - we have currentID and currentType
    - LOAD currentID, lastRegName

x++; --y;
Increment and Decrement:
  - from createUnaryExpression():
    - we have currentID and currentType
    - check if currentType is int or double (for semantic errors)
    - MOV R%d, currentID
    - INC R%d
    - LOAD currentID, R%d
    - decrease register count by one


if (x > 0) {

} else {

}
Conditionals:
  - CMP $1, $3
  - depeneding whether '>' '<' '==' '>=' '<=' --> JG JL JE JGE JLE .TRUE_LABEL%d
  -  .... else code
  -  .... else code
  - JMP .FALSE_LABEL%d
  - .TRUE_LABEL%d
  - ... if code
  - ... if code
  - JMP .EXIT_IF_ELSE_%d
  - .FALSE_LABEL%d




Variable decalarations:
  - Node
  - check types in declaration (semantic)
  - evaluateExpression()

*/

a++;