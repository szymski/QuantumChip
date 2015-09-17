/*-----------------------------------------------------------
	Quantum Chip
-------------------------------------------------------------*/

local Config = MATQConfig

if SERVER then
	AddCSLuaFile()
	AddCSLuaFile("quantumchip/core.lua")
	AddCSLuaFile("quantumchip/compiler/preprocessor.lua")
	AddCSLuaFile("quantumchip/compiler/instructions.lua")
	AddCSLuaFile("quantumchip/compiler/parser.lua")
	AddCSLuaFile("quantumchip/compiler/compiler.lua")
	AddCSLuaFile("quantumchip/compiler/tokenizer.lua")
	AddCSLuaFile("quantumchip/compiler/tokenizer_spec.lua")
	AddCSLuaFile("quantumchip/context.lua")
	AddCSLuaFile("quantumchip/component_meta.lua")
	AddCSLuaFile("quantumchip/class_meta.lua")
	AddCSLuaFile("quantumchip/components/core.lua")

	CreateConVar("qc_ver", 1, FCVAR_NOTIFY)
end

include("quantumchip/core.lua")