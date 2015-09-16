/*--------------------------------
	Quantum Chip parser
----------------------------------*/

/*--------------------------------
	Parser metatable
----------------------------------*/

local META = { }
META.__index = META

QC.PARSER = META

include("instructions.lua")

/*--------------------------------
	Scopes
----------------------------------*/

function META:PushScope()
	self.Scopes[#self.Scopes+1] = { }
	self.Scope = self.Scopes[#self.Scopes]
end

function META:PopScope()
	self.Scopes[#self.Scopes] = nil
	self.Scope = self.Scopes[#self.Scopes]
end

function META:AddScopeVariable(name, class)
	self.VariableId = self.VariableId + 1 
	self.Scope[name] = { class, self.VariableId }
	return self.VariableId
end

function META:GetScopeVariable(name)
	for i = #self.Scopes, 1, -1 do
		if self.Scopes[i][name] then
			return self.Scopes[i][name]
		end
	end
end

/*--------------------------------
	Tokens
----------------------------------*/

function META:GetTokenTrace()
	return { self.Token[3], self.Token[4] }
end

function META:NextToken()
	self.Index = self.Index + 1
	self.Token = self.Tokens[self.Index]

	if !self.Token then
		self:PrevToken()
		self:Error(self:GetTokenTrace(), "Unexpected end of file. Further input required.")
		return false
	end
end

function META:PrevToken()
	self.Index = self.Index - 1
	self.Token = self.Tokens[self.Index]

	if !self.Token then
		return false
	end
end

/*--------------------------------
	Token accept
----------------------------------*/

function META:AcceptKeyword(key)
	if self.Tokens[self.Index+1] && self.Tokens[self.Index+1][1] == "k" && self.Tokens[self.Index+1][2] == key then
		self:NextToken()
		return true
	end
	
	return false
end

function META:AcceptSymbol(key)
	if self.Tokens[self.Index+1] && self.Tokens[self.Index+1][1] == "s" && self.Tokens[self.Index+1][2] == key then
		self:NextToken()
		return true
	end

	return false
end

function META:AcceptIdent()
	if self.Tokens[self.Index+1] && self.Tokens[self.Index+1][1] == "i" then
		self:NextToken()
		return true
	end

	return false
end

function META:AcceptNumber()
	if self.Tokens[self.Index+1] && self.Tokens[self.Index+1][1] == "n" then
		self:NextToken()
		return true
	end

	return false
end

function META:AcceptString()
	if self.Tokens[self.Index+1] && self.Tokens[self.Index+1][1] == "S" then
		self:NextToken()
		return true
	end

	return false
end

function META:CheckSymbol(...)
	return  self.Tokens[self.Index+1] && self.Tokens[self.Index+1][1] == "s" && table.HasValue({...}, self.Tokens[self.Index+1][2])
end

/*--------------------------------
	Errors
----------------------------------*/

function META:Error(trace, msg)
	print("ERROR!    -    Line: " .. trace[1] .. ", Char: " .. trace[2] .. " - " .. msg)
	coroutine.yield()
end

function META:RequireKeyword(key, msg, trace)
	if !self:AcceptKeyword(key) then
		self:Error(trace or self:GetTokenTrace(), msg)
	end
end

function META:RequireSymbol(key, msg, trace)
	if !self:AcceptSymbol(key) then
		self:Error(trace or self:GetTokenTrace(), msg)
	end
end

function META:RequireIdent(msg, trace)
	if !self:AcceptIdent() then
		self:Error(trace or self:GetTokenTrace(), msg)
	end
end

/*--------------------------------
	Statement preparation
----------------------------------*/

function META:PushPreparation(code)
	self.CurPrepare[#self.CurPrepare+1] = code
end

/*--------------------------------
	Sequences & blocks
----------------------------------*/

function META:Sequence(trace, exitToken)
	local sequence = { }

	while self.Tokens[self.Index+1] do
		if exitToken && self:AcceptSymbol(exitToken) then
			self:PrevToken()
			break
		end

		self.StatementPrepare[#self.StatementPrepare+1] = {  }
		self.CurPrepare = self.StatementPrepare[#self.StatementPrepare]

		local statement = self:Statement()

		for k, v in pairs(self.CurPrepare) do
			sequence[#sequence + 1] = { Prepared = v }
		end

		self.StatementPrepare[#self.StatementPrepare] = nil
		self.CurPrepare = self.StatementPrepare[#self.StatementPrepare]

		sequence[#sequence + 1] = statement

		self:AcceptSymbol("sep")
	end

	return self:Compile_SEQ(trace, sequence)
end

function META:Block(trace)
	if self:AcceptSymbol("lcb") then
		self:PushScope()
		local seq = self:Sequence(trace, "rcb")
		self:PopScope()

		self:RequireSymbol("rcb", "Right curly bracket '}' missing.", self:GetTokenTrace())

		return seq
	end

	self:PushScope()
	local statement = self:Statement() // TODO: Preparation inside block
	self:PopScope()

	return statement
end

/*--------------------------------
	Statements useful
----------------------------------*/

function META:GetCondition()
	self:RequireSymbol("lpa", "Left parenthesis '(' missing.")

	local exp = self:Expression() 

	self:RequireSymbol("rpa", "Right parenthesis ')' missing.")

	return exp
end

function META:GetClass(trace, name)
	if !QC.Classes[name] then self:Error(trace, "No such class: " .. name) end
	
	return QC.Classes[name].ShortName
end

/*--------------------------------
	Statements
----------------------------------*/

function META:Statement()
	return self:Statement_1()
end

// If statements
function META:Statement_1()
	if self:AcceptKeyword("if") then
		return self:Compile_IF(self:GetTokenTrace(), self:GetCondition(), self:Block(self:GetTokenTrace())) 
	end

	return self:Statement_2()
end

// While loop
function META:Statement_2()
	if self:AcceptKeyword("whl") then
		return self:Compile_WHL(self:GetTokenTrace(), self:GetCondition(), self:Block(self:GetTokenTrace())) 
	end	

	return self:Statement_3()
end

// For loop
function META:Statement_3()
	if self:AcceptKeyword("for") then
		// TODO
		return self:Compile_WHL(self:GetTokenTrace(), self:GetCondition(), self:Block(self:GetTokenTrace())) 
	end	

	return self:Statement_4()
end

// Foreach loop
function META:Statement_4()
	
	return self:Statement_5()
end

// Break / continue
function META:Statement_5()
	
	return self:Statement_6()
end

// Client-server separation
function META:Statement_6()
	if self:AcceptKeyword("sv") then
		if self.Side != nil then self:Error(self:GetTokenTrace(), "Multiple client/server side blocks not allowed.") end

		self.Side = true
		local block = self:Block(self:GetTokenTrace())
		self.Side = nil

		return self:Compile_CLSV(self:GetTokenTrace(), "SERVER", block) 
	elseif self:AcceptKeyword("cl") then
		if self.Side != nil then self:Error(self:GetTokenTrace(), "Multiple client/server side blocks not allowed.") end

		self.Side = false
		local block = self:Block(self:GetTokenTrace())
		self.Side = nil

		return self:Compile_CLSV(self:GetTokenTrace(), "CLIENT", block) 
	end

	return self:Statement_7()
end

// Existing variable assignments
function META:Statement_7()
	if self:AcceptIdent() then
		local var = self:GetScopeVariable(self.Token[2])

		if !var then
			self:PrevToken()
			return self:Statement_8()
		end

		if self:AcceptSymbol("ass") then
			return self:Compile_EASS(self:GetTokenTrace(), var, self:Expression())
		else
			self:NextToken()
			self:Error(self:GetTokenTrace(), "Wtf are you trying to do here?")
		end
	end

	return self:Statement_8()
end

// New variable assignments
function META:Statement_8()
	local modifier = nil

	if self:AcceptKeyword("nw") then modifier = "nw"
	elseif self:AcceptKeyword("win") then modifier = "win"
	elseif self:AcceptKeyword("wout") then modifier = "wout" end

	if self:AcceptIdent() then
		local class = self:GetClass(self:GetTokenTrace(), self.Token[2])
		self:RequireIdent("Variable name expected.")
		local name = self.Token[2]

		if QC.Classes[name] then self:Error(self:GetTokenTrace(), "Variables can not be named as classes.") end

		if self:AcceptSymbol("ass") then
			return self:Compile_ASS(self:GetTokenTrace(), class, name, self:Expression())
		end

		return self:Compile_DEFAULT(self:GetTokenTrace(), class, name)
	end

	return self:Statement_END()
end

// Invalid statement
function META:Statement_END()
	self:NextToken()
	self:Error(self:GetTokenTrace(), "Invalid statement: " .. self.Token[2])
end

/*--------------------------------
	Expressions
----------------------------------*/

function META:Expression()
	return self:Expression_10()
end

// Addition and subtraction
function META:Expression_10()
	local exp = self:Expression_11()

	while self:CheckSymbol("add", "sub") do
		if self:AcceptSymbol("add") then
			exp = self:Compile_ADD(self:GetTokenTrace(), exp, self:Expression_11())
		elseif self:AcceptSymbol("sub") then
			exp = self:Compile_SUB(self:GetTokenTrace(), exp, self:Expression_11())
		end
	end

	return exp
end

// Multiplication, division, modulo, power
function META:Expression_11()
	local exp = self:Expression_14()

	while self:CheckSymbol("mul", "div", "mod", "pow") do
		if self:AcceptSymbol("mul") then
			exp = self:Compile_MUL(self:GetTokenTrace(), exp, self:Expression_14())
		elseif self:AcceptSymbol("div") then
			exp = self:Compile_DIV(self:GetTokenTrace(), exp, self:Expression_14())
		elseif self:AcceptSymbol("mod") then
			exp = self:Compile_MOD(self:GetTokenTrace(), exp, self:Expression_14())
		elseif self:AcceptSymbol("pow") then
			exp = self:Compile_POW(self:GetTokenTrace(), exp, self:Expression_14())
		end
	end

	return exp
end

// Grouped equation
function META:Expression_14()
	if self:AcceptSymbol("lpa") then
		local exp = self:Expression()

		self:RequireSymbol("rpa", "Right parenthesis ')' missing, to close grouped equation.")

		exp.Inline = "(" .. exp.Inline .. ")"

		return exp
	end

	return self:Expression_15()
end

// Raw values
function META:Expression_15()
	if self:AcceptKeyword("tre") then
		return self:Compile_BOOL(self:GetTokenTrace(), true)
	elseif self:AcceptKeyword("fls") then
		return self:Compile_BOOL(self:GetTokenTrace(), false)
	elseif self:AcceptNumber() then
		return self:Compile_NUM(self:GetTokenTrace(), self.Token[2])
	elseif self:AcceptString() then
		return self:Compile_STR(self:GetTokenTrace(), self.Token[2])
	end

	return self:Expression_16()
end

// Variables
function META:Expression_16()
	if self:AcceptIdent() then
		local var = self:GetScopeVariable(self.Token[2])

		if self:CheckSymbol("lpa") then return self:Expression_17(self.Token[2]) end

		if !var then self:Error(self:GetTokenTrace(), "Variable '" .. self.Token[2] .. "' isn't accessible from here.") end

		local compiled = self:Compile_VAR(self:GetTokenTrace(), var)

		if self:AcceptSymbol("inc") then
			compiled = self:Compile_INC(self:GetTokenTrace(), compiled)
		elseif self:AcceptSymbol("dec") then
			compiled = self:Compile_DEC(self:GetTokenTrace(), compiled)
		end

		return compiled
	end

	return self:Expression_END()
end

// Functions
function META:Expression_17(name)
	self:RequireSymbol("lpa", "Left parenthesis '(' missing.")

	local params = { }

	if !self:CheckSymbol("rpa") then
		repeat
			params[#params+1] = self:Expression()
		until !self:AcceptSymbol("com")
	end

	self:RequireSymbol("rpa", "Right parenthesis ')' missing.")

	return self:Compile_FUNC(self:GetTokenTrace(), name, params)
end

// Invalid expression
function META:Expression_END()
	self:Error(self:GetTokenTrace(), "Invalid expression")
end

/*--------------------------------
	Compilation
----------------------------------*/

function META:Parse(tokens)
	self.Tokens = tokens
	self.Index = 0

	self.StatementPrepare = { }

	self.Scopes = { { } }
	self.Scope = self.Scopes[1]

	self.VariableId = 0

	self.Side = nil // false - clientside, true - serverside, nil - shared

	self.StartTime = SysTime()

	QC.Compiled = self:Sequence({0, 0}).Prepared
end

/*--------------------------------
	Parser creation
----------------------------------*/

function QC.Parser() 
	local tbl = { }
	setmetatable(tbl, META)
	return tbl
end