# Compiler-Design

This project is a three-part compiler frontend for the **sD language**, developed over the Spring 2025 semester. The frontend includes:

---

### 1. Lexical Analysis (Scanner)

Implemented using **Lex (flex)**, this component scans source code written in the sD language and tokenizes it into meaningful lexical elements such as identifiers, keywords, literals, and operators.

Run the following commands on **Cygwin64** or a Unix terminal:

```bash
flex scanner.l                  # generates lex.yy.c
gcc lex.yy.c -lfl -o scanner    # compile scanner
./scanner < HelloWorld.sd       # run scanner on sample code
```

To save the output to a file:

```bash
./scanner < HelloWorld.sd > result.txt
```

---

### 2. Syntax Analysis (Parser)

Built using **Yacc (or Bison)**, this component parses the token stream produced by the scanner and checks whether the program conforms to the grammar of the sD language.

To compile and run the parser:

```bash
yacc -d parser.y                # generates y.tab.c and y.tab.h
gcc -c -g y.tab.c               # compile parser
lex scanner.l                   # re-use scanner for token generation
gcc -c -g lex.yy.c              # compile scanner again
gcc -o p y.tab.o lex.yy.o symbols.o -lfl  # link everything
./p Sigma.sd                    # run parser on source file
```

If the input program contains syntax errors, line number and token info will be shown.

---

### 3. Code Generation (Java Bytecode)

This stage takes the parse tree and generates equivalent **Java Virtual Machine (JVM) bytecode** that can be executed on any JVM. (This stage is currently in development.)

---

## Tools Used

* **Flex** ¡V Lexical analyzer generator
* **Yacc / Bison** ¡V Syntax parser generator
* **GCC** ¡V Compiler used to integrate components
* **Java VM** ¡V Target for code generation

---

## Language: sD

The **sD language** is a simplified educational programming language created for learning compiler design. It supports:

* Basic types: `int`, `float`, `bool`, `string`
* Statements: `if`, `for`, `while`, `foreach`, `print`, `return`, `read`, etc.
* Expressions with arithmetic, logical, and relational operators