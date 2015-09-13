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

	include("components/core.lua")
end

QC.Init()

function QC.AddClass(name)

end

/*--------------------------------
	Useful
----------------------------------*/

function QC.NiceClass(class)
	return QC.ShortClasses[class].Name
end

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
   		int test = true	
   	}

    ]])

print()
print("FINAL CODE")
print("===============")
print()
print(code)

