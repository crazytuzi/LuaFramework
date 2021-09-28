----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_spa = i3k_class("i3k_ai_spa", BASE);
function i3k_ai_spa:ctor(entity)
	self._type = eAType_SPA;
end

function i3k_ai_spa:IsValid()
	if not BASE.IsValid(self) then return false; end

	return self._entity._behavior:Test(eEBSpasticity);
end

function i3k_ai_spa:OnEnter()
	if BASE.OnEnter(self) then
        local alist = {}
		table.insert(alist, {actionName = i3k_db_common.engine.defaultHurtAction, actloopTimes = 1})
        table.insert(alist, {actionName = i3k_db_common.engine.defaultAttackIdleAction, actloopTimes = -1})		
		self._entity:PlayActionList(alist, 1);

		return true;
	end

	return false;
end

function i3k_ai_spa:OnLeave()
	if BASE.OnLeave(self) then
		self._entity._behavior:Clear(eEBSpasticity);

		return true;
	end

	return false;
end

function i3k_ai_spa:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		if self._timeTick > i3k_db_common.skill.spa.arg1 then
			return false;
		end

		return true;
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_spa.new(entity, priority);
end

