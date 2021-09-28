----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_idle_just_stand = i3k_class("i3k_ai_idle_just_stand", BASE);
function i3k_ai_idle_just_stand:ctor(entity)
	self._type = eAType_IDLE_STAND;
end

function i3k_ai_idle_just_stand:OnEnter()
	if BASE.OnEnter(self) then
		local alist = {}
		table.insert(alist, {actionName = i3k_db_common.engine.defaultStandAction, actloopTimes = -1})
		self._entity:PlayActionList(alist, 1)

		return true;
	end

	return false;
end

function i3k_ai_idle_just_stand:OnLeave()
	if BASE.OnLeave(self) then
		return true;
	end

	return false;
end

function i3k_ai_idle_just_stand:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_idle_just_stand.new(entity, priority);
end

