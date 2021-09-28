----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_check_water = i3k_class("i3k_ai_check_water", BASE);
function i3k_ai_check_water:ctor(entity)
    self._type = eAType_CHECK_WATER;
    --水域配置
	self.checked = false
end

function i3k_ai_check_water:IsValid()
    local entity = self._entity;

    --只在移动的时候检测 进入场景时静止状态也默认检测一次
    if not entity._behavior:Test(eEBMove) and self.checked then
        return false;
    end

    local curPos = entity._curPosE;
    local posType = g_i3k_game_context:getSpringPos(curPos)
    if posType == SPRING_TYPE_WATER then
        entity:InWater(self.checked)
    elseif posType == SPRING_TYPE_LAND then
        entity:InLand(self.checked)
    else
        entity:SpringReset(self.checked)
    end

    self.checked = true

    return false;
end

function i3k_ai_check_water:OnEnter()
    if BASE.OnEnter(self) then
        return true;
    end

    return false;
end

function i3k_ai_check_water:OnLeave()
    if BASE.OnLeave(self) then
        return true;
    end
    return false;
end

function i3k_ai_check_water:OnUpdate(dTime)
    if BASE.OnUpdate(self, dTime) then
        return true;
    end

    return false;
end

function i3k_ai_check_water:OnLogic(dTick)
    if BASE.OnLogic(self, dTick) then
        return false;
    end
    return false;
end

function create_component(entity, priority)
    return i3k_ai_check_water.new(entity, priority);
end
