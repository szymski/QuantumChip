/*--------------------------------
	Context
----------------------------------*/

local META = { }
META.__index = META

/*--------------------------------
	Execution
----------------------------------*/

local sethook = debug.sethook

function META:PreExecute()
	self.ExTime = SysTime()

	sethook(function()
		self.QuotaTime = self.QuotaTime + (SysTime() - self.ExTime)

		if self.QuotaTime > 0.05 then
			sethook()
			print("Tick quota exceeded!")
		end
	end, "", 1000)
end

function META:PostExecute()
	sethook()
end

function META:Execute(func, ...)
	self:PreExecute()

	local suc, err = pcall(func, ...)

	if !suc then
		print("FUCKING RUNTIME ERROR KURWA MAC: " .. err)
	end

	self:PostExecute()
end

/*--------------------------------
	Init
----------------------------------*/

function META:Init(func)
	self:Execute(func, self)
end

/*--------------------------------
	Creation
----------------------------------*/

function QC.Context(entity)
	local tbl = setmetatable({}, META)

	tbl.Vars = { }
	tbl.Funcs = { }
	tbl.Events = { }

	tbl.Entity = entity

	tbl.ExTime = 0
	tbl.QuotaTime = 0

	return tbl
end