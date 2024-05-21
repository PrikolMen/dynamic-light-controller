local addonName = "Dynamic Light Controller"
include("shared.lua")
ENT.SetEnabled = function(self, enabled)
	self.__enabled = enabled == true
end
ENT.SetSprite = function(self, sprite)
	self.__sprite = sprite
end
ENT.SetRed = function(self, red)
	self.__red = red or 0
end
ENT.SetGreen = function(self, green)
	self.__green = green or 0
end
ENT.SetBlue = function(self, blue)
	self.__blue = blue or 0
end
ENT.SetBrightness = function(self, brightness)
	self.__brightness = brightness or 1
end
ENT.SetRadius = function(self, radius)
	self.__radius = radius or 256
end
ENT.SetStyle = function(self, style)
	self.__style = style or 0
end
ENT.SetNoModel = function(self, nomodel)
	self.__nomodel = nomodel == true
end
ENT.SetNoWorld = function(self, noworld)
	self.__noworld = noworld == true
end
ENT.SetSpriteAlpha = function(self, alpha)
	self.__sprite_alpha = alpha or 255
end
ENT.SetSpriteScale = function(self, scale)
	self.__sprite_scale = scale or 1
end
ENT.SetDecay = function(self, decay)
	self.__decay = decay
end
local dlight_controllers = CreateConVar("dlight_controllers", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY), "Enables light emission from dynamic light controllers.", 0, 1)
local GetRed, GetGreen, GetBlue = ENT.GetRed, ENT.GetGreen, ENT.GetBlue
local ENTITY = FindMetaTable("Entity")
local VECTOR = FindMetaTable("Vector")
local GetPos = ENTITY.GetPos
local radius = 0
local getCalculatedRadius, getCalculatedBrightness
do
	local GetEnabled, GetRadius, GetBrightness = ENT.GetEnabled, ENT.GetRadius, ENT.GetBrightness
	local GetLightColor = render.GetLightColor
	local FindByClass = ents.FindByClass
	local DistToSqr = VECTOR.DistToSqr
	local IsDormant = ENTITY.IsDormant
	local TraceLine = util.TraceLine
	local sort = table.sort
	local EyePos = _G.EyePos
	local abs = math.abs
	hook.Add("PostCleanupMap", addonName, function()
		if dlight_controllers:GetBool() then
			return
		end
		local _list_0 = FindByClass("dlight_controller")
		for _index_0 = 1, #_list_0 do
			local entity = _list_0[_index_0]
			entity:Remove()
		end
	end)
	getCalculatedRadius = function(self)
		return self.__calculatedRadius or GetRadius(self)
	end
	getCalculatedBrightness = function(self)
		return self.__calculatedBrightness or GetBrightness(self)
	end
	ENT.GetCalculatedRadius = getCalculatedRadius
	local sqrCache = setmetatable({ }, {
		__index = function(tbl, key)
			rawset(tbl, key, key * key)
			return tbl[key]
		end
	})
	local dlight_controllers_distance = CreateClientConVar("dlight_controllers_distance", "2048", true, false, "Maximum distance to calculate dynamic lights.", 16, 4096)
	local maxDistance = dlight_controllers_distance:GetInt()
	local maxDistanceSqr = sqrCache[maxDistance]
	cvars.AddChangeCallback(dlight_controllers_distance:GetName(), function(_, __, value)
		maxDistance = math.floor(tonumber(value) or dlight_controllers_distance:GetDefault())
		maxDistanceSqr = sqrCache[maxDistance]
	end, addonName)
	local dlight_controllers_update = CreateClientConVar("dlight_controllers_update", "5", true, false, "Dynamic light update speed.", 0, 100)
	cvars.AddChangeCallback(dlight_controllers_update:GetName(), function(_, __, value)
		return timer.Adjust(addonName, 1 / (tonumber(value) or dlight_controllers_update:GetDefault()), 0)
	end, addonName)
	local sortByDistance
	sortByDistance = function(a, b)
		return a[8] < b[8]
	end
	local brightness, distance = 0, 0
	local temp, tempLength = { }, 0
	local dlights, length = { }, 0
	local controllerCount = 0
	local r, g, b = 0, 0, 0
	local traceResult = { }
	local trace = {
		collisiongroup = COLLISION_GROUP_WORLD,
		output = traceResult
	}
	timer.Create(addonName, 1 / dlight_controllers_update:GetFloat(), 0, function()
		if tempLength ~= 0 then
			for index = 1, tempLength do
				temp[index] = nil
			end
			tempLength = 0
		end
		local controllers = FindByClass("dlight_controller")
		controllerCount = #controllers
		if controllerCount == 0 then
			return
		end
		if not dlight_controllers:GetBool() then
			for index = 1, controllerCount do
				local entity = controllers[index]
				entity.__illuminates = false
				entity.__visible = false
			end
			return
		end
		local eyePos = EyePos()
		for index = 1, controllerCount do
			local entity = controllers[index]
			entity.__illuminates = false
			entity.__visible = false
			if not GetEnabled(entity) or IsDormant(entity) then
				goto _continue_0
			end
			local origin = GetPos(entity)
			distance = DistToSqr(origin, eyePos)
			if distance > maxDistanceSqr then
				goto _continue_0
			end
			trace.start = origin
			trace.endpos = origin
			TraceLine(trace)
			if traceResult.HitWorld then
				goto _continue_0
			end
			local color
			brightness, color, r, g, b = GetBrightness(entity), GetLightColor(origin) * 255, GetRed(entity), GetGreen(entity), GetBlue(entity)
			if (color[1] + color[2] + color[3]) > (r + g + b + 48) * brightness then
				goto _continue_0
			end
			tempLength = tempLength + 1
			temp[tempLength] = {
				entity,
				origin,
				GetRadius(entity),
				brightness,
				r,
				g,
				b,
				distance
			}
			entity.__visible = true
			::_continue_0::
		end
		if tempLength == 0 then
			return
		end
		if tempLength == 1 then
			local entity = temp[1][1]
			entity.__illuminates = true
			entity.__calculatedRadius = temp[3]
			entity.__calculatedBrightness = temp[4]
			return
		end
		for index = 1, tempLength do
			local data = temp[index]
			if not data then
				goto _continue_1
			end
			radius = data[3]
			brightness = data[4]
			local radiusSqr = sqrCache[radius * 0.5]
			r, g, b = data[5], data[6], data[7]
			local origin = data[2]
			for index2 = 1, tempLength do
				if index == index2 then
					goto _continue_2
				end
				local data2 = temp[index2]
				if not data2 or radius < data2[3] then
					goto _continue_2
				end
				distance = DistToSqr(origin, data2[2])
				if distance > radiusSqr then
					goto _continue_2
				end
				if abs(r - data2[5]) < 8 and abs(g - data2[6]) < 8 and abs(b - data2[7]) < 8 then
					temp[index2] = false
					radius = radius + (data2[3] / 2)
					brightness = brightness + (data2[4] / 10)
					if distance <= (radiusSqr * 0.25) then
						local entity = data2[1]
						entity.__visible = false
						entity.__calculatedRadius = radius
					end
				end
				::_continue_2::
			end
			if radius > maxDistance then
				radius = maxDistance
			end
			if brightness > 5 then
				brightness = 5
			end
			data[3], data[4] = radius, brightness
			::_continue_1::
		end
		length = 0
		for index = 1, tempLength do
			if temp[index] == false then
				goto _continue_3
			end
			length = length + 1
			dlights[length] = temp[index]
			::_continue_3::
		end
		if length == 0 then
			return
		end
		if length > 32 then
			sort(dlights, sortByDistance)
			length = 32
		end
		for index = 1, length do
			local data = dlights[index]
			local entity = data[1]
			entity.__illuminates = true
			entity.__calculatedRadius = data[3]
			entity.__calculatedBrightness = data[4]
		end
	end)
end
local getIndex
do
	local clientIndexes = { }
	hook.Add("EntityRemoved", addonName, function(entity)
		local index = entity.DLightIndex
		if not index or clientIndexes[index] ~= entity then
			return
		end
		clientIndexes[index] = nil
	end)
	local EntIndex, GetParent = ENTITY.EntIndex, ENTITY.GetParent
	local index = 0
	getIndex = function(entity)
		index = entity.DLightIndex or EntIndex(entity)
		if index == -1 then
			local parent = GetParent(entity)
			if parent:IsValid() then
				index = EntIndex(parent)
			end
			if index == -1 then
				index = 8192
				::findIndex::
				local otherEntity = clientIndexes[index]
				if otherEntity and otherEntity:IsValid() and otherEntity ~= entity then
					index = index + 1
					goto findIndex
				end
				clientIndexes[index] = entity
				entity.DLightIndex = index
			end
		end
		return index
	end
	ENT.GetIndex = getIndex
end
local GetSprite = ENT.GetSprite
do
	local GetStyle, GetNoModel, GetNoWorld, IsDeathTime, GetDecay = ENT.GetStyle, ENT.GetNoModel, ENT.GetNoWorld, ENT.IsDeathTime, ENT.GetDecay
	local DynamicLight, CurTime, Vector = _G.DynamicLight, _G.CurTime, _G.Vector
	local SetRenderBounds = ENTITY.SetRenderBounds
	local SetUnpacked = VECTOR.SetUnpacked
	local mins, maxs = Vector(-1, -1, -1), Vector(1, 1, 1)
	local decay = 0
	ENT.Think = function(self)
		if IsDeathTime(self) then
			self:Remove()
			return
		end
		self:LightThink()
		if not self.__illuminates then
			return
		end
		local dlight = DynamicLight(getIndex(self))
		if not dlight then
			return
		end
		decay = GetDecay(self)
		dlight.decay = decay * 1000
		dlight.dietime = CurTime() + decay
		dlight.r, dlight.g, dlight.b = GetRed(self), GetGreen(self), GetBlue(self)
		dlight.nomodel, dlight.noworld = GetNoModel(self), GetNoWorld(self)
		dlight.brightness = getCalculatedBrightness(self)
		dlight.size = getCalculatedRadius(self)
		dlight.style = GetStyle(self)
		dlight.pos = GetPos(self)
		if GetSprite(self) == "" then
			return
		end
		radius = getCalculatedRadius(self)
		SetUnpacked(mins, -radius, -radius, -radius)
		SetUnpacked(maxs, radius, radius, radius)
		return SetRenderBounds(self, mins, maxs)
	end
end
do
	local GetSpriteAlpha, GetSpriteScale = ENT.GetSpriteAlpha, ENT.GetSpriteScale
	local DrawSprite, SetMaterial = render.DrawSprite, render.SetMaterial
	local color = Color(0, 0, 0)
	local materialCache = { }
	ENT.Draw = function(self)
		if self.__visible then
			local materialPath = GetSprite(self)
			if materialPath == "" then
				return
			end
			if not materialCache[materialPath] then
				materialCache[materialPath] = Material(materialPath)
			end
			SetMaterial(materialCache[materialPath])
			color.r, color.g, color.b, color.a = GetRed(self), GetGreen(self), GetBlue(self), GetSpriteAlpha(self)
			radius = getCalculatedRadius(self) * GetSpriteScale(self)
			return DrawSprite(GetPos(self), radius, radius, color)
		end
	end
end
ENT.LightThink = function() end
