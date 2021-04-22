-- 技能 巨兽沼泽肉品管理
-- 技能ID 53338
--[[
	肉品管理员 4131
	升灵台 "巨兽沼泽"
	psf 2020-6-22
]]--

local shenglt_jushouzhaoze_controller = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return shenglt_jushouzhaoze_controller