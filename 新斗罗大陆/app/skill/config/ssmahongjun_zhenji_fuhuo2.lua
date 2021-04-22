-- 技能 ss马红俊变蛋复活1
-- 技能ID 190266
-- 顾名思义 魔法
--[[
	魂师 凤凰马红俊
	ID:1046 
	psf 2019-9-10
]]--

local ssmahongjun_zhenji_fuhuo2 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "ssmahongjun_fumo1", is_target = false},
        },
        {
            CLASS = "action.QSBSetHpPercent",
            OPTIONS = {hp_percent = 1},
        },
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "ssmahongjun_attack15_3", is_hit_effect = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssmahongjun_zhenji_fuhuo2

