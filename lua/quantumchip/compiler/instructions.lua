/*-----------------------------------------
	Quantum Chip compiler instructions
-------------------------------------------*/

local META = QC.PARSER

/*
	Instruction structure:
		Trace
		Inline / Prepared
		Return
*/

local stringReplace = string.Replace

/*--------------------------------
	Primitive types
----------------------------------*/

function META:Compile_BOOL(trace, value)
	return { Trace = trace, Inline = value and "true" or "false", Return = "b" }
end

function META:Compile_VOID(trace)
	return { Trace = trace, Inline = "nil", Return = "" }
end

function META:Compile_NUM(trace, value)
	return { Trace = trace, Inline = tostring(value), Return = "n" }
end

function META:Compile_STR(trace, value)
	return { Trace = trace, Inline = "\"" .. value .. "\"", Return = "s" }
end

/*--------------------------------
	Statements
----------------------------------*/

function META:Compile_SEQ(trace, seq)
	local native = { }

	for k, v in pairs(seq) do
		native[#native+1] = v.Prepared or v.Inline
	end

	return { Trace = trace, Prepared = table.concat(native, "\n"), Return = "" }
end

function META:Compile_IF(trace, cond, seq)
	return { Trace = trace, Prepared = "if " .. self:Compile_IS(trace, cond).Inline .. " then\n" .. seq.Prepared .. "\nend", Return = "" }
end

function META:Compile_WHL(trace, cond, seq)
	return { Trace = trace, Prepared = "while " .. self:Compile_IS(trace, cond).Inline .. " do\n" .. seq.Prepared .. "\nend", Return = "" }
end

function META:Compile_CLSV(trace, cond, seq)
	return { Trace = trace, Prepared = "if " .. cond .. " then\n" .. seq.Prepared .. "\nend", Return = "" }
end

function META:Compile_EVENT(trace, name, seq)
	return { Trace = trace, Prepared = "Events[\""..name.."\"] = function()\n" .. seq.Prepared .. "\nend", Return = "" }
end

/*--------------------------------
	Variables
----------------------------------*/

function META:Compile_ASS(trace, class, name, exp)
	if exp.Return != class then self:Error(trace, "Can not assign " .. QC.NiceClass(exp.Return) .. " to " .. QC.NiceClass(class) .. ".") end
	if self:GetScopeVariable(name) then self:Error(trace, "Variable '" .. name .. "' already exists.") end

	local id = self:AddScopeVariable(name, class)

	return { Trace = trace, Prepared = "Vars[" .. id .. "] = " .. exp.Inline, Return = "" }
end

function META:Compile_DEFAULT(trace, class, name)
	if !QC.ShortClasses[class].Default then self:Error(trace, QC.NiceClass(class) .. " doesn't have a default value.") end
	if self:GetScopeVariable(name) then self:Error(trace, "Variable '" .. name .. "' already exists.") end

	local id = self:AddScopeVariable(name, class)

	return { Trace = trace, Prepared = "Vars[" .. id .. "] = " .. QC.ShortClasses[class].Default, Return = "" }
end

function META:Compile_EASS(trace, var, exp)
	if exp.Return != var[1] then self:Error(trace, "Can not assign " .. QC.NiceClass(exp.Return) .. " to " .. QC.NiceClass(var[1]) .. ".") end

	return { Trace = trace, Prepared = "Vars[" .. var[2] .. "] = " .. exp.Inline, Return = "" }
end


function META:Compile_VAR(trace, var)
	return { Trace = trace, Inline = "Vars[" .. var[2] .. "]", Return = var[1] }
end

/*--------------------------------
	Operators
----------------------------------*/

function META:Compile_IS(trace, exp)
	local operator =  QC.Operators["is,"..exp.Return]
	if !operator then self:Error(trace, "No condition operator for " .. QC.NiceClass(exp.Return) .. ".") end

	local compiled = self:CompileOperator(operator, exp.Inline)
	if compiled.Return == "b" then return compiled end

	self:Error(trace, "Condition operator of " .. QC.NiceClass(exp.Return) .. " doesn't return boolean. This shouldn't happen.")
end

/*--------------------------------
	Arithmetic operators
----------------------------------*/

function META:Compile_ADD(trace, exp1, exp2)
	local operator =  QC.Operators["+,"..exp1.Return..","..exp2.Return]

	if !operator then self:Error(trace, "No " .. QC.NiceClass(exp2.Return) .. " addition operator for " .. QC.NiceClass(exp1.Return) .. ".") end

	return self:CompileOperator(operator, exp1.Inline, exp2.Inline)
end

function META:Compile_SUB(trace, exp1, exp2)
	local operator =  QC.Operators["-,"..exp1.Return..","..exp2.Return]

	if !operator then self:Error(trace, "No " .. QC.NiceClass(exp2.Return) .. " subtraction operator for " .. QC.NiceClass(exp1.Return) .. ".") end

	return self:CompileOperator(operator, exp1.Inline, exp2.Inline)
end

function META:Compile_MUL(trace, exp1, exp2)
	local operator =  QC.Operators["*,"..exp1.Return..","..exp2.Return]

	if !operator then self:Error(trace, "No " .. QC.NiceClass(exp2.Return) .. " multiplication operator for " .. QC.NiceClass(exp1.Return) .. ".") end

	return self:CompileOperator(operator, exp1.Inline, exp2.Inline)
end

function META:Compile_DIV(trace, exp1, exp2)
	local operator =  QC.Operators["/,"..exp1.Return..","..exp2.Return]

	if !operator then self:Error(trace, "No " .. QC.NiceClass(exp2.Return) .. " division operator for " .. QC.NiceClass(exp1.Return) .. ".") end

	return self:CompileOperator(operator, exp1.Inline, exp2.Inline)
end

function META:Compile_MOD(trace, exp1, exp2)
	local operator =  QC.Operators["%,"..exp1.Return..","..exp2.Return]

	if !operator then self:Error(trace, "No " .. QC.NiceClass(exp2.Return) .. " modulo operator for " .. QC.NiceClass(exp1.Return) .. ".") end

	return self:CompileOperator(operator, exp1.Inline, exp2.Inline)
end

function META:Compile_POW(trace, exp1, exp2)
	local operator =  QC.Operators["^,"..exp1.Return..","..exp2.Return]

	if !operator then self:Error(trace, "No " .. QC.NiceClass(exp2.Return) .. " power operator for " .. QC.NiceClass(exp1.Return) .. ".") end

	return self:CompileOperator(operator, exp1.Inline, exp2.Inline)
end

function META:Compile_INC(trace, var)
	local operator =  QC.Operators["++,"..var.Return]

	if !operator then self:Error(trace, "No incrementation operator for " .. QC.NiceClass(var.Return) .. ".") end

	return self:CompileOperator(operator, var.Inline)
end

function META:Compile_DEC(trace, var)
	local operator =  QC.Operators["--,"..var.Return]

	if !operator then self:Error(trace, "No decrementation operator for " .. QC.NiceClass(var.Return) .. ".") end

	return self:CompileOperator(operator, var.Inline)
end

/*--------------------------------
	Functions and methods
----------------------------------*/

function META:Compile_FUNC(trace, name, params)
	local paramStr = ""

	for k, v in pairs(params) do
		paramStr = paramStr .. v.Return .. (k == #params and "" or ",")
	end

	local func = (QC.Functions[name] and QC.Functions[name][paramStr] or nil)

	if !func then self:Error(trace, "No such function '" .. name .. "(" .. paramStr .. ")" .. "'.") end

	return self:CompileFunction(func, params)
end

function META:Compile_METHOD(trace, exp, name, params)
	local paramStr = ""

	for k, v in pairs(params) do
		paramStr = paramStr .. v.Return .. (k == #params and "" or ",")
	end

	local func = (QC.Functions[name] and QC.Functions[name][exp.Return .. ":" .. paramStr] or nil)

	if !func then self:Error(trace, "No such method '" .. exp.Return .. ":" .. name .. "(" .. paramStr .. ")" .. "'.") end

	table.insert(params, 1, exp)

	return self:CompileFunction(func, params)
end

/*--------------------------------
	Operator/function compilation
----------------------------------*/

function META:CompileOperator(operator, ...)
	local inputs = {...}

	if operator.Prepared then
		local prep = operator.Prepared

		for i = 1, #inputs do
			prep = stringReplace(prep, "@" .. i, inputs[i])
		end

		self:PushPreparation(prep)
	end

	local compiled = operator.Inline

	for i = 1, #inputs do
		compiled = stringReplace(compiled, "@" .. i, inputs[i])
	end

	return { Inline = compiled, Return = operator.Return }
end

function META:CompileFunction(func, params)
	if func.Prepared then
		local prep = func.Prepared

		for i = 1, #params do
			prep = stringReplace(prep, "@" .. i, params[i].Inline)
		end

		self:PushPreparation(prep)
	end

	local compiled = func.Inline

	for i = 1, #params do
		compiled = stringReplace(compiled, "@" .. i, params[i].Inline)
	end

	return { Inline = compiled, Return = func.Return }
end
