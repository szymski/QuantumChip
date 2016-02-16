--[[
	luaa_enumerable.luaa
	18.12.2015 14:30:13

	This file is a part of LuaAdvanced library.
	No license yet.

	Compiled using LuaAdvanced
	This file should not be modified.
]]

-- Enumerable class metatable
CEnumerable = { }
CEnumerable.__index = CEnumerable
CEnumerable.__type = "Enumerable"
CEnumerable.__baseclasses = { }
luaa.Inherit(CEnumerable, CLUAA_Object)
function CEnumerable:Enumerable(tbl)
	self._table = tbl
end
function CEnumerable:Where(f)
	local tbl = { }
	
	for _, v in pairs(self._table) do
			if(f(v)) then
				tbl[#tbl + 1] = v
			end
			
	
	
	end
	
	return Enumerable(tbl)
end
function CEnumerable:Select(f)
	local tbl = { }
	
	for _, v in pairs(self._table) do
			tbl[#tbl + 1] = f(v)
	
	
	end
	
	return Enumerable(tbl)
end
function CEnumerable:First(f)
	
	for _, v in pairs(self._table) do
			if(f(v)) then
				return v
			end
			
	
	
	end
	
end
function CEnumerable:Any(f)
	
	for _, v in pairs(self._table) do
			if(f(v)) then
				return true
			end
			
	
	
	end
	
	return false
end
function CEnumerable:Skip(n)
	local tbl = { }
	local c = 0
	
	for _, v in pairs(self._table) do
			if(c < n) then
						c = c + 1
						goto continue_1
			
			end
			
			tbl[#tbl + 1] = v
	
	::continue_1::
	end
	
	return Enumerable(tbl)
end
function CEnumerable:SkipWhile(f)
	local tbl = { }
	local b = false
	
	for _, v in pairs(self._table) do
			if(not (f(v))) then
				b = true
			end
			
			if(b) then
				tbl[#tbl + 1] = v
			end
			
	
	
	end
	
	return Enumerable(tbl)
end
function CEnumerable:Reverse()
	local tbl = { }
	
	for _, v in pairs(self._table) do
			table.insert(tbl, 1, v)
	
	
	end
	
	return Enumerable(tbl)
end
function CEnumerable:Inherit(tbl)
	local c = 1
	
	for _, v in pairs(tbl) do
			if(not (self._table[c])) then
						self._table[c] = v
			
			end
			
			c = c + 1
	
	
	end
	
	return Enumerable(tbl)
end
function CEnumerable:Merge(tbl)
	local c = 1
	
	for _, v in pairs(tbl) do
			if((luaa.IsSubclassOf(v, "table") and luaa.IsSubclassOf(self._table[c], "table"))) then
						Enumerable(self._table[c]).Merge(v)
			
			else
						self._table[c] = v
			
			end
			
			c = c + 1
	
	
	end
	
	return Enumerable(self._table)
end
function CEnumerable:Add(tbl)
	
	for _, v in pairs(tbl) do
			self._table[#self._table + 1] = v
	
	
	end
	
	return Enumerable(self._table)
end
function CEnumerable:AddWhile(f)
	local tbl = { }
	
	for _, v in pairs(self._table) do
			if(not (f(v))) then
						break
			
			end
			
			tbl[#tbl + 1] = v
	
	
	end
	
	return Enumerable(tbl)
end
function CEnumerable:SelectMany(f)
	local tbl = { }
	
	for _, v in pairs(self._table) do
		
	for _, v2 in pairs(f(v)) do
		tbl[#tbl + 1] = v2
	
	end
	
	
	end
	
	return Enumerable(tbl)
end
function CEnumerable:OrderBy(f)
	local tbl = { }
	
	for _, v in pairs(self._table) do
		tbl[#tbl + 1] = v
	
	end
	
	
	local i = 2
	while i <= #tbl do
		if(f(tbl[i]) < f(tbl[i - 1])) then
			local temp = tbl[i - 1]
			tbl[i - 1] = tbl[i]
			tbl[i] = temp
			i = 1
	
	end
	
	
	i = i + 1
	end
	
	return Enumerable(tbl)
end
function CEnumerable:OrderByDescending(f)
	local tbl = { }
	
	for _, v in pairs(self._table) do
		tbl[#tbl + 1] = v
	
	end
	
	
	local i = 2
	while i <= #tbl do
		if(f(tbl[i]) > f(tbl[i - 1])) then
			local temp = tbl[i - 1]
			tbl[i - 1] = tbl[i]
			tbl[i] = temp
			i = 1
	
	end
	
	
	i = i + 1
	end
	
	return Enumerable(tbl)
end
function CEnumerable:Count()
	return #self._table
end
function CEnumerable:ToTable()
	return self._table
end

function CEnumerable:__new(...)
    	self._table = nil

    self:Enumerable(...)
end
function Enumerable(...)
    local tbl = { }
    setmetatable(tbl, CEnumerable)
    tbl:__new(...);
    return tbl
end

