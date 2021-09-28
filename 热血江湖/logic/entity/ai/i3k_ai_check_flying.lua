----------------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/entity/ai/i3k_ai_base").i3k_ai_base;


------------------------------------------------------
i3k_ai_check_flying = i3k_class("i3k_ai_check_flying", BASE);
function i3k_ai_check_flying:ctor(entity)
    self._type = eAType_CHECK_FLYING;
	self.checked = false
end

function i3k_ai_check_flying:IsValid()
    local entity = self._entity;

    --只在移动的时候检测 进入场景时静止状态也默认检测一次
    if not entity._behavior:Test(eEBMove) and self.checked then
        return false;
    end

    local curPos = entity._curPosE;
    local areaId = g_i3k_db.i3k_db_check_enter_flying_arena(curPos)
    if areaId then
		g_i3k_logic:OpenRoleFlyingFind(areaId)
    else
		g_i3k_ui_mgr:CloseUI(eUIID_RoleFlyingFind)
    end

    self.checked = true

    return false;
end

function create_component(entity, priority)
    return i3k_ai_check_flying.new(entity, priority);
end
