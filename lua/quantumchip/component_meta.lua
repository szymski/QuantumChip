/*--------------------------------
	Component metatable
----------------------------------*/

local META = { }
META.__index = META

/*--------------------------------
	Functions
----------------------------------*/

function META:AddInlineFunction(name, params, ret, inline)

end

function META:AddInlineOperator(...)
	QC.AddInlineOperator(self, ...)
end

function META:AddPreparedOperator(...)
	QC.AddPreparedOperator(self, ...)
end

/*--------------------------------
	Creation
----------------------------------*/

function QC.CreateComponent(name) 
	local tbl = { }
	setmetatable(tbl, META)
	tbl.Name = name
	tbl.Description = ""
	tbl.Author = ""
	QC.Components[#QC.Components+1] = tbl
	return tbl
end