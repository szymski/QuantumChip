/*--------------------------------
	Class metatable
----------------------------------*/

local META = { }
META.__index = META

/*--------------------------------
	Functions
----------------------------------*/

function META:AddAlias(alias)
	QC.Classes[alias] = self
end

function META:SetDefault(value)
	self.Default = value
end

/*--------------------------------
	Creation
----------------------------------*/

function QC.CreateClass(component, name, short) 
	local tbl = { }
	setmetatable(tbl, META)
	tbl.Component = component
	tbl.Name = name
	tbl.ShortName = short
	QC.Classes[name] = tbl
	QC.ShortClasses[short] = tbl
	return tbl
end