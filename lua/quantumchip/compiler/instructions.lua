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

/*--------------------------------
	Primitive types
----------------------------------*/

function META:Compile_BOOL(trace, value)
	return { Trace = trace, Inline = value and "true" or "false", Return = "b" }
end

function META:Compile_VOID(trace)
	return { Trace = trace, Inline = "nil", Return = "void" }
end

function META:Compile_NUM(trace, value)
	return { Trace = trace, Inline = tostring(value), Return = "n" }
end

function META:Compile_STR(trace, value)
	return { Trace = trace, Inline = value, Return = "s" }
end

/*--------------------------------
	Operators
----------------------------------*/

function META:Compile_IS(trace, exp)
	if exp.Return == "b" then return exp end
	if exp.Return == "n" then return { Trace = trace, Inline = exp.Inline .. " > 0", Return = "b" } end

	self:Error(trace, exp.Return .. " can not be used as condition.")
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
	return { Trace = trace, Prepared = table.concat({"if", self:Compile_IS(trace, cond).Inline, "then\n", seq.Prepared, "\nend"}, " "), Return = "" }
end

function META:Compile_CLSV(trace, cond, seq)
	return { Trace = trace, Prepared = table.concat({"if", cond, "then\n", seq.Prepared, "\nend"}, " "), Return = "" }
end

/*--------------------------------
	Variables
----------------------------------*/

function META:Compile_ASS(trace, class, name, exp)
	if exp.Return != class then self:Error(trace, "Can not assign " .. QC.NiceClass(exp.Return) .. " to " .. QC.NiceClass(class) .. ".") end

	return { Trace = trace, Prepared = "local var_" .. name .. " = " .. exp.Inline, Return = "" }
end
