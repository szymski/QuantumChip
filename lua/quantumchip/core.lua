/*--------------------------------
	Quantum Chip core
----------------------------------*/

QC = { }

include("component_meta.lua")
include("class_meta.lua")
include("compiler/compiler.lua")

/*--------------------------------
	Basic stuff
----------------------------------*/

function QC.Init()
	print("Initializing Quantum Chip")
	QC.Components = { }
	QC.Classes = { }
	QC.ShortClasses = { }
	QC.Functions = { }
	QC.Operators = { }

	include("components/core.lua")
end

function QC.AddClass(name)

end

/*--------------------------------
	Useful
----------------------------------*/

function QC.NiceClass(class)
	return QC.ShortClasses[class].Name
end

/*--------------------------------
	Operators
----------------------------------*/

function QC.AddInlineOperator(component, operator, input, ret, inline)
	QC.Operators[operator..","..input] = {
		Component = component,
		Operator = operator,
		Input = input,
		Return = ret,
		Inline = inline
	}
end

function QC.AddPreparedOperator(component, operator, input, ret, prep, inline)
	QC.Operators[operator..","..input] = {
		Component = component,
		Operator = operator,
		Input = input,
		Return = ret,
		Prepared = prep,
		Inline = inline
	}
end



QC.Init()

/*--------------------------------
	Debug
----------------------------------*/

if SERVER then return end

local compiler =  QC.Compiler()

print()
print()
print()
print()
print()
print()
print()

local code = compiler:Compile([[

   	server {
   		
   		int test;

   		test = 1*2+5*7/25%4*123+512*12%64-53+46*6;

   		
   		
    }


    ]])

print()
print("FINAL CODE")
print("===============")
print()
print(code)

