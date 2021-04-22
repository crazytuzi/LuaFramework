-- 技能 给暴龙加暴击shenglt_baolongzhiwang_critical_buff
-- 技能ID 53339
--[[
	暴龙之王 4127
	升灵台"巨兽沼泽"
]]--
--psf 2020-6-22

local shenglt_baolongzhiwang_ruchang = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {        
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "shenglt_baolongzhiwang_buff"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "shenglt_baolongzhiwang_debuff",all_enemy = true},
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shenglt_baolongzhiwang_ruchang
