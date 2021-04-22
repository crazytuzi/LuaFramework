-- 技能 ss马红俊变蛋出现1
-- 技能ID 190265
-- 顾名思义 魔法
--[[
	魂师 凤凰马红俊
	ID:1046 
	psf 2019-9-10
]]--

local ssmahongjun_zhenji_biandan_chuxian = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBSetHpPercent",
            OPTIONS = {hp_percent = 1},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "ssmahongjun_dan", is_target = false},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "ssmahongjun_attack15_2", is_hit_effect = false},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "ssmahongjun_zhenji_dazhao", is_target = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssmahongjun_zhenji_biandan_chuxian

