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
	self.Scope[name] = class
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
	Sequences & blocks
----------------------------------*/

function META:Sequence(trace, exitToken)
	local sequence = { }

	while self.Tokens[self.Index+1] do
		if exitToken && self:AcceptSymbol(exitToken) then
			self:PrevToken()
			return self:Compile_SEQ(trace, sequence)
		end

		sequence[#sequence + 1] = self:Statement()
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
	local statement = self:Statement()
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

// Client-server separation
function META:Statement_2()
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

	return self:Statement_3()
end

// Variable Assignments
function META:Statement_3()
	local modifier = nil

	if self:AcceptKeyword("nw") then modifier = "nw"
	elseif self:AcceptKeyword("win") then modifier = "win"
	elseif self:AcceptKeyword("wout") then modifier = "wout" end

	if self:AcceptIdent() then
		local class = self:GetClass(self:GetTokenTrace(), self.Token[2])
		self:RequireIdent("Variable name expected.")
		local name = self.Token[2]

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
	return self:Expression_1()
end

// Raw values
function META:Expression_1()
	if self:AcceptKeyword("tre") then
		return self:Compile_BOOL(self:GetTokenTrace(), true)
	elseif self:AcceptKeyword("fls") then
		return self:Compile_BOOL(self:GetTokenTrace(), false)
	elseif self:AcceptNumber() then
		return self:Compile_NUM(self:GetTokenTrace(), self.Token[2])
	elseif self:AcceptString() then
		return self:Compile_STR(self:GetTokenTrace(), self.Token[2])
	end

	return self:Expression_END()
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

	self.Scopes = { { } }
	self.Scope = self.Scopes[0]

	self.Side = nil // false - clientside, true - serverside

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