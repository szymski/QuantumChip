/*--------------------------------
	Quantum Chip tokenizer
----------------------------------*/

include("tokenizer_spec.lua")

local stringFind = string.find

/*--------------------------------
	Tokenizer
----------------------------------*/

local META = { }
META.__index = META

/*
	Token table:
		Token type
		Token value
		Line
		Character
*/

/*--------------------------------
	Move functions
----------------------------------*/

function META:CheckNextLine()
	if self.Input[self.Line][self.Pos] == "" then
		self.Line = self.Line + 1
		self.Pos = 0
	end
end

function META:NextChar()
	self.Pos = self.Pos + 1
	self.Char = self.Input[self.Line][self.Pos]
	return self.Input[self.Line][self.Pos] != nil
end

function META:PrevChar()

end

function META:NextCharPattern(char)

end

/*--------------------------------
	Utils
----------------------------------*/

function META:SkipWhiteSpace()
	local pos = stringFind(self.Input[self.Line], "[^%s]", self.Pos+1)

	if pos && pos != -1 && pos != self.Pos+1 then
		self.Pos = pos-1
		self.Char = self.Input[self.Line][self.Pos]
	end
end

function META:PushToken(tokenType, value)
	self.Tokens[#self.Tokens+1] = { tokenType, value, self.Line, self.Pos }
end

/*--------------------------------
	Patterns
----------------------------------*/

function META:AcceptPattern(pattern)
	local startPos, endPos = stringFind(self.Input[self.Line], pattern, self.Pos)

	if startPos && startPos != -1 && startPos == self.Pos then
		self.PatternStack[#self.PatternStack+1] = self.Pos
		self.PatternMatch = self.Input[self.Line]:sub(self.Pos, endPos)
		self.Pos = endPos
		return true
	end

	return false
end

function META:PrevPattern()
	self.Pos = self.PatternStack[#self.PatternStack]
	self.PatternStack[#self.PatternStack] = CheckNextLine
end

/*--------------------------------
	Errors
----------------------------------*/

// Tokenizer error, returns msg, line, character
function META:Error(msg)
	return "Line: " .. self.Line .. " Char: " .. self.Pos .. " - " .. msg, self.Line, self.Pos
end

/*--------------------------------
	Tokenization
----------------------------------*/

function META:Tokenize(input)
	print("==========")
	print("Tokenizing")

	self.Input = string.Explode("\n", input)
	self.Lines = #self.Input
	self.Line = 1
	self.Pos = 0
	self.Tokens = { }
	self.PatternStack = { }
	self.StartTime = SysTime() // Anti-stuck

	while self.Input[self.Line] do
		self:SkipWhiteSpace()
		self:NextChar()

		if self:AcceptPattern("[%a_][%a%d_]*") then 							// Identifiers
			if QC.RawKeywords[self.PatternMatch] then
				self:PushToken("k", QC.RawKeywords[self.PatternMatch][1])
			else
				self:PushToken("i", self.PatternMatch)
			end
		elseif self:AcceptPattern("%d+%.%d+") || self:AcceptPattern("%d+") then 							// Number
			self:PushToken("n", tonumber(self.PatternMatch))
		elseif self:AcceptPattern("\"") then 																// Strings
			self:NextChar()
		elseif self:AcceptPattern("[^%w^%s][^%w^%s]?") then 												// Symbol
			if QC.RawSymbols[self.PatternMatch] then
				self:PushToken("s", QC.RawSymbols[self.PatternMatch][1])
			else
				self:PrevPattern()
				if QC.RawSymbols[self.Char] then
					self:PushToken("s", QC.RawSymbols[self.Char][1])
				else
					return self:Error("Unknown symbol " .. self.Char)
				end
			end
		elseif self:AcceptPattern("[%s]+") then	
			self:NextChar()	// Spaces - we do nothing here
		else
			self:NextChar()
		end

		self:CheckNextLine()




		// Anti-stuck
		if SysTime() - self.StartTime > 1 then
			print("STUCK!")
			break
		end
		// Anti-stuck
	end

	return self.Tokens
end

/*--------------------------------
	Tokenizer creation
----------------------------------*/

function QC.Tokenizer() 
	local tbl = { }
	setmetatable(tbl, META)
	return tbl
end