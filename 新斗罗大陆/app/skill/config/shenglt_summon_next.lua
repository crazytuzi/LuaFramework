-- 技能 升灵台专用召唤下波怪
-- 技能ID 53282
--[[
	偷懒的小怪 4103 4107 4112 4119
	升灵台
	psf 2020-4-13
]]--
local shenglt_summon_next = {
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBSummonMonstersInSoulTower",
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shenglt_summon_next