----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_autofight_stunt_skill = i3k_class("i3k_ai_autofight_stunt_skill", BASE);
function i3k_ai_autofight_stunt_skill:ctor(entity)
	self._type	= eAType_AUTOFIGHT_STUNT_SKILL;
end

function i3k_ai_autofight_stunt_skill:IsValid()
	local entity = self._entity;
	if entity._AutoFight == false then
		return false
	end
	if entity:IsDead() or not entity:CanAttack() then
		return false;
	end
	if not entity._weapon or not entity._weapon.valid then
		return false
	end

	if entity._missionMode.valid then
		return false
	end
	
	if entity._superMode.valid then
		return entity:CanUseSkill() and not entity._curSkill or entity._maunalSkill;
	end


	return false;
end

function i3k_ai_autofight_stunt_skill:OnEnter()
	if BASE.OnEnter(self) then
		if self._entity._superMode.valid then
			self:SetSkill();
		end
		return true;
	end

	return false;
end

function i3k_ai_autofight_stunt_skill:OnLeave()
	if BASE.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_ai_autofight_stunt_skill:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_autofight_stunt_skill:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end

	return false;
end

function i3k_ai_autofight_stunt_skill:SetSkill()
	local entity = self._entity;

	local skill = entity._weapon.skills[entity._superMode.attacks];
	if skill then
		entity:UseSkill(skill);
	end
end

function create_component(entity, priority)
	return i3k_ai_autofight_stunt_skill.new(entity, priority);
end
