--[[
	luaa_objects.luaa
	18.12.2015 14:29:51

	This file is a part of LuaAdvanced library.
	No license yet.

	Compiled using LuaAdvanced
	This file should not be modified.
]]

-- LUAA_Object class metatable
CLUAA_Object = { }
CLUAA_Object.__index = CLUAA_Object
CLUAA_Object.__type = "Object"
CLUAA_Object.__baseclasses = { }

function CLUAA_Object:GetType()
	return self.__type
end

function CLUAA_Object:__new(...)
    	self.__type = "Object"
	self.__baseclasses = { }

    
end
function LUAA_Object(...)
    local tbl = { }
    setmetatable(tbl, CLUAA_Object)
    tbl:__new(...);
    return tbl
end

