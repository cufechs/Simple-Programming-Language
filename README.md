# N Compiler
N is a simple programming language compiler similar to a mix between C/C++ built using Lex and Yacc.

# How to Use
### 1. Install Lex & Yacc  
Download and install **Lex** & **Yacc** compiler generating packages.

This compiler is built on:

| Package                 | Version        |
| ----------------------- | -------------- |
| Lex                     | Flex v2.5.4a   |
| Yacc                    | Bison v2.4.1   |

**Download links:** [Windows](https://github.com/lexxmark/winflexbison/releases), Linux, Mac

### 2. Install GCC compiler

### 3. Build and Run N compiler
Run `./run.sh` to build and run the .exe for you.

**_Note:_** If you are in Windows you might run it in `git bash`.

# N Compiler Commands
**Syntax**:  

# Overview
In this section, we are going to give a brief descriptions and examples for the syntax allowed by N. As we said, it is almost identical to C-language.

## Data Types
In N, we support the basic data types but unfortunately, we do not support arrays or pointers.
The supported types:
-	`void`  : is only valid as a function return type to tell that it has no value to return.
-	`int`   : is an integer numeric value data type.
-	`double`: is a real numeric value data type.
-	`char`  : is a character value data type.
-	`bool`  : is a Boolean value data type that accepts either `true` or `false`.

## Variable/Constant Declarations
In N, we support scoped variables and constants declaration. As in C-language, constants must be initialized as being declared.

**e.g.**

```C++
int x;
char c = 'n';
bool lock = true;
int a = 0, b, MAX = 100;

const double PI = 3.14;
const double EPS = 1e-9;
```

## If-Else Control Statements
We support if-else control statement in almost the exact same way as in C-language. 

**e.g.**

```C++
if (x) {
    if (y > 0)
        /* if-body */
    else if (z & 1)
        /* else-if-body */
    else
        /* else-body */
}
```

## Switch Statements
Like if-statement, we support switch-statement in almost the exact same way as in C-language. 

**e.g.**

```C++
switch (state) {
	case 1:
	case 2:
		/* do something */
	case RUNNING: // RUNNING must be defined as constant
		/* do something */
		break;
	default:
		/* default */
}
```

## For/While/Until Loops
N supports loops in almost the exact same way as in C-language. We support for-loops, while-loops, and do-while loops. Break-statements and continue-statements are supported within the scope of a loop.

**e.g.**
```C++
for (int i = 0; i < n; ++i) {
    for (int j = 0; j < m; ++j) {
        while (i < j) // do something
        continue;
    }
}

do {
    if (cond)
        break;
    // do something
} while (true);
```

## Functions
N supports functions but with limited functionalities than that of the C-language. We do not support default parameters. We do not support neither function prototyping nor function overloading.
Return-statements are allowed within the scope of a function. And functions can only be defined in the global scope.

**e.g.**
```C++
int fib(int n) {
    return fib(n - 1) + fib(n - 2);
}
```

## Expressions
In N, we support complex expressions similar to those of C-language. We support almost the entire set of operators supported by C-language with the same precedence and associativity.

**e.g.**
```C++
((x++ == --y) == true) ;
```

## Comments
N supports the same comment styles as in C-language. The comments can either be:
-	Line comment:
   ```C++
   // This is a line comment
   ```
-	Block comment:
  ```C++
  /**
   * This is a block comment
   * that can span
   * multiple lines
   */
  ```
