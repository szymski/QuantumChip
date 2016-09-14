# Compiler structure

QuantumChip compiler is split into 5 parts.

Each file added to the compiler is processed separately by preprocessor, lexer and syntax analyser. Then, all files go to semantic analyser and code generator.

## Preprocessor - luaa/quantumchip/compiler/preprocessor/
Comments are removed and preprocessor directives are handled.

## Lexical analyser - luaa/quantumchip/compiler/lexer/
Lexer translates source code into a stream of tokens.

## Syntax analyser - luaa/quantumchip/compiler/syntax_analyser/
Stream of tokens is translated into a AST (Abstract Syntax Tree).

## Semantic analyser - luaa/quantumchip/compiler/semantic_analyser/
Instructions are checked for errors (type checking etc.).

## Code generator - luaa/quantumchip/compiler/code_generator/
Generates code from instructions.
