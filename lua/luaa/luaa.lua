--[[
	luaa.luaa
	18.12.2015 14:29:54

	This file is a part of LuaAdvanced library.
	No license yet.

	Compiled using LuaAdvanced
	This file should not be modified.
]]

if((luaa and luaa.GetVersion() >= 1)) then
	return
end

luaa = { }
include("luaa/luaa_objects.lua")
function luaa.GetVersion()
	return 1

end
function luaa.GetType(object)
	if(object.GetType) then
		return object:GetType()
	else
		return type(object)
	end
	

end
function luaa.Inherit(classMeta, baseClass)
	
	for k, v in pairs(baseClass) do
		if(k:sub(1, 2) ~= "__") then
		classMeta[k] = v
	end
	
	
	end
	
	
	for _, v in pairs(baseClass.__baseclasses) do
		classMeta.__baseclasses[#classMeta.__baseclasses + 1] = v
	
	end
	
	classMeta.__baseclasses[#classMeta.__baseclasses + 1] = baseClass.__type

end
function luaa.IsSubclassOf(object, type)
	local objectType = luaa.GetType(object)
	if(objectType == type) then
		return true
	end
	
	
	for _, v in pairs(object.__baseclasses) do
		if(v == type) then
		return true
	end
	
	
	end
	
	return false

end
include("luaa/luaa_enumerable.lua")

