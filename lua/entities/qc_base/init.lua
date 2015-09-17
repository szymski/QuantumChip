/*--------------------------------
	QC entity base serverside
----------------------------------*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/bull/gates/processor.mdl")

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetUseType(SIMPLE_USE)

	self:SetScript([[
server {
	int lol = print(123)
}
	]], "Test script")

end

function ENT:SetScript(script, name)
	local code, line, char, err = QC.Compiler():Compile(script)

    if !code then
    	print("ERROR!    -    Line: " .. line .. ", Char: " .. char .. " - " .. err)
    	return
    end

    print(code)

    local func = CompileString(code, "QC", false)

    if isstring(func) then
    	print("Compilation error!    -    " .. func)
    	return
    end

    self.Context = QC.Context(self)
    self.Context:Init(func())

end
