/*--------------------------------
	Quantum Chip preprocessor
----------------------------------*/

local stringFind = string.find

/*--------------------------------
	Preprocessor metatable
----------------------------------*/

local META = { }
META.__index = META

/*--------------------------------
	Useful
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

/*--------------------------------
	Preprocessing
----------------------------------*/

function META:Process(input)
	print("==========")
	print("Preprocessing")

	self.Input = string.Explode("\n", input)
	self.Lines = #self.Input
	self.Line = 1
	self.Pos = 0
	self.MultiLineComment = false
	self.StartTime = SysTime() // Anti-stuck

	while self.Input[self.Line] do
		self:NextChar()

		// Single-line comments
		local startPos, endPos = stringFind(self.Input[self.Line], "//", 1, true)
		if startPos then
			self.Input[self.Line] = self.Input[self.Line]:sub(1, startPos-1)
		end

		// Multiline comments
		if !self.MultiLineComment then
			local startPos, endPos = stringFind(self.Input[self.Line], "/*", 1, true)
			if startPos then
				local startPos2, endPos2 = stringFind(self.Input[self.Line], "*/", 1, true)
				if startPos2 then
					local temp = self.Input[self.Line]
					self.Input[self.Line] = temp:sub(1, startPos-1) .. temp:sub(endPos2+1)
				else
					self.MultiLineComment = true
					self.Input[self.Line] = self.Input[self.Line]:sub(1, startPos-1)
				end
			end
		else
			local startPos, endPos = stringFind(self.Input[self.Line], "*/", 1, true)
			if startPos then
				self.Input[self.Line] = self.Input[self.Line]:sub(endPos+1)
				self.MultiLineComment = false
			else
				self.Input[self.Line] = ""
			end
		end

		// Directives

		self:CheckNextLine()

		// Anti-stuck
		if SysTime() - self.StartTime > 1 then
			print("STUCK!")
			break
		end
		// Anti-stuck
	end

	return table.concat(self.Input, "\n")
end

/*--------------------------------
	Preprocessor creation
----------------------------------*/

function QC.Preprocessor() 
	local tbl = { }
	setmetatable(tbl, META)
	return tbl
end