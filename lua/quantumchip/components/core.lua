/*--------------------------------
	Core component
----------------------------------*/

local Component = QC.CreateComponent("core")
Component.Description = "Core component. Includes all primitive types and basic functions."
Component.Author = "Szymekk"

local Class_Boolean = QC.CreateClass(Component, "boolean", "b")
local Class_Number = QC.CreateClass(Component, "number", "n")
local Class_String = QC.CreateClass(Component, "string", "s")

Class_Boolean:AddAlias("bool")
Class_Number:AddAlias("int")

Class_Boolean:SetDefault("true")
Class_Number:SetDefault("0")
Class_String:SetDefault("\"\"")

QC.AddInlineOperator(nil, "is", "b", "b", "@1")
QC.AddInlineOperator(nil, "is", "n", "b", "@1 >= 1")

QC.AddInlineOperator(nil, "+", "n,n", "n", "@1 + @2")
QC.AddInlineOperator(nil, "-", "n,n", "n", "@1 - @2")
QC.AddInlineOperator(nil, "*", "n,n", "n", "@1 * @2")
QC.AddInlineOperator(nil, "/", "n,n", "n", "@1 / @2")
QC.AddInlineOperator(nil, "%", "n,n", "n", "@1 % @2")
QC.AddInlineOperator(nil, "^", "n,n", "n", "@1 ^ @2")

QC.AddPreparedOperator(nil, "++", "n", "n", "@1 = @1 + 1", "@1")
QC.AddPreparedOperator(nil, "--", "n", "n", "@1 = @1 - 1", "@1")


QC.AddInlineFunction(nil, "boolFunc", "", "b", "true")

QC.AddInlineFunction(nil, "pow", "n:n", "n", "math.pow(@1, @2)")

QC.AddInlineFunction(nil, "print", "n", "n", "print('@1')")

QC.AddInlineFunction(nil, "testFunc", "", "n", "1234")
QC.AddInlineFunction(nil, "testFunc", "n,n", "n", "@1 + @2")
QC.AddPreparedFunction(nil, "anotherFunc", "", "n", "local num = 5+5", "num")

