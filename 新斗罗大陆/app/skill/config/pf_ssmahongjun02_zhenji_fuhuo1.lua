-- 技能 ss马红俊变蛋复活1
-- 技能ID 190266
-- 顾名思义 魔法
--[[
	魂师 凤凰马红俊
	ID:1046 
	psf 2019-9-10
]]--

local ssmahongjun_zhenji_fuhuo1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBUncancellable"
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "pf_ssmahongjun02_zhenji_biandan1", is_target = false},
        },
        -- {
        --     CLASS = "action.QSBApplyBuff",
        --     OPTIONS = {buff_id = "pf_ssmahongjun02_fumo1", is_target = false},
        -- },
        {
            CLASS = "action.QSBSetHpPercent",
            OPTIONS = {hp_percent = 1},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "pf_ssmahongjun_attack15_2", is_hit_effect = false},
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return ssmahongjun_zhenji_fuhuo1

