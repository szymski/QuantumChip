/*--------------------------------
	Quantum Chip core
----------------------------------*/

QC = { }

include("context.lua")
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

/*--------------------------------
	Functions

	Function table [name][params]
----------------------------------*/

function QC.AddInlineFunction(component, name, input, ret, inline)
	QC.Functions[name] = QC.Functions[name] or { }

	QC.Functions[name][input] = {
		Component = component,
		Operator = operator,
		Input = input,
		Return = ret,
		Inline = inline
	}
end

function QC.AddPreparedFunction(component, name, input, ret, prep, inline)
	QC.Functions[name] = QC.Functions[name] or { }

	QC.Functions[name][input] = {
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

local code, line, char, err = compiler:Compile([[

   	server event dupa {
   		int asd = 5;
   	}


    ]])

if !code then
	print("ERROR!    -    Line: " .. line .. ", Char: " .. char .. " - " .. err)
end

print()
print("FINAL CODE")
print("===============")
print()
print(code)

