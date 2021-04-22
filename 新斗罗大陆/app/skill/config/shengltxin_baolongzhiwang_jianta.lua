-- 技能 暴龙边跑边放AOE
-- 技能ID 53338
--[[
	暴龙之王 4127
	升灵台"巨兽沼泽"
]]--
--psf 2020-6-22

local shenglt_baolongzhiwang_jianta = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {        
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "shenglt_jushouzhaoze_jianta", is_hit_effect = false, haste = true},
        },
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shenglt_baolongzhiwang_jianta
