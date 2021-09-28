require "Core.Role.ModelCreater.BaseModelCreater"
RideModelCreater = class("RideModelCreater", BaseModelCreater);

function RideModelCreater:New(data, parent)
	self = {};
	setmetatable(self, {__index = RideModelCreater});
	if data and parent then self:Init(data, parent) end
	return self;
end

--
function RideModelCreater:_Init(data)
	self.onEnableOpen = true
	self.model_id = data.model_id
	--self.checkAnimation = false
end

function RideModelCreater:_GetModern()
	return "Roles", tostring(self.model_id)
end


function RideModelCreater:_GetSourceDir()
	return "Mounts"
end

function RideModelCreater:GetDefaultAction()
	return "stand"
end

function RideModelCreater:_CanPoolMode()
	return self._psScaleState ~= 2 and not self.useHeroShader
end
function RideModelCreater:SetHeroShader()
	self.useHeroShader = true
end
function RideModelCreater:_InitAvtar()
	--Warning("_InitAvtar,==" ..tostring(self.useHeroShader) .. tostring(self._roleAvtar) )
	self:_OnModeInited()
	if self.useHeroShader and self._roleAvtar then
		self._roleAvtar:ChangeShader(self._role)
	end
end

-- function RideModelCreater:_OnModelLoaded()
-- 	if not IsNil(self._role) then
-- 		self._roleAnimator = self._role:GetComponent("Animator");		
-- 		if self.checkAnimation then self:_InitAnimation() end
-- 		self:_SetSelfLayer()
-- 		self:_UpdateActive();		
-- 	end
-- end
