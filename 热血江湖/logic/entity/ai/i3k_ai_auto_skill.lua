----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_auto_skill = i3k_class("i3k_ai_auto_skill", BASE);
function i3k_ai_auto_skill:ctor(entity)
	self._type	= eAType_AUTO_SKILL;
end

function i3k_ai_auto_skill:IsValid()
	local entity = self._entity;
	local hoster = entity._hoster
	return entity:CanUseSkill() and not entity._curSkill or entity._maunalSkill;
end

function i3k_ai_auto_skill:OnEnter()
	if BASE.OnEnter(self) then
		self:SetSkill();

		return true;
	end

	return false;
end

function i3k_ai_auto_skill:OnLeave()
	if BASE.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_ai_auto_skill:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_auto_skill:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end

	return false;
end

function i3k_ai_auto_skill:SetSkill()
	local entity = self._entity;

	if entity._maunalSkill then
		entity:UseSkill(entity._maunalSkill);

		entity._maunalSkill = nil;
	else
		local nid = entity._attackID + 1;
		if nid == nil or nid < 1 or nid > #entity._attackLst then
			nid = 1;
		end

		local sid = entity._attackLst[nid];
		if sid then
			local skill = nil;
			if sid == 0 then
				skill = entity:GetAttackSkill();
			else
				skill = entity._skills[sid];
			end

			if skill then
				entity._attackID = nid;

				entity:UseSkill(skill);
			end
		end
	end
end

function create_component(entity, priority)
	return i3k_ai_auto_skill.new(entity, priority);
end
