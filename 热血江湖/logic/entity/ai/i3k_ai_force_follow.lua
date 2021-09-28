----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_follow").i3k_ai_follow;


------------------------------------------------------
i3k_ai_force_follow = i3k_class("i3k_ai_force_follow", BASE);
function i3k_ai_force_follow:ctor(entity)
	self._type = eAType_FORCE_FOLLOW;
end

function i3k_ai_force_follow:IsValid()
	if not BASE.IsValid(self) then return false; end

	local entity = self._entity;

	if entity._forceFollow then
		return true;
	end

	return false;
end

function create_component(entity, priority)
	return i3k_ai_force_follow.new(entity, priority);
end

