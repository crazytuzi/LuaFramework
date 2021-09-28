----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;

------------------------------------------------------
local g_i3k_release_time = 5000;

i3k_ai_network_cache = i3k_class("i3k_ai_network_cache", BASE);
function i3k_ai_network_cache:ctor(entity)
	self._type = eAType_NETWORK_CACHE;
end

function i3k_ai_network_cache:OnAttach()
	self._entity._cacheable = true;
end

function i3k_ai_network_cache:OnDetach()
	self._entity._cacheable = false;
end

function i3k_ai_network_cache:IsValid()
	local entity = self._entity;

	if entity:IsInLeaveCache() then
		return true;
	end

	return false;
end

function i3k_ai_network_cache:CanAttackNoneTarget()
	return false;
end

function i3k_ai_network_cache:OnEnter()
	if BASE.OnEnter(self) then
		return true;
	end

	return false;
end

function i3k_ai_network_cache:OnLeave()
	if BASE.OnLeave(self) then
		local entity = self._entity;
		if entity:IsInLeaveCache() then
			local world = i3k_game_get_world();
			if world then
				if entity then
					world:RmvEntity(entity);
					entity:Release();
				end
			end
		else
			entity:ResetLeaveCache();
		end

		return true;
	end

	return false;
end

function i3k_ai_network_cache:OnUpdate(dTime)
	if not BASE.OnUpdate(self, dTime) then return false; end

	return true;
end

function i3k_ai_network_cache:OnLogic(dTick)
	if not BASE.OnLogic(self, dTick) then return false; end

	if dTick > 0 then
		local entity = self._entity;

		entity:UpdateCacheTime(dTick);

		if entity:GetLeaveCacheTime() > g_i3k_release_time then
			return false;
		end
	end

	return true;
end

function create_component(entity, priority)
	return i3k_ai_network_cache.new(entity, priority);
end
