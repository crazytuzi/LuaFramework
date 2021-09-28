----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_retreat = i3k_class("i3k_ai_guard", BASE);
function i3k_ai_retreat:ctor(entity)
	self._type = eAType_RETREAT;
end

function i3k_ai_retreat:IsValid()
	if not BASE.IsValid(self) then return false; end

	local entity = self._entity;

	if entity:IsDead() then
		return false;
	end

	if entity:GetEntityType() ~= eET_Monster then
		return false;
	end

	if entity._behavior:Test(eEBRetreat) then
		return false;
	end

	local dist = i3k_vec3_dist(entity._curPos, entity._birthPos);

	return dist > entity._cfg.traceDist;
end

function i3k_ai_retreat:OnEnter()
	if BASE.OnEnter(self) then
		self._entity._behavior:Set(eEBRetreat);

		return true;
	end

	return false;
end

function i3k_ai_retreat:OnLogic(dTick)
	if not BASE.OnLogic(self, dTick) then return false; end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_retreat.new(entity, priority);
end

