----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_manual_skill = i3k_class("i3k_ai_manual_skill", BASE);
function i3k_ai_manual_skill:ctor(entity)
	self._type	= eAType_MANUAL_SKILL;
end

function i3k_ai_manual_skill:IsValid()
	local entity = self._entity;

	return entity._maunalSkill;
end

function i3k_ai_manual_skill:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;

		entity:UseSkill(self._entity._maunalSkill);

		return true;
	end

	return false;
end

function i3k_ai_manual_skill:OnLeave()
	if BASE.OnLeave(self) then
		local entity = self._entity;

		entity:ResetMaunalAttack();

		return true;
	end

	return false;
end

function i3k_ai_manual_skill:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_manual_skill:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_manual_skill.new(entity, priority);
end
