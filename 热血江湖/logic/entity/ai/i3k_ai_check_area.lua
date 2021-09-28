----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_check_area = i3k_class("i3k_ai_check_area", BASE);
function i3k_ai_check_area:ctor(entity)
    self._type = eAType_CHECK_AREA;
	self.checked = false
end

function i3k_ai_check_area:IsValid()
    local entity = self._entity;

    --只在移动的时候检测 进入场景时静止状态也默认检测一次
    if not entity._behavior:Test(eEBMove) and self.checked then
        return false;
    end

    local curPos = entity._curPosE;
    local areaType, facePos = g_i3k_db.i3k_db_get_area_type_arg(curPos)
    -- i3k_log("i3k_ai_check_area areaType: "..areaType)
    entity:onAreaType(self.checked, areaType, facePos)

    self.checked = true

    return false;
end

function i3k_ai_check_area:OnEnter()
    if BASE.OnEnter(self) then
        return true;
    end

    return false;
end

function i3k_ai_check_area:OnLeave()
    if BASE.OnLeave(self) then
        return true;
    end
    return false;
end

function i3k_ai_check_area:OnUpdate(dTime)
    if BASE.OnUpdate(self, dTime) then
        return true;
    end

    return false;
end

function i3k_ai_check_area:OnLogic(dTick)
    if BASE.OnLogic(self, dTick) then
        return false;
    end
    return false;
end

function create_component(entity, priority)
    return i3k_ai_check_area.new(entity, priority);
end
