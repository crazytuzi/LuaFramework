------------------------------------------------------
--2018/08/01
------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = i3k_entity;
------------------------------------------------------
i3k_simple_entity = i3k_class("i3k_simple_entity", BASE);
function i3k_simple_entity:ctor(guid)
	self._entityType	= eET_Simple;
	self._guid			= guid
	self:CreateActor()
end

function i3k_simple_entity:Create(id)
	self:createModel(id)
end

function i3k_simple_entity:OnLogic(dTick)
	BASE.OnLogic(self, dTick);
end

function i3k_simple_entity:createModel(id)
	local mcfg = i3k_db_models[id];
	if mcfg then
		self._resCreated = 0
		if self._entity:CreateHosterModel(mcfg.path, string.format("simple_entity_%s", self._guid)) then
			self._baseScale = mcfg.scale;
			self:SetScale(self._baseScale);
			self._entity:EnterWorld(false)
		end
	end
end

function i3k_simple_entity:OnSelected(val)
	
end

function i3k_simple_entity:ValidInWorld()
	return true
end

function i3k_simple_entity:IsAttackable(attacker)
	return false;
end
