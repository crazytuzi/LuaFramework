--[[
        @Date    : 2019-03-02
        @Author  : zhangbing
        @Explain : copy form Japan version
--]]
----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_check_arrival_target = i3k_class("i3k_ai_check_arrival_target", BASE);
function i3k_ai_check_arrival_target:ctor(entity)
    self._type = eAType_CHECK_ARRIVAL_TARGET;
end

local moveFlag = {
	eAType_MOVE,
	eAType_NETWORK_MOVE,
	eAType_SKILLENTITY_MOVE,
}
function i3k_ai_check_arrival_target:IsValid()
    local entity = self._entity;
	local findPathData = entity._findPathData
	
	if findPathData and findPathData.endPos and g_i3k_game_context:Caculator(entity._curPosE, findPathData.endPos, findPathData.fadeDistance) 
	and findPathData.checkFlag then
		findPathData.checkFlag  = false
		
		if findPathData.entityFlag then
			g_i3k_coroutine_mgr:StartCoroutine(function()	
				g_i3k_coroutine_mgr.WaitForSeconds(500 / 1000)--i3k_db_common.npcFadeTime / 1000)
				local world = i3k_game_get_world()
				
				if world then
					world:ReleaseEntity(entity)
				end					
			end)
		elseif findPathData.aiFlag then
			entity:RmvAiComp(eAType_AUTO_MOVE)			
			for	_, v in ipairs(moveFlag) do
				if entity._aiController._childs[v] then
					entity._movable = true
					break
				end
			end
		end
		
		if findPathData.callBack then
			local callback = findPathData.callBack		
			callback()
		end
		
	end

	return false;
end

function i3k_ai_check_arrival_target:OnEnter()
    if BASE.OnEnter(self) then
        return true;
    end

    return false;
end

function i3k_ai_check_arrival_target:OnLeave()	
	if BASE.OnLeave(self) then
        return true;
    end
	
    return false;
end

function i3k_ai_check_arrival_target:OnUpdate(dTime)
    if BASE.OnUpdate(self, dTime) then
        return true;
    end

    return false;
end

function i3k_ai_check_arrival_target:OnLogic(dTick)
    if BASE.OnLogic(self, dTick) then
        return false;
    end
	
    return false;
end

function create_component(entity, priority)
    return i3k_ai_check_arrival_target.new(entity, priority);
end

