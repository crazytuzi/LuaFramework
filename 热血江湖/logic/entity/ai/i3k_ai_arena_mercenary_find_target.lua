----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_arena_mercenary_find_target = i3k_class("i3k_ai_arena_mercenary_find_target", BASE);
function i3k_ai_arena_mercenary_find_target:ctor(entity)
	self._type = eAType_FOLLOW;
	self._target	= nil;
end

function i3k_ai_arena_mercenary_find_target:IsValid()
	local entity = self._entity
	
	if entity:IsDead() or not entity:CanAttack() then
		return false;
	end

	local enmities = entity:GetEnmities();
	if enmities then
		if enmities[1] then
			return false
		end
	end
	
	local posId = entity._posId
	if entity and entity._alives[2] then
		local target = nil;
		for i,v in ipairs(entity._alives[2]) do
			if v.entity._posId == posId and not v.entity:IsDead() then
				target = v.entity
				break;
			end
		end
		
		if not target then
			local rndNum = i3k_engine_get_rnd_u(1, #entity._alives[2]);
			local rndTarget = entity._alives[2][rndNum];
			if rndTarget and rndTarget.entity and not rndTarget.entity:IsDead() then
				target = rndTarget.entity;
			end
		end
		if target then
			self._target = target;
			return true;
		end
	end
	
	return false;
end

function i3k_ai_arena_mercenary_find_target:OnEnter()
	if BASE.OnEnter(self) then
		local entity = self._entity
		if self._target then
			entity:AddEnmity(self._target);
			return true;
		end
	end

	return false;
end

function i3k_ai_arena_mercenary_find_target:OnLogic(dTick)
	return false;
end

function create_component(entity, priority)
	return i3k_ai_arena_mercenary_find_target.new(entity, priority);
end

