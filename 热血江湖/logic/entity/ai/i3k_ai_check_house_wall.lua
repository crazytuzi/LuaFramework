----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_check_house_wall = i3k_class("i3k_ai_check_house_wall", BASE);
function i3k_ai_check_house_wall:ctor(entity)
    self._type = eAType_CHECK_HOUSE_WALL;
	self.checked = false
end

function i3k_ai_check_house_wall:IsValid()
    local entity = self._entity;

    --只在移动的时候检测 进入场景时静止状态也默认检测一次
    if not entity._behavior:Test(eEBMove) and self.checked then
        return false;
    end

    local curPos = entity._curPosE;
    local areaType, areaId = g_i3k_db.i3k_db_get_house_wall_arena(curPos)
    if areaType == g_HOUSE_WALL_AREA then
        entity:EnterHouseWallArea(areaId)
    else
        entity:LeaveHouseWallArea()
    end

    self.checked = true

    return false;
end

function i3k_ai_check_house_wall:OnEnter()
    if BASE.OnEnter(self) then
        return true;
    end

    return false;
end

function i3k_ai_check_house_wall:OnLeave()
    if BASE.OnLeave(self) then
        return true;
    end
    return false;
end

function i3k_ai_check_house_wall:OnUpdate(dTime)
    if BASE.OnUpdate(self, dTime) then
        return true;
    end

    return false;
end

function i3k_ai_check_house_wall:OnLogic(dTick)
    if BASE.OnLogic(self, dTick) then
        return false;
    end
    return false;
end

function create_component(entity, priority)
    return i3k_ai_check_house_wall.new(entity, priority);
end
