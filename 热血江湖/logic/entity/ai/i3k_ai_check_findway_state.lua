module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;

------------------------------------------------------
i3k_ai_check_findway_state = i3k_class("i3k_ai_check_findway_state", BASE);


function i3k_ai_check_findway_state:ctor(entity)
    self._type = eAType_CHECK_FINDWAY_STATE;	
	self._mapType = i3k_game_get_map_type()
	
	self._checkMethod = 
	{
		[g_PRINCESS_MARRY] = {check = g_i3k_game_context.getPrincessMarryFindWayState, set = g_i3k_game_context.setPrincessMarryFindWayState, findway = g_i3k_game_context.gotoPrincessPos,} 
	}
end

function i3k_ai_check_findway_state:IsValid()
    local entity = self._entity;
	
	if entity:GetEntityType() ~= eET_Player then
		return false
	end
	
	if not self._checkMethod[self._mapType] then
		return false
	end
	
	local m = self._checkMethod[self._mapType]
	
	if not entity:GetFindWayStatus() then
		m.set(g_i3k_game_context, false)
		return
	end
	
	if not entity:getdynamicfindwayflag() then
		return false
	end
		
	if m.check(g_i3k_game_context) then
		m.findway(g_i3k_game_context)
		entity:setdynamicfindwayflag(false)
	end
	
	return false;
end

function i3k_ai_check_findway_state:OnEnter()
    if BASE.OnEnter(self) then
        return true;
    end

    return false;
end

function i3k_ai_check_findway_state:OnLeave()	
	if BASE.OnLeave(self) then
        return true;
    end
	
    return false;
end

function i3k_ai_check_findway_state:OnUpdate(dTime)
    if BASE.OnUpdate(self, dTime) then
        return true;
    end

    return false;
end

function i3k_ai_check_findway_state:OnLogic(dTick)
    if BASE.OnLogic(self, dTick) then
        return false;
    end
	
    return false;
end

function create_component(entity, priority)
    return i3k_ai_check_findway_state.new(entity, priority);
end

