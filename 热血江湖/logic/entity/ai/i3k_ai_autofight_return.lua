----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_autofight_return = i3k_class("i3k_ai_autofight_return", BASE);
function i3k_ai_autofight_return:ctor(entity)
	self._type		= eAType_AUTOFIGHT_RETURN;
	self._target	= nil;
end

function i3k_ai_autofight_return:IsValid()
	local entity = self._entity;
	if not entity._AutoFight then
		return false;
	end
	if entity:IsDead() or not entity:CanAttack() then
		return false;
	end

	local world = i3k_game_get_world();
	if world._mapType and not i3k_db_common.autoFight.autoFightSetMap[world._mapType] then
		return false
	end
	
	local value = g_i3k_game_context:getAutoFightRadius()
	if value and value ~= g_OneMap then
		local autoFightRadius = i3k_db_common.autoFight.autoFightRadius[value or 1]
		local dist = i3k_vec3_dist(entity._curPos,entity._AutoFight_Point)
		local enmities = entity:GetEnmities();
		local isRetreat = false;
		if enmities then
			if enmities[1] and enmities[1]:GetEntityType() == eET_Player and  enmities[1]:IsDead() then
				isRetreat = true;
			end
		end
		if dist > autoFightRadius or isRetreat then
			return true;
		end
	end
	return false;
end

function i3k_ai_autofight_return:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity;
		entity:MoveTo(i3k_logic_pos_to_world_pos(entity._AutoFight_Point))
		entity._behavior:Set(eEBRetreat);

		return true;
	end

	return false;
end

function i3k_ai_autofight_return:OnLeave()
	if BASE.OnLeave(self) then
		self._target = nil;

		return true;
	end

	return false;
end

function i3k_ai_autofight_return:OnUpdate(dTime)
	if BASE.OnUpdate(self, dTime) then
		return true;
	end

	return false;
end

function i3k_ai_autofight_return:OnLogic(dTick)
	if BASE.OnLogic(self, dTick) then
		return false; -- only one frame
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_autofight_return.new(entity, priority);
end

