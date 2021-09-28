----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;
require("logic/entity/i3k_entity_itemdrop_def");

------------------------------------------------------
i3k_ai_pet_check_alive = i3k_class("i3k_ai_pet_check_alive", BASE);
function i3k_ai_pet_check_alive:ctor(entity)
	self._type = eAType_PET_CHECK_ALIVE;
end

function i3k_ai_pet_check_alive:IsValid()
	if not BASE.IsValid(self) then return false; end
	--i3k_log("GetAliveTick:"..self._entity:GetAliveTick().."|"..self._entity:GetAliveDuration())
	return not self._entity:IsDead() and self._entity:GetAliveTick() > self._entity:GetAliveDuration();
end

function i3k_ai_pet_check_alive:OnEnter()
	if BASE.OnEnter(self) then
		self._entity:OnDead();

		return true;
	end

	return false;
end

function i3k_ai_pet_check_alive:OnLeave()
	if BASE.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_ai_pet_check_alive:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false;
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_pet_check_alive.new(entity, priority);
end

