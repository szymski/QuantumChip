# Compiler structure

QuantumChip compiler is split into 5 parts.

Each file added to the compiler is processed separately by preprocessor, lexer and syntax analyser. Then, all files go to semantic analyser and code generator.

## Preprocessor - luaa/quantumchip/compiler/preprocessor/
Comments are removed and preprocessor directives are handled.

## Lexer - luaa/quantumchip/compiler/lexer/
Lexer translates source code into a list of tokens.

## Syntax analyser - luaa/quantumchip/compiler/lexer/
List of tokens is translated in a list of instructions.

## Semantic analyser - luaa/quantumchip/compiler/lexer/
Instructions are checked for errors (scope checking etc.).

## Code generator - luaa/quantumchip/compiler/code_generator/
Generates code from instructions.