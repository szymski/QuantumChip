/*--------------------------------
	Quantum Chip compiler
----------------------------------*/

include("preprocessor.lua")
include("tokenizer.lua")
include("parser.lua")

/*--------------------------------
	Compiler metatable
----------------------------------*/

local META = { }
META.__index = META

/*--------------------------------
	Compilation
----------------------------------*/

local function Parse(tokens)
	QC.Compiled = nil
	QC.Parser():Parse(tokens)
end

function META:Compile(code)
	local time = SysTime()

	local newCode = QC.Preprocessor():Process(code)

	print(newCode)

	print("Preprocessing time: " .. (SysTime()-time))



	local time = SysTime()

	local tokens = QC.Tokenizer():Tokenize(newCode)

	print("Tokenization time: " .. (SysTime()-time))

	for k, v in pairs(tokens) do
		print(v[1] .. "    -    " .. v[2])
	end



	print("")
	print("PARSING")
	print("")


	local time = SysTime()

	local parseFunc = coroutine.create(Parse)
	local success, err = coroutine.resume(parseFunc, tokens)

	if !success then print("Compiler error: " .. err) end

	if !QC.Compiled then return nil, QC.ErrorLine, QC.ErrorChar, QC.ErrorMsg end

	local compiled = QC.Compiled

	print("Parsing time: " .. (SysTime()-time))

	return table.concat({
[[
// Quantum Chip Script

return function(context)

	// Preparation
	local Vars = context.Vars
	local Funcs = context.Funcs
	local Events = context.Events

	// Main
	]], compiled, [[
	
	
end
]]	}, "\n")
end

/*--------------------------------
	Compiler creation
----------------------------------*/

function QC.Compiler() 
	local tbl = { }
	setmetatable(tbl, META)
	return tbl
end