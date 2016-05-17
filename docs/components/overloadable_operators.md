# List of overloadable operators

## Overloading operators

To overload an operator of specified class, use following construction:
```
COMPONENT:AddClassOperatorInline(classShortName, operatorName, arguments, returnType, inlineCode);
```

Example:
```
COMPONENT:AddClassOperatorInline("s", "+", "s:s", "s", "@1 .. @2"); 
```
The operator above is called when you're using + operator on string variable. For example: "this is" + " a sentence".

## Overloadable operators

| Operator name | Takes values | Description |
|---|---|---|
| = | variable, value | Assignment operator used every time a value is assigned to a variable |
| is | value | Operator compiling a value into a condition |
| neg | value | Negation operator (not bitwise) |
| == | leftValue, rightValue | Comparison operator |
| != | leftValue, rightValue | Comparison operator |
| >= | leftValue, rightValue | Comparison operator |
| <= | leftValue, rightValue | Comparison operator |
| # | value | Returns length of the value |
| + | leftValue, rightValue | Addition operator |
| - | leftValue, rightValue | Subtraction operator |
| * | leftValue, rightValue | Multiplication operator |
| / | leftValue, rightValue | Division operator |
| % | leftValue, rightValue | Modulo operator |
| null | variable | Compiled when null is assigned to a variable |