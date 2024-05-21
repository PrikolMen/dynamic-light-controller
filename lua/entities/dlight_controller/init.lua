AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
local SetNW2Var
do
	local _obj_0 = FindMetaTable("Entity")
	SetNW2Var = _obj_0.SetNW2Var
end
local IsDeathTime = ENT.IsDeathTime
CreateConVar("dlight_controllers", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY), "Enables light emission from dynamic light controllers.", 0, 1)
ENT.Think = function(self)
	if IsDeathTime(self) then
		self:Remove()
		return
	end
end
ENT.SetEnabled = function(self, enabled)
	return SetNW2Var(self, "enabled", enabled == true)
end
ENT.SetSprite = function(self, sprite)
	return SetNW2Var(self, "sprite", sprite)
end
ENT.SetRed = function(self, red)
	return SetNW2Var(self, "red", red)
end
ENT.SetGreen = function(self, green)
	return SetNW2Var(self, "green", green)
end
ENT.SetBlue = function(self, blue)
	return SetNW2Var(self, "blue", blue)
end
ENT.SetBrightness = function(self, brightness)
	return SetNW2Var(self, "brightness", brightness)
end
ENT.SetRadius = function(self, radius)
	return SetNW2Var(self, "radius", radius)
end
ENT.SetStyle = function(self, style)
	return SetNW2Var(self, "style", style)
end
ENT.SetNoModel = function(self, nomodel)
	return SetNW2Var(self, "nomodel", nomodel == true)
end
ENT.SetNoWorld = function(self, noworld)
	return SetNW2Var(self, "noworld", noworld == true)
end
ENT.SetSpriteAlpha = function(self, alpha)
	return SetNW2Var(self, "sprite-alpha", alpha or 255)
end
ENT.SetSpriteScale = function(self, scale)
	return SetNW2Var(self, "sprite-scale", scale or 1)
end
ENT.SetDecay = function(self, decay)
	return SetNW2Var(self, "decay", decay)
end
