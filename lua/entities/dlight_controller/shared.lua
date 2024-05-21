local isnumber, isvector, IsColor, CurTime = _G.isnumber, _G.isvector, _G.IsColor, _G.CurTime
local GetNW2Var
do
	local _obj_0 = FindMetaTable("Entity")
	GetNW2Var = _obj_0.GetNW2Var
end
ENT.Type = "anim"
ENT.DLightController = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Initialize = function(self)
	return self:DrawShadow(false)
end
ENT.GetEnabled = function(self)
	return GetNW2Var(self, "enabled", self.__enabled or false)
end
ENT.GetSprite = function(self)
	return GetNW2Var(self, "sprite", self.__sprite or "")
end
ENT.GetRed = function(self)
	return GetNW2Var(self, "red", self.__red or 255)
end
ENT.GetGreen = function(self)
	return GetNW2Var(self, "green", self.__green or 255)
end
ENT.GetBlue = function(self)
	return GetNW2Var(self, "blue", self.__blue or 255)
end
ENT.GetBrightness = function(self)
	return GetNW2Var(self, "brightness", self.__brightness or 1)
end
ENT.GetRadius = function(self)
	return GetNW2Var(self, "radius", self.__radius or 256)
end
ENT.GetStyle = function(self)
	return GetNW2Var(self, "style", self.__style or 0)
end
ENT.GetNoModel = function(self)
	return GetNW2Var(self, "nomodel", self.__nomodel or false)
end
ENT.GetNoWorld = function(self)
	return GetNW2Var(self, "noworld", self.__noworld or false)
end
ENT.GetSpriteAlpha = function(self)
	return GetNW2Var(self, "sprite-alpha", self.__sprite_alpha or 255)
end
ENT.GetSpriteScale = function(self)
	return GetNW2Var(self, "sprite-scale", self.__sprite_scale or 1)
end
ENT.GetDecay = function(self)
	return GetNW2Var(self, "decay", self.__decay or 1)
end
ENT.SetLightColor = function(self, r, g, b)
	if IsColor(r) then
		self:SetRed(r.r)
		self:SetGreen(r.g)
		self:SetBlue(r.b)
		return
	end
	if isvector(r) then
		self:SetRed(r[1] * 255)
		self:SetGreen(r[2] * 255)
		self:SetBlue(r[3] * 255)
		return
	end
	self:SetRed(r)
	self:SetGreen(g)
	self:SetBlue(b)
	return
end
local inf = 1 / 0
ENT.GetLifetime = function(self)
	if self.DeathTime then
		return self.DeathTime - CurTime()
	end
	return inf
end
ENT.SetLifetime = function(self, time)
	if isnumber(time) then
		self.DeathTime = CurTime() + time
		return
	end
	self.DeathTime = nil
end
ENT.IsDeathTime = function(self)
	if self.DeathTime == nil then
		return false
	end
	return CurTime() > self.DeathTime
end
